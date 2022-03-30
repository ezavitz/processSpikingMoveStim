% setup paths for my laptop vs. on the cluster
if ismac 
    thisPathRoot = '/Users/ezavitz/Documents/code/corrStructure_V1MT/data';
    codeRoot = '~/Documents/code/';
else
    thisPathRoot = '~/sz11/data';
    codeRoot = '~/code/';
end

addpath(genpath([codeRoot 'utilities']))
addpath(genpath([codeRoot 'NPMK']))
addpath(genpath([codeRoot 'processSpikingMoveStim'])) 
