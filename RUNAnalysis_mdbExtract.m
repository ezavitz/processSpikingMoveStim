clc
if ismac 
    cd('~/Documents/code/ephys/processSpikingMoveStim');
else
    cd('~/code/processSpikingMoveStim');
end

configureBatch_mdb; 

fPre = ''; % use this to prefix other versions of preprocessed data

force = 1;

prefixes = {'V1','MT'};

chanOrder{1} = 1:96; %to do -- make this a reshaped Utah channel 10x10 map
chanOrder{2} = [13 23 5 25 6 24 14 27 7 26 4 28 8 20 3 29 9 19 2 31 10 30 1 32 11 22 12 21 15 18 16 17];

% file is a cell array of penetrations with fields animalName, ID, Utah mapFile, etc.      
param.allTypes = {'Dots', 'SineWave', 'Square', 'PSsquare'}; 
param.windows = {'Move', 'Blank'}; 
param.window{1} = [50 550];
param.window{2} = [650 1000];
param.nTrialsSlowWin = 0; % number of trials over which to calculate the slow fluctuation of the mean
                           % set this to <= 0 to z-score over all trials at once.
% for SDFs
param.sWin = 1000; %SDF window size (ms)
param.sBin = 50;   %SDF boxcar size (ms)

tmp = split(allFiles{pen}, filesep);

saveName = sprintf('%s%s%scombinedData_%i.mat', rootDir, filesep, fPre, whichCh);

if ~exist(saveName, 'file') || force
    [sTrain, onsetInds, StimFile, chanOrder] = combineDataMarmolab(rootDir, param.allTypes, whichCh);

    fprintf('\n Saving %s \n', saveName);
    save(saveName, 'sTrain', 'onsetInds', 'StimFile', ...
                   'param', 'chanOrder', '-v7.3');
end

