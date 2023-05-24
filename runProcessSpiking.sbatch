#!/bin/bash
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-user=elizabeth.zavitz@monash.edu
#SBATCH --job-name=procSpike
#SBATCH --time=01:00:00
#SBATCH --ntasks=6
#SBATCH --mem=56320
#SBATCH --array=1-11

module load matlab
matlab -nodisplay -nojvm -nosplash < /home/earsenau/code/processSpikingMoveStim/RUNAnalysis_brain.m
