#!/bin/bash

# need these for compiled matlabs jobs
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/gpfs1/arch/x86_64/matlab2010a/bin/glnxa64:/gpfs1/arch/x86_64/matlab2010a/runtime/glnxa64:/gpfs1/arch/x86_64/matlab2010a/sys/os/glnxa64:/gpfs1/arch/x86_64/matlab2010a/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:/gpfs1/arch/x86_64/matlab2010a/sys/java/jre/glnxa64/jre/lib/amd64/server:/gpfs1/arch/x86_64/matlab2010a/sys/java/jre/glnxa64/jre/lib/amd64/client:/gpfs1/arch/x86_64/matlab2010a/sys/java/jre/glnxa64/jre/lib/amd64
export XAPPLRESDIR=/gpfs1/arch/x86_64/matlab2010a/X11/app-defaults

cd /users/a/r/areagan/work/2013/data-assimilation/src/experiments/openFoamAssimilation

# C=40
# SEED=0
# for B in 2 4 8 16 32 
# do
#   for D in 10 20 30
#   do
#     for E in 2 3 5 10 20
#     do
#       echo $B $C $D $E
#       qsub -v NUMTSENSORS="$B",NUMWINDOWS="$C",WINDOWLEN="$D",NUMENS="$E",COUNTER="$SEED" runFullModelLocalZones.qsub
#       SEED=$(($SEED+1))
#     done
#   done
# done

## for a single test (always find something wrong)
EXPCOUNT=1
## tunable parameters
NUMRUNS=1
RUNTIME=200

## part of experiment
OBSERROR=0.05
ERRORDIST="normal"
SUBSAMPLEALPHA=1
RHO=28
OBSVAR=3
qsub -v NUMRUNS,RUNTIME,OBSERROR,ERRORDIST,SUBSAMPLEALPHA,RHO,OBSVAR,EXPCOUNT run.qsub




