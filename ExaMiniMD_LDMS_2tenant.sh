#!/bin/bash
#SBATCH --job-name=ExaMiniMD_MT_LDMS_HPAS
#SBATCH --partition=local
#SBATCH --nodes=1
#SBATCH --time=30:00:00
#SBATCH --exclusive

########################################
# Helpers
########################################

prep_dirs() {
  rm -rf data logs
  mkdir -p data logs
}

start_ldms() {
  srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G \
       ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
  LDMS_SAMPLER_PID=$!

  srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G \
       ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
  LDMS_AGG_PID=$!
}

stop_ldms() {
  killall ldmsd 2>/dev/null
  sleep 2
}

start_anomaly() {
  local TYPE=$1
  local ST=$2
  local DUR=$3

  case $TYPE in
    CO)
      srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=20G \
        hpas cpuoccupy -u 95, -t $ST -d $DUR &
      ;;
    ML)
      srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=20G \
        hpas memleak -s 10M, -t $ST -d $DUR &
      ;;
    CC)
      srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=20G \
        hpas cachecopy -c L3 -m 0.8 -t $ST -d $DUR &
      ;;
    *)
      return
      ;;
  esac
  echo $!
}

stop_anomaly() {
  for pid in "$@"; do
    if kill -0 $pid &>/dev/null; then
      kill $pid
    fi
  done
}

########################################
# Baseline
########################################

echo "Baseline single-tenant run"
prep_dirs
start_ldms

APP_START=$(date +%s)
srun --exclusive --cpu-bind=verbose \
     --ntasks-per-node=1 --cpus-per-task=8 --mem=20G \
     ExaMiniMD -il ./input_files/ExaMiniMD_in.lj --comm-type MPI
APP_END=$(date +%s)

stop_ldms

BASE_DUR=$((APP_END - APP_START))
if (( BASE_DUR < 60 )); then
  echo "Baseline too short"
  exit 1
fi

########################################
# Two-tenant run
########################################

run_two_tenants() {
  local LABEL=$1
  local ANOM1=$2
  local ANOM2=$3

  echo "Running $LABEL"
  prep_dirs
  start_ldms

  ANOM_TAG=""
  ANOM_PIDS=()

  if [ "$ANOM1" != "STD" ]; then
    ST1=$((BASE_DUR / 12 + RANDOM % (BASE_DUR / 6)))
    ET1=$((BASE_DUR * 7 / 12 + RANDOM % (BASE_DUR / 6)))
    PID1=$(start_anomaly "$ANOM1" "$ST1" "$((ET1 - ST1))")
    ANOM_PIDS+=($PID1)
    ANOM_TAG="ST${ST1}_ET${ET1}_${ANOM1}"
  fi

  if [ "$ANOM2" != "STD" ]; then
    ST2=$((BASE_DUR / 12 + RANDOM % (BASE_DUR / 6)))
    ET2=$((BASE_DUR * 7 / 12 + RANDOM % (BASE_DUR / 6)))
    PID2=$(start_anomaly "$ANOM2" "$ST2" "$((ET2 - ST2))")
    ANOM_PIDS+=($PID2)
    ANOM_TAG="${ANOM_TAG}_ST${ST2}_ET${ET2}_${ANOM2}"
  fi

  srun --exclusive --cpu-bind=verbose \
       --ntasks-per-node=1 --cpus-per-task=8 --mem=20G \
       ExaMiniMD -il ./input_files/ExaMiniMD_in.lj --comm-type MPI &

  srun --exclusive --cpu-bind=verbose \
       --ntasks-per-node=1 --cpus-per-task=8 --mem=20G \
       ExaMiniMD -il ./input_files/ExaMiniMD_in.lj --comm-type MPI &

  wait

  stop_anomaly "${ANOM_PIDS[@]}"
  stop_ldms

  OUTDIR="dataset/ExaMiniMD_MT/${LABEL}/${ANOM_TAG}_2tenant"
  mkdir -p "$OUTDIR"

  mv data logs "$OUTDIR"
  ls slurm-* &>/dev/null && mv slurm-* "$OUTDIR"
}

########################################
# Permutations
########################################

run_two_tenants STD_STD  STD STD
run_two_tenants STD_CO   STD CO
run_two_tenants STD_ML   STD ML
run_two_tenants STD_CC   STD CC
run_two_tenants CO_ML    CO  ML
run_two_tenants CO_CC    CO  CC
