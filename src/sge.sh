#!/bin/bash

# Name of Job
#$ -N $folder

# Set Shell to be used to run the job
#$ -S /bin/bash

# Set the current working directory as the location of error and output files
# These files will show up as .e and .o files
#$ -cwd
#$ -o stdout/
#$ -e stderr/

# Select which queue to run in
#$ -q UI

# Select the number of slots the job will use
#$ -pe smp 21

#Print information from the job into the output file
/bin/echo Running on host: `hostname`.
/bin/echo In directory: `pwd`
/bin/echo Starting on: `date`

#Send e-mail at beginning/end/suspension of job
#$ -m bes

#E-mail address to send to
#$ -M [enter email here]

# Running main script
~/julia-d386e40c17/bin/julia main.jl $folder

/bin/echo Ending on: `date`