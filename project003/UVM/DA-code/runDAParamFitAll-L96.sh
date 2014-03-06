#!/bin/bash

# need these for compiled matlabs jobs
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/gpfs1/arch/x86_64/matlab2010a/bin/glnxa64:/gpfs1/arch/x86_64/matlab2010a/runtime/glnxa64:/gpfs1/arch/x86_64/matlab2010a/sys/os/glnxa64:/gpfs1/arch/x86_64/matlab2010a/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:/gpfs1/arch/x86_64/matlab2010a/sys/java/jre/glnxa64/jre/lib/amd64/server:/gpfs1/arch/x86_64/matlab2010a/sys/java/jre/glnxa64/jre/lib/amd64/client:/gpfs1/arch/x86_64/matlab2010a/sys/java/jre/glnxa64/jre/lib/amd64
export XAPPLRESDIR=/gpfs1/arch/x86_64/matlab2010a/X11/app-defaults

cd /users/a/r/areagan/class/2013/MCRN501/project003/UVM/DA-code

####################################
##        SINGLE EXPERIMENT       ##
####################################

# export EXPCOUNT=1 ## will run through 5 experiments
# ## tunable parameters
# export NUMRUNS=2
# export RUNTIME=100
# ## part of experiment
# export OBSERROR=0.05
# export ERRORDIST="normal"
# export SUBSAMPLEALPHA=1
# export DIMENSION=10
# qsub -q workq -V runL96.qsub

#####################################
##       FULL EXPERIMENT           ##
#####################################

## tunable parameters
export NUMRUNS=20
export RUNTIME=100

## for normal error
ERRORDIST="normal"
export ERRORDIST
for EXPCOUNT in 4 5
do
  export EXPCOUNT
  for OBSERROR in 0 0.01 0.05 0.1 0.25 0.5 1 2
  do
    export OBSERROR
    for SUBSAMPLEALPHA in 1 5 25 50
    do
      export SUBSAMPLEALPHA
      for DIMENSION in 4 8 10 15
      do
	export DIMENSION
	# data/L96_normal_0.5_20_100_1_4_2_forecastEnds.csv
  	FILENAME="data/L96_${ERRORDIST}_${OBSERROR}_${NUMRUNS}_${RUNTIME}_${SUBSAMPLEALPHA}_${DIMENSION}_${EXPCOUNT}_forecastEnds.csv"
  	# echo $FILENAME
  	if [ -f $FILENAME ]; then
  	  echo "already done"
  	else
          echo "$FILENAME not done"
  	  qsub -q workq -V runL96.qsub
  	fi
      done
    done
  done
done

## for uniform error
ERRORDIST="uniform"
export ERRORDIST
for EXPCOUNT in 4 5
do
  export EXPCOUNT
  for OBSERROR in 0 0.5 2 4 6 8 10
  do
    export OBSERROR
    for SUBSAMPLEALPHA in 1 5 25 50
    do
      export SUBSAMPLEALPHA
      for DIMENSION in 4 8 10 15
      do
	export DIMENSION
  	FILENAME="data/L96_${ERRORDIST}_${OBSERROR}_${NUMRUNS}_${RUNTIME}_${SUBSAMPLEALPHA}_${DIMENSION}_${EXPCOUNT}_forecastEnds.csv"
  	# echo $FILENAME
  	if [ -f $FILENAME ]; then
  	  echo "already done"
  	else
          echo "$FILENAME not done"
  	  qsub -q workq -V runL96.qsub
  	fi
      done
    done
  done
done
  
  
  
  
  
  
  
  
  
  
  
  
  
  
