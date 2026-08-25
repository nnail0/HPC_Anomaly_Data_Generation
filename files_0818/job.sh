#!/bin/bash

export SUBSCRIBER_DATA='{"papi_sampler":{"file":"/home/narate/test/papi/papi.json"}}'

srun bash -c 'for X in {1..10}; do echo $X; sleep 1; done'

srun bash -c 'for X in {1..10}; do echo $X; sleep 1; done'
