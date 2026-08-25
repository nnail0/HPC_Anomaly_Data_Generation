#!/bin/bash
#SBATCH --job-name=SW4lite_LDMS_HPAS
#SBATCH --partition=local
#SBATCH --nodes=1
#SBATCH --time=30:00:00
#SBATCH --exclusive

if [ -d "data" ]; then :; else mkdir data; fi
if [ -d "logs" ]; then :; else mkdir logs; fi

# export SUBSCRIBER_DATA='{"papi_sampler":{"file":"/home/nathaniel-filer/papi.json"}}'

echo "SW4lite"
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf -v DEBUG &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf -v DEBUG &
LDMS_AGG_PID=$!
APP_START_TIME=$(date +%s)
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
APP_END_TIME=$(date +%s)
APP_DUR=$(($APP_END_TIME - $APP_START_TIME))
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if (($APP_DUR < 60)); then
  echo "App duration less than 60 seconds - too short!"
  exit
fi
if [ -d "dataset/SW4lite" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite
  mv data dataset/SW4lite
  mv logs dataset/SW4lite
  mv slurm-* dataset/SW4lite
fi
mkdir data
mkdir logs

killall ldmsd

echo "SW4lite_CO"
ANOM_START_TIME=$(($APP_DUR / 12 + RANDOM % $APP_DUR / 6))
ANOM_END_TIME=$(($APP_DUR * 7 / 12 + RANDOM % $APP_DUR / 6))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95, -t $ANOM_START_TIME -d $(($ANOM_END_TIME - $ANOM_START_TIME)) &
ANOM_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM_PID &> /dev/null; then kill $ANOM_PID; fi
if [ -d "dataset/SW4lite_CO" ]; then :; else mkdir dataset/SW4lite_CO; fi
if [ -d "dataset/SW4lite_CO/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_u95," ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CO/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_u95,
  mv data dataset/SW4lite_CO/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_u95,
  mv logs dataset/SW4lite_CO/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_u95,
  mv slurm-* dataset/SW4lite_CO/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_u95,
fi
mkdir data
mkdir logs

killall ldmsd

echo "SW4lite_ML"
ANOM_START_TIME=$(($APP_DUR / 12 + RANDOM % $APP_DUR / 6))
ANOM_END_TIME=$(($APP_DUR * 7 / 12 + RANDOM % $APP_DUR / 6))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M, -t $ANOM_START_TIME -d $(($ANOM_END_TIME - $ANOM_START_TIME)) &
ANOM_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM_PID &> /dev/null; then kill $ANOM_PID; fi
if [ -d "dataset/SW4lite_ML" ]; then :; else mkdir dataset/SW4lite_ML; fi
if [ -d "dataset/SW4lite_ML/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_s10M," ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_ML/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_s10M,
  mv data dataset/SW4lite_ML/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_s10M,
  mv logs dataset/SW4lite_ML/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_s10M,
  mv slurm-* dataset/SW4lite_ML/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_s10M,
fi
mkdir data
mkdir logs

killall ldmsd

echo "SW4lite_CC"
ANOM_START_TIME=$(($APP_DUR / 12 + RANDOM % $APP_DUR / 6))
ANOM_END_TIME=$(($APP_DUR * 7 / 12 + RANDOM % $APP_DUR / 6))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8, -t $ANOM_START_TIME -d $(($ANOM_END_TIME - $ANOM_START_TIME)) &
ANOM_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM_PID &> /dev/null; then kill $ANOM_PID; fi
if [ -d "dataset/SW4lite_CC" ]; then :; else mkdir dataset/SW4lite_CC; fi
if [ -d "dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL1_m0.8," ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL1_m0.8,
  mv data dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL1_m0.8,
  mv logs dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL1_m0.8,
  mv slurm-* dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL1_m0.8,
fi
mkdir data
mkdir logs

killall ldmsd

echo "SW4lite_CC"
ANOM_START_TIME=$(($APP_DUR / 12 + RANDOM % $APP_DUR / 6))
ANOM_END_TIME=$(($APP_DUR * 7 / 12 + RANDOM % $APP_DUR / 6))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8, -t $ANOM_START_TIME -d $(($ANOM_END_TIME - $ANOM_START_TIME)) &
ANOM_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM_PID &> /dev/null; then kill $ANOM_PID; fi
if [ -d "dataset/SW4lite_CC" ]; then :; else mkdir dataset/SW4lite_CC; fi
if [ -d "dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL2_m0.8," ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL2_m0.8,
  mv data dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL2_m0.8,
  mv logs dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL2_m0.8,
  mv slurm-* dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL2_m0.8,
fi
mkdir data
mkdir logs

killall ldmsd

echo "SW4lite_CC"
ANOM_START_TIME=$(($APP_DUR / 12 + RANDOM % $APP_DUR / 6))
ANOM_END_TIME=$(($APP_DUR * 7 / 12 + RANDOM % $APP_DUR / 6))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM_START_TIME -d $(($ANOM_END_TIME - $ANOM_START_TIME)) &
ANOM_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM_PID &> /dev/null; then kill $ANOM_PID; fi
if [ -d "dataset/SW4lite_CC" ]; then :; else mkdir dataset/SW4lite_CC; fi
if [ -d "dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL3_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL3_m0.8
  mv data dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL3_m0.8
  mv logs dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL3_m0.8
  mv slurm-* dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL3_m0.8
fi
mkdir data
mkdir logs

killall ldmsd 
