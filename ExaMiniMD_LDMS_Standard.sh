#!/bin/bash
#SBATCH --job-name=ExaMiniMD_LDMS_Standard
#SBATCH --partition=local
#SBATCH --nodes=1
#SBATCH --time=30:00:00
#SBATCH --exclusive

if [ -d "data" ]; then :; else mkdir data; fi
if [ -d "logs" ]; then :; else mkdir logs; fi

echo "ExaMiniMD"
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf -r $HOME/ldmsd.pid -v DEBUG &
LDMS_SAMPLER_PID=$!
echo $LDMS_SAMPLER_PID
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf -r $HOME/ldmsd.pid -v DEBUG &
LDMS_AGG_PID=$!
echo $LDMS_AGG_PID
APP_START_TIME=$(date +%s)
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G ExaMiniMD -il ./input_files/ExaMiniMD_in.lj --comm-type MPI
APP_END_TIME=$(date +%s)
APP_DUR=$(($APP_END_TIME - $APP_START_TIME))
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if (($APP_DUR < 60)); then
  echo "App duration less than 60 seconds - too short!"
  exit
fi



mkdir "dataset/ExaMiniMD/run_$(date +'%m_%d_%H%M')"
mv data "dataset/ExaMiniMD/run_$(date +'%m_%d_%H%M')"

mv logs "dataset/ExaMiniMD/run_$(date +'%m_%d_%H%M')"
mkdir data
mkdir logs

killall ldmsd
