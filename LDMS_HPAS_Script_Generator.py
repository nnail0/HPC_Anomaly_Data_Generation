#!/usr/bin/env python3

import argparse
import sys
import logging
import re

anom_dict = {"memleak":"ML",
             "memeater":"ME",
             "membw":"MB",
             "cpuoccupy":"CO",
             "netoccupy":"NO",
             "cachecopy":"CC",
             "iometadata":"IM",
             "iobandwidth":"IB"}

def main():
    """Generates an sbatch bash script that will create a dataset of metrics
    during the running of an application using the lightweight distributed
    metric system (LDMS) and anomalies from the HPC performance anomaly suite (HPAS)."""
    # Set up logging
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Parser for LDMS/HPAS script generator.")
    parser.add_argument("-s", "--sbatch", type=list[str],
                        help="sbatch arguments separated by commas, e.g., [\"--partition=local\",\"--nodes=1\",\"--time=30:00\",\"--exclusive\"]",
                        default=["--partition=local","--nodes=1","--time=30:00:00","--exclusive"])
    parser.add_argument("-n", "--name", type=str, help="name of application", required=True)
    parser.add_argument("-c", "--command", type=str, help="command to run application", required=True)
    parser.add_argument("-a", "--hpas_anomalies", type=list[str],
                        help="list of anomaly commands WITHOUT start times or durations, e.g., [\"cpuoccupy -u 95\",\"memleak -s 10M\",\"cachecopy -c L1 -m 0.8\"]",
                        default=["cpuoccupy -u 95","memleak -s 10M","cachecopy -c L1 -m 0.8","cachecopy -c L2 -m 0.8","cachecopy -c L3 -m 0.8"])
    parser.add_argument("-lsa", "--ldmsd_srun_args", type=str,
                        help="srun arguments for ldms daemons, e.g., \"--exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G\"",
                        default="--exclusive --ntasks-per-node=1 --cpus-per-task=1 --mem=1G")
    parser.add_argument("-hsa", "--hpas_srun_args", type=str,
                        help="srun arguments for hpas anomalies, e.g., \"--exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G\"",
                        default="--exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=1 --mem=20G")
    parser.add_argument("-asa", "--app_srun_args", type=str,
                        help="srun arguments for application, e.g., \"--exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G\"",
                        default="--exclusive --cpu-bind=verbose --ntasks-per-node=1 --cpus-per-task=8 --mem=20G")
    parser.add_argument("-w", "--wait", type=int, help="time between runs, in seconds")
    parser.add_argument("-m", "--multiple", type=str, help="run permutations with multiple anomalies: none, separate, overlapping, or both", default="both")

    args = parser.parse_args()

    logging.info("Starting to generate the script...")

    # Header with sbatch parameters
    script = "#!/bin/bash\n"
    script += "#SBATCH --job-name=" + args.name + "_LDMS_HPAS\n"
    for sbatch_arg in args.sbatch:
        script += "#SBATCH " + sbatch_arg + "\n"
    script += "\n"

    # Create "data" and "logs" directories if they don't exist
    script += "if [ -d \"data\" ]; then :; else mkdir data; fi\n"
    script += "if [ -d \"logs\" ]; then :; else mkdir logs; fi\n\n"

    # Run with no anomalies
    if args.wait:
        script += "sleep " + str(args.wait) + "\n"
    script += "echo \"" + args.name + "\"\n"
    script += "srun " + args.ldmsd_srun_args + " ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &\n"
    script += "LDMS_SAMPLER_PID=$!\n"
    script += "srun " + args.ldmsd_srun_args + " ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &\n"
    script += "LDMS_AGG_PID=$!\n"
    script += "APP_START_TIME=$(date +%s)\n"
    script += "srun " + args.app_srun_args + " " + args.command + "\n"
    script += "APP_END_TIME=$(date +%s)\n"
    script += "APP_DUR=$(($APP_END_TIME - $APP_START_TIME))\n"
    script += "kill $LDMS_AGG_PID\n"
    script += "kill $LDMS_SAMPLER_PID\n"
    script += "if (($APP_DUR < 60)); then\n" # If app doesn't run long enough, abort
    script += "  echo \"App duration less than 60 seconds - too short!\"\n"
    script += "  exit\n"
    script += "fi\n"
    script += "if [ -d \"dataset/" + args.name + "\" ]; then\n" # If plain run has already been done, discard generated data
    script += "  rm -r data\n"
    script += "  rm -r logs\n"
    script += "else\n"
    script += "  mkdir dataset/" + args.name + "\n"
    script += "  mv data dataset/" + args.name + "\n"
    script += "  mv logs dataset/" + args.name + "\n"
    script += "fi\n"
    script += "mkdir data\n"
    script += "mkdir logs\n\n"

    # Get anomaly abbreviations for use in directory names
    abbrevs = []
    for anom in args.hpas_anomalies:
        for entry in anom_dict:
            if anom.startswith(entry):
                abbrevs.append(anom_dict[entry])

    # Get anomaly parameters for use in directory names
    list_of_params = []
    for anom in args.hpas_anomalies:
        params = re.findall(r'[-](.) ([^ ]+)', anom)
        params_string = ""
        for param in params:
            params_string += "_" + param[0] + param[1]
        list_of_params.append(params_string)

    # Run with single anomalies
    for i in range(len(args.hpas_anomalies)):
        if args.wait:
            script += "sleep " + str(args.wait) + "\n"
        script += "echo \"" + args.name + "_" + abbrevs[i] + "\"\n"
        script += "ANOM_START_TIME=$(($APP_DUR / 12 + RANDOM % $APP_DUR / 6))\n" # calculate anomaly start and end times
        script += "ANOM_END_TIME=$(($APP_DUR * 7 / 12 + RANDOM % $APP_DUR / 6))\n"
        script += "srun " + args.ldmsd_srun_args + " ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &\n"
        script += "LDMS_SAMPLER_PID=$!\n"
        script += "srun " + args.ldmsd_srun_args + " ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &\n"
        script += "LDMS_AGG_PID=$!\n"
        script += "srun " + args.hpas_srun_args + " hpas " + args.hpas_anomalies[i] + " -t $ANOM_START_TIME -d $(($ANOM_END_TIME - $ANOM_START_TIME)) &\n"
        script += "ANOM_PID=$!\n"
        script += "srun " + args.app_srun_args + " " + args.command + "\n"
        script += "kill $LDMS_AGG_PID\n"
        script += "kill $LDMS_SAMPLER_PID\n"
        script += "if kill -0 $ANOM_PID &> /dev/null; then kill $ANOM_PID; fi\n"
        script += "if [ -d \"dataset/" + args.name + "_" + abbrevs[i] + "\" ]; then :; else mkdir dataset/" + args.name + "_" + abbrevs[i] + "; fi\n"
        script += "if [ -d \"dataset/" + args.name + "_" + abbrevs[i] + "/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}" + list_of_params[i] + "\" ]; then\n"
        script += "  rm -r data\n"
        script += "  rm -r logs\n"
        script += "else\n"
        script += "  mkdir dataset/" + args.name + "_" + abbrevs[i] + "/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}" + list_of_params[i] + "\n"
        script += "  mv data dataset/" + args.name + "_" + abbrevs[i] + "/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}" + list_of_params[i] + "\n"
        script += "  mv logs dataset/" + args.name + "_" + abbrevs[i] + "/ST${ANOM_START_TIME}_ET${ANOM_END_TIME}" + list_of_params[i] + "\n"
        script += "fi\n"
        script += "mkdir data\n"
        script += "mkdir logs\n\n"

    if args.multiple == "separate" or args.multiple == "both":
        # Run with two anomalies at separate times
        for i in range(len(args.hpas_anomalies)):
            for j in range(len(args.hpas_anomalies)):
                if args.wait:
                    script += "sleep " + str(args.wait) + "\n"
                script += "echo \"" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/separate\"\n"
                script += "ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))\n" # calculate anomaly start and end times
                script += "ANOM1_END_TIME=$(($APP_DUR * 4 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))\n"
                script += "ANOM2_START_TIME=$(($APP_DUR * 7 / 15 + RANDOM % $APP_DUR / 10))\n"
                script += "ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))\n"
                script += "srun " + args.ldmsd_srun_args + " ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &\n"
                script += "LDMS_SAMPLER_PID=$!\n"
                script += "srun " + args.ldmsd_srun_args + " ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &\n"
                script += "LDMS_AGG_PID=$!\n"
                script += "srun " + args.hpas_srun_args + " hpas " + args.hpas_anomalies[i] + " -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &\n"
                script += "ANOM1_PID=$!\n"
                script += "srun " + args.hpas_srun_args + " hpas " + args.hpas_anomalies[j] + " -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &\n"
                script += "ANOM2_PID=$!\n"
                script += "srun " + args.app_srun_args + " " + args.command + "\n"
                script += "kill $LDMS_AGG_PID\n"
                script += "kill $LDMS_SAMPLER_PID\n"
                script += "if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi\n"
                script += "if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi\n"
                script += "if [ -d \"dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "\" ]; then :; else mkdir dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "; fi\n"
                script += "if [ -d \"dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/separate\" ]; then :; else mkdir dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/separate; fi\n"
                script += "if [ -d \"dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}" + list_of_params[i] + "_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}" + list_of_params[j] + "\" ]; then\n"
                script += "  rm -r data\n"
                script += "  rm -r logs\n"
                script += "else\n"
                script += "  mkdir dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}" + list_of_params[i] + "_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}" + list_of_params[j] + "\n"
                script += "  mv data dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}" + list_of_params[i] + "_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}" + list_of_params[j] + "\n"
                script += "  mv logs dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/separate/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}" + list_of_params[i] + "_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}" + list_of_params[j] + "\n"
                script += "fi\n"
                script += "mkdir data\n"
                script += "mkdir logs\n\n"

    if args.multiple == "overlapping" or args.multiple == "both":
        # Run with two anomalies overlapping
        for i in range(len(args.hpas_anomalies)):
            for j in range(len(args.hpas_anomalies)):
                if args.wait:
                    script += "sleep " + str(args.wait) + "\n"
                script += "echo \"" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/overlaps\"\n"
                script += "ANOM1_START_TIME=$(($APP_DUR / 15 + RANDOM % $APP_DUR / 10))\n" # calculate anomaly start and end times
                script += "ANOM1_END_TIME=$(($APP_DUR * 8 / 15 + RANDOM % $APP_DUR / 10))\n"
                script += "ANOM2_START_TIME=$(($APP_DUR * 3 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))\n"
                script += "ANOM2_END_TIME=$(($APP_DUR * 10 / 15 + $APP_DUR / 60 + RANDOM % $APP_DUR / 10))\n"
                script += "srun " + args.ldmsd_srun_args + " ldmsd -x sock:10001 -l logs/sampler.log -c conf/sampler.conf &\n"
                script += "LDMS_SAMPLER_PID=$!\n"
                script += "srun " + args.ldmsd_srun_args + " ldmsd -x sock:20001 -l logs/aggregator.log -c conf/aggregator.conf &\n"
                script += "LDMS_AGG_PID=$!\n"
                script += "srun " + args.hpas_srun_args + " hpas " + args.hpas_anomalies[i] + " -t $ANOM1_START_TIME -d $(($ANOM1_END_TIME - $ANOM1_START_TIME)) &\n"
                script += "ANOM1_PID=$!\n"
                script += "srun " + args.hpas_srun_args + " hpas " + args.hpas_anomalies[j] + " -t $ANOM2_START_TIME -d $(($ANOM2_END_TIME - $ANOM2_START_TIME)) &\n"
                script += "ANOM2_PID=$!\n"
                script += "srun " + args.app_srun_args + " " + args.command + "\n"
                script += "kill $LDMS_AGG_PID\n"
                script += "kill $LDMS_SAMPLER_PID\n"
                script += "if kill -0 $ANOM1_PID &> /dev/null; then kill $ANOM1_PID; fi\n"
                script += "if kill -0 $ANOM2_PID &> /dev/null; then kill $ANOM2_PID; fi\n"
                script += "if [ -d \"dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "\" ]; then :; else mkdir dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "; fi\n"
                script += "if [ -d \"dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/overlaps\" ]; then :; else mkdir dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/overlaps; fi\n"
                script += "if [ -d \"dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}" + list_of_params[i] + "_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}" + list_of_params[j] + "\" ]; then\n"
                script += "  rm -r data\n"
                script += "  rm -r logs\n"
                script += "else\n"
                script += "  mkdir dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}" + list_of_params[i] + "_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}" + list_of_params[j] + "\n"
                script += "  mv data dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}" + list_of_params[i] + "_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}" + list_of_params[j] + "\n"
                script += "  mv logs dataset/" + args.name + "_" + abbrevs[i] + "_" + abbrevs[j] + "/overlaps/ST${ANOM1_START_TIME}_ET${ANOM1_END_TIME}" + list_of_params[i] + "_ST${ANOM2_START_TIME}_ET${ANOM2_END_TIME}" + list_of_params[j] + "\n"
                script += "fi\n"
                script += "mkdir data\n"
                script += "mkdir logs\n\n"

    with open (args.name + "_LDMS_HPAS.sh", "w") as script_file:
        script_file.write(script)

    logging.info("Script generated successfully.")
    
if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logging.error(f"An error occurred: {e}")
        sys.exit(1)
