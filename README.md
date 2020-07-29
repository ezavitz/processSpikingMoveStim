# processSpikingMoveStim
Functions that create intermediate analysis files. This is meant to work on a file hierarchy compatible with marmolab-pipeline. 

It integrates: 
- kilosort cluster outputs and spike times
- digital event timing from NEV for stimulus synch
- information from Stim files (.mat)

It produces the following intermediate data files that are useful for further analysis. 

![Picture of how things fit together](workflow.jpg)
