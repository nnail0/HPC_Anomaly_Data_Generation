#!/bin/bash
#SBATCH --job-name=ExaMiniMD_LDMS_HPAS
#SBATCH --partition=local
#SBATCH --nodes=1
#SBATCH --time=30:00:00
#SBATCH --exclusive

echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH"
echo "ZAP_LIBPATH = $ZAP_LIBPATH"
ls $ZAP_LIBPATH/libzap_sock.so

which ldmsd
ldmsd -V

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
if [ -d "dataset/ExaMiniMD" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/ExaMiniMD
  mv data dataset/ExaMiniMD
  mv logs dataset/ExaMiniMD
fi
mkdir data
mkdir logs

echo "ExaMiniMD_CO"
ANOM_START_TIME=$(($APP_DUR / 12 + RANDOM % $APP_DUR / 6))
ANOM_END_TIME=$(($APP_DUR * 7 / 12 + RANDOM % $APP_DUR / 6))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf -r /tmp/$USER/ldms/ldmsd.pid -v DEBUG &
LDMS_SAMPLER_PID=$!
echo $LDMS_SAMPLER_PID
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf -r /tmp/$USER/ldms/ldmsd.pid -v DEBUG &
LDMS_AGG_PID=$!
echo $LDMS_AGG_PID
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM_START_TIME -d $(($ANOM_END_TIME - $ANOM_START_TIME)) &
ANOM_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G ExaMiniMD -il ./input_files/ExaMiniMD_in.lj --comm-type MPI
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM_PID &> /dev/null; then kill $ANOM_PID; fi
if [ -d "dataset/ExaMiniMD_CO" ]; then :; else mkdir dataset/ExaMiniMD_CO; fi
if [ -d "dataset/ExaMiniMD_CO/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_u95" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/ExaMiniMD_CO/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_u95
  mv data dataset/ExaMiniMD_CO/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_u95
  mv logs dataset/ExaMiniMD_CO/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_u95
fi
mkdir data
mkdir logs

