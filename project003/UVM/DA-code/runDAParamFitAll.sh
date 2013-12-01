#!/bin/bash

# need these for compiled matlabs jobs
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/gpfs1/arch/x86_64/matlab2010a/bin/glnxa64:/gpfs1/arch/x86_64/matlab2010a/runtime/glnxa64:/gpfs1/arch/x86_64/matlab2010a/sys/os/glnxa64:/gpfs1/arch/x86_64/matlab2010a/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:/gpfs1/arch/x86_64/matlab2010a/sys/java/jre/glnxa64/jre/lib/amd64/server:/gpfs1/arch/x86_64/matlab2010a/sys/java/jre/glnxa64/jre/lib/amd64/client:/gpfs1/arch/x86_64/matlab2010a/sys/java/jre/glnxa64/jre/lib/amd64
export XAPPLRESDIR=/gpfs1/arch/x86_64/matlab2010a/X11/app-defaults

cd /users/a/r/areagan/class/2013/MCRN501/project003/UVM/DA-code

# ## for a single test (always find something wrong)
# EXPCOUNT=1 ## will run through 5 experiments
# ## tunable parameters
# NUMRUNS=100
# RUNTIME=200
# ## part of experiment
# OBSERROR=0.05
# ERRORDIST="normal" #"uniform"
# SUBSAMPLEALPHA=1
# RHO=28
# OBSVAR=3
# qsub -v NUMRUNS,RUNTIME,OBSERROR,ERRORDIST,SUBSAMPLEALPHA,RHO,OBSVAR,EXPCOUNT run.qsub

## tunable parameters
export NUMRUNS=100
export RUNTIME=200
## part of experiment
export RHO=22
## for normal error
ERRORDIST="normal"
export ERRORDIST
for EXPCOUNT in {1..5} ## will run through 5 experiments
do
  export EXPCOUNT
  for OBSERROR in 0 0.01 0.05 0.1 0.25 0.5 1 2
  do
    export OBSERROR
    for SUBSAMPLEALPHA in 1 5 25 50
    do
      export SUBSAMPLEALPHA
      for OBSVAR in 1 3
      do
	export OBSVAR
	qsub -q shortq -V run.qsub
      done
    done
  done
done
## for uniform error
ERRORDIST="uniform"
export ERRORDIST
for EXPCOUNT in {1..5} ## will run through 5 experiments
do
  export EXPCOUNT
  for OBSERROR in 0 0.5 2 4 6 8 10
  do
    export OBSERROR
    for SUBSAMPLEALPHA in 1 5 25 50
    do
      export SUBSAMPLEALPHA
      for OBSVAR in 1 3
      do
	export OBSVAR
	qsub -q shortq -V run.qsub
      done
    done
  done
done
