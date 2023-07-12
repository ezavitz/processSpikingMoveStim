% setup paths for my laptop vs. on the cluster
if ismac 
    thisPathRoot = '~/Documents/code/ephys/corrStructure_V1MT/data';
    codeRoot = '~/Documents/code/';
    subdirs = {'ephys/', 'ephys/', 'ephys/', 'ephys/',...
               'marmolab/', 'marmolab/', 'marmolab/'};
else
    thisPathRoot = '~/om94_scratch/data';
    codeRoot = '~/code/';
    subdirs = {'', '', '', '', '', '', ''};
end

addpath(genpath([codeRoot subdirs{1} 'utilities']))
addpath(genpath([codeRoot subdirs{2} 'NPMK']))
addpath(genpath([codeRoot subdirs{3} 'processSpikingMoveStim'])) 
addpath(genpath([codeRoot subdirs{4} 'neurostim']))
addpath(genpath([codeRoot subdirs{5} 'marmodata'])) 
addpath(genpath([codeRoot subdirs{6} 'marmolab-stimuli'])) 
addpath(genpath([codeRoot subdirs{7} 'marmolab-common'])) 