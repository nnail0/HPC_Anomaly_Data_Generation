#!/usr/bin/env python3
"""
Hardware-agnostic thermal logger for Linux.
Reads sysfs (hwmon, thermal), optional lm-sensors, optional nvidia-smi.
Outputs wide-format CSV for analysis and curve derivation.
"""

import argparse
import csv
import json
import re
import subprocess
import time
from dataclasses import dataclass
from pathlib import Path


def read_sysfs(path: Path) -> float | None:
    """Read numeric value from sysfs, return None if missing or invalid."""
    try:
        raw = path.read_text().strip()
        return float(raw) if raw else None
    except (OSError, ValueError):
        return None


def read_sysfs_text(path: Path) -> str | None:
    """Read text from sysfs (for type, name, label files). Returns None if missing."""
    try:
        raw = path.read_text().strip()
        return raw if raw else None
    except OSError:
        return None


@dataclass(frozen=True, slots=True)
class HwmonChannel:
    """One hwmon sysfs file discovered at startup; read() fetches the current value."""

    path: Path
    column: str
    kind: str  # "power_uw" | "temp_milli" | "raw"

    def read(self) -> dict[str, float]:
        val = read_sysfs(self.path)
        if val is None:
            return {}
        if self.kind == "power_uw":
            return {self.column: round(val / 1_000_000, 3)}
        if self.kind == "temp_milli":
            if val > 1000:
                val = round(val / 1000, 2)
            return {self.column: val}
        return {self.column: val}


def discover_hwmon_channels() -> list[HwmonChannel]:
    """Enumerate hwmon temp, fan, and power inputs (no sensor values read)."""
    out: list[HwmonChannel] = []
    hwmon = Path("/sys/class/hwmon")
    if not hwmon.exists():
        return out

    for dev in sorted(hwmon.iterdir()):
        name = read_sysfs_text(dev / "name")
        prefix = f"hwmon_{dev.name}"
        if name:
            prefix = f"{prefix}_{re.sub(r'[^a-zA-Z0-9]', '_', name)}"

        for f in dev.iterdir():
            if not f.is_file():
                continue
            if f.name == "power1_input":
                out.append(HwmonChannel(f, f"{prefix}_power_W", "power_uw"))
            elif "_input" in f.name:
                col = f"{prefix}_{f.name.replace('_input', '')}"
                kind = "temp_milli" if "temp" in f.name else "raw"
                out.append(HwmonChannel(f, col, kind))

    return out


@dataclass(frozen=True, slots=True)
class ThermalZoneChannel:
    path: Path
    column: str

    def read(self) -> dict[str, float]:
        val = read_sysfs(self.path)
        if val is None:
            return {}
        return {self.column: val / 1000}  # mC -> C


def discover_thermal_zone_channels() -> list[ThermalZoneChannel]:
    """Enumerate thermal zone temp files (no values read)."""
    out: list[ThermalZoneChannel] = []
    thermal = Path("/sys/class/thermal")
    if not thermal.exists():
        return out

    for tz in sorted(thermal.glob("thermal_zone*")):
        temp_path = tz / "temp"
        if not temp_path.exists():
            continue
        type_name = read_sysfs_text(tz / "type") or tz.name
        col = f"thermal_{tz.name}_{re.sub(r'[^a-zA-Z0-9]', '_', type_name)}_C"
        out.append(ThermalZoneChannel(temp_path, col))

    return out


@dataclass(frozen=True, slots=True)
class CoolingChannel:
    cur_path: Path
    max_path: Path
    column: str

    def read(self) -> dict[str, float]:
        val = read_sysfs(self.cur_path)
        if val is None:
            return {}
        out: dict[str, float] = {self.column: val}
        max_val = read_sysfs(self.max_path)
        if max_val and max_val > 0:
            out[f"{self.column}_pct"] = round(100 * val / max_val, 2)
        return out


def discover_cooling_channels() -> list[CoolingChannel]:
    """Enumerate cooling device state files (no values read)."""
    out: list[CoolingChannel] = []
    thermal = Path("/sys/class/thermal")
    if not thermal.exists():
        return out

    for cd in sorted(thermal.glob("cooling_device*")):
        cur_path = cd / "cur_state"
        if not cur_path.exists():
            continue
        type_name = read_sysfs_text(cd / "type") or cd.name
        col = f"cooling_{cd.name}_{re.sub(r'[^a-zA-Z0-9]', '_', type_name)}"
        out.append(CoolingChannel(cur_path, cd / "max_state", col))

    return out


def read_nvidia_smi() -> dict[str, float]:
    """Query nvidia-smi for GPU temp, power, utilization."""
    out: dict[str, float] = {}
    try:
        result = subprocess.run(
            [
                "nvidia-smi",
                "--query-gpu=temperature.gpu,power.draw,utilization.gpu,utilization.memory,fan.speed",
                "--format=csv,noheader,nounits",
            ],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode != 0 or not result.stdout.strip():
            return out

        parts = [p.strip() for p in result.stdout.strip().split(",")]
        if len(parts) >= 1:
            try:
                out["gpu_temp_C"] = float(parts[0])
            except ValueError:
                pass
        if len(parts) >= 2:
            try:
                out["gpu_power_W"] = float(parts[1].replace(" W", "").strip())
            except ValueError:
                pass
        if len(parts) >= 3:
            try:
                out["gpu_util_pct"] = float(parts[2].replace("%", "").strip())
            except ValueError:
                pass
        if len(parts) >= 4:
            try:
                out["gpu_mem_util_pct"] = float(parts[3].replace("%", "").strip())
            except ValueError:
                pass
        if len(parts) >= 5:
            try:
                out["gpu_fan_pct"] = float(parts[4].replace("%", "").strip())
            except ValueError:
                pass
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass
    return out


def read_lm_sensors() -> dict[str, float]:
    """Parse lm-sensors output if available (fallback/additional data)."""
    out: dict[str, float] = {}
    try:
        result = subprocess.run(
            ["sensors", "-j"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode != 0:
            return out

        data = json.loads(result.stdout)
        for chip, entries in data.items():
            prefix = f"sensors_{re.sub(r'[^a-zA-Z0-9]', '_', chip)}"
            for label, vals in entries.items():
                if isinstance(vals, dict) and "input" in vals:
                    try:
                        v = float(vals["input"])
                        col = f"{prefix}_{re.sub(r'[^a-zA-Z0-9]', '_', label)}"
                        out[col] = v
                    except (ValueError, TypeError):
                        pass
    except (FileNotFoundError, subprocess.TimeoutExpired, ValueError):
        pass
    return out


@dataclass
class SensorSession:
    """Discovered once; each row only reads current values from known paths / tools."""

    hwmon: list[HwmonChannel]
    thermal: list[ThermalZoneChannel]
    cooling: list[CoolingChannel]
    use_nvidia: bool
    use_lm_sensors: bool

    @classmethod
    def create(cls, use_lm_sensors: bool, use_nvidia: bool) -> "SensorSession":
        return cls(
            hwmon=discover_hwmon_channels(),
            thermal=discover_thermal_zone_channels(),
            cooling=discover_cooling_channels(),
            use_nvidia=use_nvidia,
            use_lm_sensors=use_lm_sensors,
        )

    def read_row(self) -> dict[str, float]:
        row: dict[str, float] = {}
        for c in self.hwmon:
            row.update(c.read())
        for c in self.thermal:
            row.update(c.read())
        for c in self.cooling:
            row.update(c.read())
        if self.use_nvidia:
            row.update(read_nvidia_smi())
        if self.use_lm_sensors:
            row.update(read_lm_sensors())
        return row


def gather_row(use_lm_sensors: bool = True, use_nvidia: bool = True) -> dict[str, float]:
    """
    One-shot: discover all sensors and return one row.
    For repeated logging, use SensorSession.create(...).read_row() in a loop.
    """
    return SensorSession.create(use_lm_sensors, use_nvidia).read_row()


def get_ordered_columns(rows: list[dict]) -> list[str]:
    """Return column order: timestamp first, then stable sort of the rest."""
    if not rows:
        return ["timestamp"]
    cols: set[str] = set()
    for r in rows:
        cols.update(r.keys())
    others = sorted(cols - {"timestamp"})
    return ["timestamp"] + others


def main() -> None:
    parser = argparse.ArgumentParser(description="Thermal logger (wide CSV)")
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=Path("thermal_log.csv"),
        help="Output CSV path",
    )
    parser.add_argument(
        "-i",
        "--interval",
        type=float,
        default=5.0,
        help="Poll interval in seconds (default: 5)",
    )
    parser.add_argument(
        "--once",
        action="store_true",
        help="Run once and exit (for cron)",
    )
    parser.add_argument(
        "--no-lm-sensors",
        action="store_true",
        help="Skip lm-sensors (use sysfs only)",
    )
    parser.add_argument(
        "--no-nvidia",
        action="store_true",
        help="Skip nvidia-smi",
    )
    args = parser.parse_args()

    output = args.output
    write_header = not output.exists()
    rows_buffer: list[dict] = []
    session = SensorSession.create(
        use_lm_sensors=not args.no_lm_sensors,
        use_nvidia=not args.no_nvidia,
    )

    def flush():
        nonlocal write_header
        if not rows_buffer:
            return
        columns = get_ordered_columns(rows_buffer)
        with output.open("a", newline="") as f:
            w = csv.DictWriter(f, fieldnames=columns, extrasaction="ignore")
            if write_header:
                w.writeheader()
                write_header = False
            w.writerows(rows_buffer)
        rows_buffer.clear()

    try:
        while True:
            ts = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
            row = session.read_row()
            row["timestamp"] = ts
            rows_buffer.append(row)
            flush()

            if args.once:
                break
            time.sleep(args.interval)
    except KeyboardInterrupt:
        pass
    finally:
        flush()


if __name__ == "__main__":
    main()
