if getenv('SLURM_ARRAY_TASK_ID')
    idStr = getenv('SLURM_ARRAY_TASK_ID'); % get task ID string 
    fprintf('ID %s\n', idStr);
	arrayTaskID = str2num(idStr); % conv string to number
	pen = arrayTaskID; 
    thisJob = getenv('$SLURM_JOB_NAME');
else
    pen = 1;
end

if ismac 
    thisPathRoot = '/Users/ezavitz/Documents/data';
else
    thisPathRoot = '~/sz11/data/';
    addpath(genpath('~/code/utilities'))
    addpath(genpath('~/code/NPMK'))
    addpath(genpath('~/code/processSpikingMoveStim')) 
end

fPre = 'NEV'; % use this to prefix other versions of preprocessed data

allFiles = {'/CJ177/007', ...
            '/CJ177/008', ...
            '/CJ179/012', ...
            '/CJ179/013', ...
            '/CJ179/016', ...
            '/CJ190/001', ...
            '/CJ190/003', ...
            '/CJ191/002'};

fprintf('taskID: %s\n', allFiles{pen});

force = 1;

rootDir = [thisPathRoot allFiles{pen}];
fprintf('Array & Penetration ID: %s \n', allFiles{pen});

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

saveName = sprintf('%s%s%scombinedData.mat', rootDir, filesep, fPre);
if ~exist(saveName, 'file') || force
    [sTrain, onsetInds, StimFile] = combineDataNEVSpikes(rootDir, prefixes);
    fprintf('\n Saving %s \n', saveName);
    save(saveName, 'sTrain', 'onsetInds', 'StimFile',...
                   'param', 'chanOrder',  '-v7.3');
else 
    load(saveName);  
end

saveName = sprintf('%s%s%sfRates.mat', rootDir, filesep, fPre);
if ~exist(saveName, 'file') || force
    [tcs, Zscs, tcs_byFile] = ...
            getRatesScores_brain(param, sTrain, onsetInds, StimFile);
    fprintf('\n Saving %s \n', saveName);
    save(saveName, 'Zscs', 'tcs', 'tcs_byFile', 'chanOrder', 'param');
else 
    load(saveName);
end

saveName = sprintf('%s%s%sexclusions.mat', rootDir, filesep, fPre);
if ~exist(saveName, 'file') || force
    [OK] = getExclusions(tcs);
    fprintf('\n Saving %s \n', saveName);
    save(saveName, 'OK');
else
    load(saveName);
end