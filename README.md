# HPC-Anomaly-Data-Generation
## Background
### LDMS (Lightweight Distributed Metric System)
LDMS samples a system's metrics and records them.  This project uses LDMS to generate data using the "meminfo", "vmstat", and "procstat" plugins, but could be adjusted to use others.  Here are some resources for using it:
 - [LDMS Github](https://github.com/ovis-hpc/ldms)
 - [LDMS Documentation](https://ovis-hpc.readthedocs.io/en/latest/)
    - [LDMS Quick Start](https://ovis-hpc.readthedocs.io/projects/ldms/en/latest/intro/quick-start.html)
    - [LDMS Tutorial Slides](https://sites.google.com/view/ldmscon2024/tutorials/tutorial-slides)
### HPAS (HPC Performance Anomaly Suite)
HPAS contains anomalies that can be executed while an application runs to simulate anomalous behavior.  This project gathers data while an application runs alongside one or more anomalies to see how they affect the system metrics.  This project only uses "cpuoccupy", "memleak", and "cachecopy", but could be adapted to use others.  Here are some resources for using HPAS:
 - [HPAS Github](https://github.com/peaclab/HPAS)
 - Note: once installed, `hpas -h` will show a list of the available anomalies, and `hpas <anomaly_name> -h` will show the usage for a specific anomaly.
### Proxy Apps
While generating data, this project runs proxy apps, which are simplified codes that emulate features or the behavior of larger code bases.  This project only generated data using "ExaMiniMD" and "SW4lite", but is intended to work with any application.  Here are some resources for installing and using proxy apps:
 - [Exascale Computing Project - Proxy Apps Suite](https://proxyapps.exascaleproject.org/)
 - [ExaMiniMD](https://proxyapps.exascaleproject.org/app/examinimd/)
 - [SW4lite](https://proxyapps.exascaleproject.org/app/sw4lite/)
## Data Generation Scripts
`LDMS_HPAS_Script_Generator.py` takes arguments specifying the details and parameters of the data generation, and creates a script that will generate the data.
## Notebook for Reading/Plotting Data
## Potential Future Work
