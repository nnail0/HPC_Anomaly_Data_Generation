# HPC-Anomaly-Data-Generation

## Background

### LDMS (Lightweight Distributed Metric System)

LDMS samples a system's metrics and records them.  This project uses LDMS to generate data using the "meminfo", "vmstat", and "procstat" plugins, but could be adjusted to use others.  Here are some resources for using it:
 - [LDMS Github](https://github.com/ovis-hpc/ldms)
 - [LDMS Documentation](https://ovis-hpc.readthedocs.io/en/latest/)
    - [LDMS Quick Start](https://ovis-hpc.readthedocs.io/projects/ldms/en/latest/intro/quick-start.html)
    - [LDMS Tutorial Slides](https://sites.google.com/view/ldmscon2024/tutorials/tutorial-slides)

### HPAS (HPC Performance Anomaly Suite)

HPAS contains anomalies that can be executed while an application runs to simulate anomalous behavior.  This project gathers data while an application runs alongside one or more anomalies to see how they affect the system metrics.  This project only uses "cpuoccupy", "memleak", and "cachecopy", but could be adapted to use others.  Here are some resources for using HPAS:
 - [HPAS Github](https://github.com/peaclab/HPAS)
 - Note: once installed, `hpas -h` will show a list of the available anomalies, and `hpas <anomaly_name> -h` will show the usage for a specific anomaly.

### Proxy Apps

While generating data, this project runs proxy apps, which are simplified codes that emulate features or the behavior of larger code bases.  This project only generated data using "ExaMiniMD" and "SW4lite", but is intended to work with any application.  Here are some resources for installing and using proxy apps:
 - [Exascale Computing Project - Proxy Apps Suite](https://proxyapps.exascaleproject.org/)
 - [ExaMiniMD](https://proxyapps.exascaleproject.org/app/examinimd/)
 - [SW4lite](https://proxyapps.exascaleproject.org/app/sw4lite/)

## Data Generation Scripts

`LDMS_HPAS_Script_Generator.py` takes arguments specifying the details and parameters of the data generation, and creates a Slurm sbatch script that will generate the data.  The default values are set to work for a single node CPU (60G RAM, 1 socket, 10 cores per socket, and 2 threads per core) but by adjusting the sbatch arguments and srun arguments for the LDMS daemons, the HPAS anomalies, and the application, the script should work for any system in the way desired.
 - Note: run `python LDMS_HPAS_Script_Generator.py -h` to see available parameters and their descriptions/formats.

By default, the script generator will gather data for a run of the application without any anomalies, a run of the application for each single anomaly provided to the `--hpas_anomalies` option, and two runs of the application for each possible combination of two anomalies - one with the two not overlapping (separate), and one with the two overlapping.  Fewer permutations may be specified by setting the `--multiple` option to "none", "separate", or "overlapping".

During each run, the anomalies will start at randomized times within certain time windows so that ML models analyzing the data won't assume the anomalies always start at the exact same time.

## The Data

The generated data is moved to the `dataset` directory and stored in folders based on which anomalies occurred during the run, whether they were seperate or overlapping, and their parameters (start and end times, as well as other parameters provided like cpuoccupy utilization or memleak size).  Anomalies are abbreviated (cpuoccupy as CO, memleak as ML, cachecopy as CC).  For example, an ExaMiniMD run where a `cpuoccupy -u 95` anomaly started at t=10 and ended at t=120, and a `cachecopy -c L1 -m 0.8` anomaly started at t=240 and ended at t=360, the results would be in `dataset/ExaMiniMD_CO_CC/separate/ST10_ET120_u95_ST240_ET360_cL1_m0.8`.

## Notebook for Reading/Plotting Data

The Jupyter Notebook `plot_data.ipynb` is a simple program to visualize the data.  Changing the values of the variables "application", "anom1", "anom1_params", "anom2", "anom2_params", "metric", and "norm" will change which data you visualize, and how you visualize it.
