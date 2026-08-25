#!/bin/bash

ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf -r $HOME/ldmsd_sampler.pid -v DEBUG
echo $?
