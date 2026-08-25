#!/bin/bash
#SBATCH --job-name=ExaMiniMD_LDMS_Standard
#SBATCH --partition=local
#SBATCH --nodes=1
#SBATCH --time=30:00:00

if [ -d "data" ]; then :; else mkdir data; fi
if [ -d "logs" ]; then :; else mkdir logs; fi

#export CALI_CONFIG="libpfm(events=perf::PERF_COUNT_HW_CPU_CYCLES),memstat,ldms(stream=caliper,host=localhost,port=10001,xprt=sock)"
# export CALI_SERVICES_ENABLE=loop_monitor,mpi,ldms,libpfm,memstat
# export CALI_LDMS_STREAM=caliper
# export CALI_LDMS_XPRT=sock
# export CALI_LDMS_HOST=localhost
# export CALI_LDMS_PORT=10001
# export CALI_LDMS_AUTH=none
# export LD_LIBRARY_PATH=/home/nathaniel-filer/caliper-2.14.0/lib:/usr/local/lib:/home/nathaniel-filer/ldms/lib64:$LD_LIBRARY_PATH

echo "ExaMiniMD"
INIT_START_TIME=$(date +%s)
srun --exclusive --ntasks=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf -r $HOME/ldmsd.pid -v DEBUG &
LDMS_SAMPLER_PID=$!
echo $LDMS_SAMPLER_PID
srun --exclusive --ntasks=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf -r $HOME/ldmsd.pid -v DEBUG &
LDMS_AGG_PID=$!
echo $LDMS_AGG_PID
INIT_END_TIME=$(date +%s)
echo "Initalization time:" $(($INIT_END_TIME - $INIT_START_TIME))

srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G ExaMiniMD -il ./input_files/ExaMiniMD_in.lj --comm-type MPI
APP_START_TIME=$(date +%s)
#srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sleep 60
#srun --exclusive --ntasks=1 --cpus-per-task=8 --mem=20G ExaMiniMD -il ./input_files/ExaMiniMD_in.lj --comm-type MPI
# srun --exclusive --export=ALL,LD_PRELOAD=/home/nathaniel-filer/caliper-2.14.0/lib/libcaliper.so \
#   --ntasks=1 --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G \
#   ExaMiniMD -il ./input_files/ExaMiniMD_in.lj --comm-type MPI

# S1_PID=$!
# J1_PID=$(pgrep -P $S1_PID) 
# echo $J1_PID

APP_END_TIME=$(date +%s)
APP_DUR=$(($APP_END_TIME - $APP_START_TIME))
CLEANUP_START=$(date +%s)
echo "App duration: " $APP_DUR
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if (($APP_DUR < 60)); then
  echo "App duration less than 60



mkdir "dataset/ExaMiniMD/run_$(date +'%m_%d_%H%M')"
mv data "dataset/ExaMiniMD/run_$(date +'%m_%d_%H%M')"
mv slurm-* "dataset/ExaMiniMD/run_$(date +'%m_%d_%H%M')"

mv logs "dataset/ExaMiniMD/run_$(date +'%m_%d_%H%M')"
mkdir data
mkdir logs

killall ldmsd
CLEANUP_END=$(date +%s)
echo "Cleanup time:" $(($CLEANUP_END - $CLEANUP_START))
