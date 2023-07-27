if ismac 
    cd('~/Documents/code/ephys/processSpikingMoveStim');
else
    cd('~/code/processSpikingMoveStim');
end

configureBatch; 

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

saveName = sprintf('%s%s%scombinedData.mat', rootDir, filesep, fPre);

chByCh = getFileListFromDirs(rootDir,'combinedData_[0-9]+\.mat');

if ~exist(saveName, 'file') || force
    if str2double(tmp{2}(3:end)) < 200 % if we're in the old data set (i.e. < CJ200)
        [sTrain, onsetInds, StimFile, clustInfo] = combineData(rootDir, prefixes);
        fprintf('\n Saving %s \n', saveName);
        save(saveName, 'sTrain', 'onsetInds', 'StimFile',...
                       'param', 'chanOrder', 'clustInfo',  '-v7.3');
    else % we are in the new dataset of neurostim/marmolab
        if isempty(chByCh) % if there's also no channel-by-channel data
            error('no data to combine!')
        else
            [sTrain, onsetInds, StimFile, param] = mergeChsCombinedData(rootDir, prefixes);
            clustInfo = [];
            save(saveName, 'sTrain', 'onsetInds', 'StimFile',...
                       'param', 'chanOrder', 'clustInfo',  '-v7.3');
        end
    end
else
    fprintf('%s already exists.\n', saveName);
    load(saveName, 'param', 'sTrain', 'onsetInds', 'StimFile');  
end

saveName = sprintf('%s%s%sfRates.mat', rootDir, filesep, fPre);
if ~exist(saveName, 'file') || force
    [tcs, Zscs, tcs_byFile] = ...
            getRatesScores_brain(param, sTrain, onsetInds, StimFile);
    fprintf('\n Saving %s \n', saveName);
    save(saveName, 'Zscs', 'tcs', 'tcs_byFile', 'chanOrder', 'param');
else
    fprintf('%s already exists.\n', saveName);
    load(saveName, 'tcs');
end

saveName = sprintf('%s%s%sSDFs.mat', rootDir, filesep, fPre);
if ~exist(saveName, 'file') || force
    [all_sdfs] = getSDF_brain(param, sTrain, onsetInds, StimFile);
    fprintf('\n Saving %s \n', saveName);
    save(saveName, 'all_sdfs', 'param', '-v7.3');
else
    fprintf('%s already exists.\n', saveName); 
end

saveName = sprintf('%s%s%sexclusions.mat', rootDir, filesep, fPre);
if ~exist(saveName, 'file') || force
    [OK] = getExclusions(tcs);
    fprintf('\n Saving %s \n', saveName);
    save(saveName, 'OK');
else
    fprintf('%s already exists.\n', saveName);
end