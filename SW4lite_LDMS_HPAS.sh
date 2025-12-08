#!/bin/bash
#SBATCH --job-name=SW4lite_LDMS_HPAS
#SBATCH --partition=local
#SBATCH --nodes=1
#SBATCH --time=30:00:00
#SBATCH --exclusive

if [ -d "data" ]; then :; else mkdir data; fi
if [ -d "logs" ]; then :; else mkdir logs; fi

sleep 30
echo "SW4lite"
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
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
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CO"
ANOM_START_TIME=$(($APP_DUR / 12 + RANDOM % $APP_DUR / 6))
ANOM_END_TIME=$(($APP_DUR * 7 / 12 + RANDOM % $APP_DUR / 6))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM_START_TIME -d $(($ANOM_END_TIME - $ANOM_START_TIME)) &
ANOM_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM_PID &> /dev/null; then kill $ANOM_PID; fi
if [ -d "dataset/SW4lite_CO" ]; then :; else mkdir dataset/SW4lite_CO; fi
if [ -d "dataset/SW4lite_CO/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_u95" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CO/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_u95
  mv data dataset/SW4lite_CO/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_u95
  mv logs dataset/SW4lite_CO/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_u95
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_ML"
ANOM_START_TIME=$(($APP_DUR / 12 + RANDOM % $APP_DUR / 6))
ANOM_END_TIME=$(($APP_DUR * 7 / 12 + RANDOM % $APP_DUR / 6))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM_START_TIME -d $(($ANOM_END_TIME - $ANOM_START_TIME)) &
ANOM_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM_PID &> /dev/null; then kill $ANOM_PID; fi
if [ -d "dataset/SW4lite_ML" ]; then :; else mkdir dataset/SW4lite_ML; fi
if [ -d "dataset/SW4lite_ML/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_s10M" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_ML/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_s10M
  mv data dataset/SW4lite_ML/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_s10M
  mv logs dataset/SW4lite_ML/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_s10M
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC"
ANOM_START_TIME=$(($APP_DUR / 12 + RANDOM % $APP_DUR / 6))
ANOM_END_TIME=$(($APP_DUR * 7 / 12 + RANDOM % $APP_DUR / 6))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM_START_TIME -d $(($ANOM_END_TIME - $ANOM_START_TIME)) &
ANOM_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM_PID &> /dev/null; then kill $ANOM_PID; fi
if [ -d "dataset/SW4lite_CC" ]; then :; else mkdir dataset/SW4lite_CC; fi
if [ -d "dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL1_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL1_m0.8
  mv data dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL1_m0.8
  mv logs dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL1_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC"
ANOM_START_TIME=$(($APP_DUR / 12 + RANDOM % $APP_DUR / 6))
ANOM_END_TIME=$(($APP_DUR * 7 / 12 + RANDOM % $APP_DUR / 6))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM_START_TIME -d $(($ANOM_END_TIME - $ANOM_START_TIME)) &
ANOM_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM_PID &> /dev/null; then kill $ANOM_PID; fi
if [ -d "dataset/SW4lite_CC" ]; then :; else mkdir dataset/SW4lite_CC; fi
if [ -d "dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL2_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL2_m0.8
  mv data dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL2_m0.8
  mv logs dataset/SW4lite_CC/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}_cL2_m0.8
fi
mkdir data
mkdir logs

sleep 30
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
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CO_CO/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CO_CO" ]; then :; else mkdir dataset/SW4lite_CO_CO; fi
if [ -d "dataset/SW4lite_CO_CO/separate" ]; then :; else mkdir dataset/SW4lite_CO_CO/separate; fi
if [ -d "dataset/SW4lite_CO_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CO_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv data dataset/SW4lite_CO_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv logs dataset/SW4lite_CO_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CO_ML/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CO_ML" ]; then :; else mkdir dataset/SW4lite_CO_ML; fi
if [ -d "dataset/SW4lite_CO_ML/separate" ]; then :; else mkdir dataset/SW4lite_CO_ML/separate; fi
if [ -d "dataset/SW4lite_CO_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CO_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv data dataset/SW4lite_CO_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv logs dataset/SW4lite_CO_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CO_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CO_CC" ]; then :; else mkdir dataset/SW4lite_CO_CC; fi
if [ -d "dataset/SW4lite_CO_CC/separate" ]; then :; else mkdir dataset/SW4lite_CO_CC/separate; fi
if [ -d "dataset/SW4lite_CO_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CO_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv data dataset/SW4lite_CO_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv logs dataset/SW4lite_CO_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CO_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CO_CC" ]; then :; else mkdir dataset/SW4lite_CO_CC; fi
if [ -d "dataset/SW4lite_CO_CC/separate" ]; then :; else mkdir dataset/SW4lite_CO_CC/separate; fi
if [ -d "dataset/SW4lite_CO_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CO_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv data dataset/SW4lite_CO_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv logs dataset/SW4lite_CO_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CO_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CO_CC" ]; then :; else mkdir dataset/SW4lite_CO_CC; fi
if [ -d "dataset/SW4lite_CO_CC/separate" ]; then :; else mkdir dataset/SW4lite_CO_CC/separate; fi
if [ -d "dataset/SW4lite_CO_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CO_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv data dataset/SW4lite_CO_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv logs dataset/SW4lite_CO_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_ML_CO/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_ML_CO" ]; then :; else mkdir dataset/SW4lite_ML_CO; fi
if [ -d "dataset/SW4lite_ML_CO/separate" ]; then :; else mkdir dataset/SW4lite_ML_CO/separate; fi
if [ -d "dataset/SW4lite_ML_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_ML_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv data dataset/SW4lite_ML_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv logs dataset/SW4lite_ML_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_ML_ML/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_ML_ML" ]; then :; else mkdir dataset/SW4lite_ML_ML; fi
if [ -d "dataset/SW4lite_ML_ML/separate" ]; then :; else mkdir dataset/SW4lite_ML_ML/separate; fi
if [ -d "dataset/SW4lite_ML_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_ML_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv data dataset/SW4lite_ML_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv logs dataset/SW4lite_ML_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_ML_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_ML_CC" ]; then :; else mkdir dataset/SW4lite_ML_CC; fi
if [ -d "dataset/SW4lite_ML_CC/separate" ]; then :; else mkdir dataset/SW4lite_ML_CC/separate; fi
if [ -d "dataset/SW4lite_ML_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_ML_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv data dataset/SW4lite_ML_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv logs dataset/SW4lite_ML_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_ML_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_ML_CC" ]; then :; else mkdir dataset/SW4lite_ML_CC; fi
if [ -d "dataset/SW4lite_ML_CC/separate" ]; then :; else mkdir dataset/SW4lite_ML_CC/separate; fi
if [ -d "dataset/SW4lite_ML_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_ML_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv data dataset/SW4lite_ML_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv logs dataset/SW4lite_ML_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_ML_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_ML_CC" ]; then :; else mkdir dataset/SW4lite_ML_CC; fi
if [ -d "dataset/SW4lite_ML_CC/separate" ]; then :; else mkdir dataset/SW4lite_ML_CC/separate; fi
if [ -d "dataset/SW4lite_ML_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_ML_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv data dataset/SW4lite_ML_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv logs dataset/SW4lite_ML_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CO/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CO" ]; then :; else mkdir dataset/SW4lite_CC_CO; fi
if [ -d "dataset/SW4lite_CC_CO/separate" ]; then :; else mkdir dataset/SW4lite_CC_CO/separate; fi
if [ -d "dataset/SW4lite_CC_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv data dataset/SW4lite_CC_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv logs dataset/SW4lite_CC_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_ML/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_ML" ]; then :; else mkdir dataset/SW4lite_CC_ML; fi
if [ -d "dataset/SW4lite_CC_ML/separate" ]; then :; else mkdir dataset/SW4lite_CC_ML/separate; fi
if [ -d "dataset/SW4lite_CC_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv data dataset/SW4lite_CC_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv logs dataset/SW4lite_CC_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/separate" ]; then :; else mkdir dataset/SW4lite_CC_CC/separate; fi
if [ -d "dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv data dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv logs dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/separate" ]; then :; else mkdir dataset/SW4lite_CC_CC/separate; fi
if [ -d "dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv data dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv logs dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/separate" ]; then :; else mkdir dataset/SW4lite_CC_CC/separate; fi
if [ -d "dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv data dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv logs dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CO/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CO" ]; then :; else mkdir dataset/SW4lite_CC_CO; fi
if [ -d "dataset/SW4lite_CC_CO/separate" ]; then :; else mkdir dataset/SW4lite_CC_CO/separate; fi
if [ -d "dataset/SW4lite_CC_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv data dataset/SW4lite_CC_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv logs dataset/SW4lite_CC_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_ML/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_ML" ]; then :; else mkdir dataset/SW4lite_CC_ML; fi
if [ -d "dataset/SW4lite_CC_ML/separate" ]; then :; else mkdir dataset/SW4lite_CC_ML/separate; fi
if [ -d "dataset/SW4lite_CC_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv data dataset/SW4lite_CC_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv logs dataset/SW4lite_CC_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/separate" ]; then :; else mkdir dataset/SW4lite_CC_CC/separate; fi
if [ -d "dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv data dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv logs dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/separate" ]; then :; else mkdir dataset/SW4lite_CC_CC/separate; fi
if [ -d "dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv data dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv logs dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/separate" ]; then :; else mkdir dataset/SW4lite_CC_CC/separate; fi
if [ -d "dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv data dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv logs dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CO/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CO" ]; then :; else mkdir dataset/SW4lite_CC_CO; fi
if [ -d "dataset/SW4lite_CC_CO/separate" ]; then :; else mkdir dataset/SW4lite_CC_CO/separate; fi
if [ -d "dataset/SW4lite_CC_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv data dataset/SW4lite_CC_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv logs dataset/SW4lite_CC_CO/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_ML/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_ML" ]; then :; else mkdir dataset/SW4lite_CC_ML; fi
if [ -d "dataset/SW4lite_CC_ML/separate" ]; then :; else mkdir dataset/SW4lite_CC_ML/separate; fi
if [ -d "dataset/SW4lite_CC_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv data dataset/SW4lite_CC_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv logs dataset/SW4lite_CC_ML/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/separate" ]; then :; else mkdir dataset/SW4lite_CC_CC/separate; fi
if [ -d "dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv data dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv logs dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/separate" ]; then :; else mkdir dataset/SW4lite_CC_CC/separate; fi
if [ -d "dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv data dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv logs dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/separate"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/separate" ]; then :; else mkdir dataset/SW4lite_CC_CC/separate; fi
if [ -d "dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv data dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv logs dataset/SW4lite_CC_CC/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CO_CO/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CO_CO" ]; then :; else mkdir dataset/SW4lite_CO_CO; fi
if [ -d "dataset/SW4lite_CO_CO/overlaps" ]; then :; else mkdir dataset/SW4lite_CO_CO/overlaps; fi
if [ -d "dataset/SW4lite_CO_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CO_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv data dataset/SW4lite_CO_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv logs dataset/SW4lite_CO_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CO_ML/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CO_ML" ]; then :; else mkdir dataset/SW4lite_CO_ML; fi
if [ -d "dataset/SW4lite_CO_ML/overlaps" ]; then :; else mkdir dataset/SW4lite_CO_ML/overlaps; fi
if [ -d "dataset/SW4lite_CO_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CO_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv data dataset/SW4lite_CO_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv logs dataset/SW4lite_CO_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CO_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CO_CC" ]; then :; else mkdir dataset/SW4lite_CO_CC; fi
if [ -d "dataset/SW4lite_CO_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_CO_CC/overlaps; fi
if [ -d "dataset/SW4lite_CO_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CO_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv data dataset/SW4lite_CO_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv logs dataset/SW4lite_CO_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CO_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CO_CC" ]; then :; else mkdir dataset/SW4lite_CO_CC; fi
if [ -d "dataset/SW4lite_CO_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_CO_CC/overlaps; fi
if [ -d "dataset/SW4lite_CO_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CO_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv data dataset/SW4lite_CO_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv logs dataset/SW4lite_CO_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CO_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CO_CC" ]; then :; else mkdir dataset/SW4lite_CO_CC; fi
if [ -d "dataset/SW4lite_CO_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_CO_CC/overlaps; fi
if [ -d "dataset/SW4lite_CO_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CO_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv data dataset/SW4lite_CO_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv logs dataset/SW4lite_CO_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_u95_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_ML_CO/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_ML_CO" ]; then :; else mkdir dataset/SW4lite_ML_CO; fi
if [ -d "dataset/SW4lite_ML_CO/overlaps" ]; then :; else mkdir dataset/SW4lite_ML_CO/overlaps; fi
if [ -d "dataset/SW4lite_ML_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_ML_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv data dataset/SW4lite_ML_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv logs dataset/SW4lite_ML_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_ML_ML/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_ML_ML" ]; then :; else mkdir dataset/SW4lite_ML_ML; fi
if [ -d "dataset/SW4lite_ML_ML/overlaps" ]; then :; else mkdir dataset/SW4lite_ML_ML/overlaps; fi
if [ -d "dataset/SW4lite_ML_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_ML_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv data dataset/SW4lite_ML_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv logs dataset/SW4lite_ML_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_ML_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_ML_CC" ]; then :; else mkdir dataset/SW4lite_ML_CC; fi
if [ -d "dataset/SW4lite_ML_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_ML_CC/overlaps; fi
if [ -d "dataset/SW4lite_ML_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_ML_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv data dataset/SW4lite_ML_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv logs dataset/SW4lite_ML_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_ML_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_ML_CC" ]; then :; else mkdir dataset/SW4lite_ML_CC; fi
if [ -d "dataset/SW4lite_ML_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_ML_CC/overlaps; fi
if [ -d "dataset/SW4lite_ML_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_ML_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv data dataset/SW4lite_ML_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv logs dataset/SW4lite_ML_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_ML_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_ML_CC" ]; then :; else mkdir dataset/SW4lite_ML_CC; fi
if [ -d "dataset/SW4lite_ML_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_ML_CC/overlaps; fi
if [ -d "dataset/SW4lite_ML_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_ML_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv data dataset/SW4lite_ML_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv logs dataset/SW4lite_ML_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_s10M_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CO/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CO" ]; then :; else mkdir dataset/SW4lite_CC_CO; fi
if [ -d "dataset/SW4lite_CC_CO/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_CO/overlaps; fi
if [ -d "dataset/SW4lite_CC_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv data dataset/SW4lite_CC_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv logs dataset/SW4lite_CC_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_ML/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_ML" ]; then :; else mkdir dataset/SW4lite_CC_ML; fi
if [ -d "dataset/SW4lite_CC_ML/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_ML/overlaps; fi
if [ -d "dataset/SW4lite_CC_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv data dataset/SW4lite_CC_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv logs dataset/SW4lite_CC_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_CC/overlaps; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv data dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv logs dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_CC/overlaps; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv data dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv logs dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_CC/overlaps; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv data dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv logs dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL1_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CO/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CO" ]; then :; else mkdir dataset/SW4lite_CC_CO; fi
if [ -d "dataset/SW4lite_CC_CO/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_CO/overlaps; fi
if [ -d "dataset/SW4lite_CC_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv data dataset/SW4lite_CC_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv logs dataset/SW4lite_CC_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_ML/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_ML" ]; then :; else mkdir dataset/SW4lite_CC_ML; fi
if [ -d "dataset/SW4lite_CC_ML/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_ML/overlaps; fi
if [ -d "dataset/SW4lite_CC_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv data dataset/SW4lite_CC_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv logs dataset/SW4lite_CC_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_CC/overlaps; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv data dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv logs dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_CC/overlaps; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv data dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv logs dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_CC/overlaps; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv data dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv logs dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL2_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CO/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cpuoccupy -u 95 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CO" ]; then :; else mkdir dataset/SW4lite_CC_CO; fi
if [ -d "dataset/SW4lite_CC_CO/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_CO/overlaps; fi
if [ -d "dataset/SW4lite_CC_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv data dataset/SW4lite_CC_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
  mv logs dataset/SW4lite_CC_CO/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_u95
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_ML/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas memleak -s 10M -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_ML" ]; then :; else mkdir dataset/SW4lite_CC_ML; fi
if [ -d "dataset/SW4lite_CC_ML/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_ML/overlaps; fi
if [ -d "dataset/SW4lite_CC_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv data dataset/SW4lite_CC_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
  mv logs dataset/SW4lite_CC_ML/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_s10M
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L1 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_CC/overlaps; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv data dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
  mv logs dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL1_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L2 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_CC/overlaps; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv data dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
  mv logs dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL2_m0.8
fi
mkdir data
mkdir logs

sleep 30
echo "SW4lite_CC_CC/overlaps"
ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))
ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))
ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &
LDMS_SAMPLER_PID=$!
srun --exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &
LDMS_AGG_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &
ANOM1_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G hpas cachecopy -c L3 -m 0.8 -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &
ANOM2_PID=$!
srun --exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G sw4lite ./input_files/SW4lite.in
kill $LDMS_AGG_PID
kill $LDMS_SAMPLER_PID
if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi
if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi
if [ -d "dataset/SW4lite_CC_CC" ]; then :; else mkdir dataset/SW4lite_CC_CC; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps" ]; then :; else mkdir dataset/SW4lite_CC_CC/overlaps; fi
if [ -d "dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8" ]; then
  rm -r data
  rm -r logs
else
  mkdir dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv data dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
  mv logs dataset/SW4lite_CC_CC/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}_cL3_m0.8_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}_cL3_m0.8
fi
mkdir data
mkdir logs

