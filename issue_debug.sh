#!/bin/bash

echo "Starting sampler"
srun --exclusive --ntasks=1 ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf -r $HOME/ldmsd_sampler.pid -v DEBUG
echo "Sampler exit code: $?"

echo "Starting aggregator"
srun --exclusive --ntasks=1 ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf -r $HOME/ldmsd_aggregator.pid -v DEBUG
echo "Aggregator exit code: $?"

echo "Starting sleep"
srun --exclusive --ntasks=1 sleep 5
echo "Sleep exit code: $?"
