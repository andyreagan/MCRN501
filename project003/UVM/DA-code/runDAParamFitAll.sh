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
C=40
D=10
E=20
SEED=100
for B in 32 100 1000 2000 5000 10000 20000 40000
do
  qsub -v NUMTSENSORS="$B",NUMWINDOWS="$C",WINDOWLEN="$D",NUMENS="$E",COUNTER="$SEED" run.qsub
done



