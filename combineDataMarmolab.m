function [sTrain, onsetInds, StimFile, chanOrder] = ...
    combineDataMarmolab(rootDir, allTypes)
    
    clc;
    tmp = split(rootDir, filesep); % get the animal mame
    expression = sprintf('%s\\.motionStim\\.[0-9]{6}\\.mat', tmp{end-1});

    % get a list of the neurostim files that are part of this penetration
    fileList = getFileListFromDirs([rootDir filesep], expression);
    cfg = 'marmodata.cfgs.acute.H64FlexiH64FlexiIntan';

for iFile = 1:length(fileList)
    
    d = marmodata.mdbase([rootDir filesep fileList{iFile}],'loadArgs', ...
    {'loadEye',false,'spikes',true,'source','ghetto', ...
    'reload',true,'channels',[1 2],'useCAR',false}); %% need to remove channels argument to process all
    
    % CREATE ONSET INDS
    % load neurostim file
    load([rootDir filesep fileList{iFile}], 'c'); 
    
    oris = get(c.nWave.prms.orientation, 'atTrialTime', Inf)';
    contrast = get(c.nWave.prms.contrast, 'atTrialTime', Inf)';
    types = get(c.nWave.prms.type, 'atTrialTime', Inf)';
    typeMat = cell2mat(cellfun(@(x) find(strcmpi(allTypes, x)), types, 'UniformOutput', false)); 
    times = round(d.meta.cic.firstFrame.time*1000); 
    times = times-times(1)+1; 
    tmp = [times; oris; contrast; typeMat]; 
    onsetInds{iFile}{1} = tmp; onsetInds{iFile}{2} = tmp; %for backwards compatibility with V1/MT recordings on different systems
    
    % CREATE SPIKE TRAIN
    % preallocate
    sTrain = zeros(d.spikes.numChannels, times(end)+5000);
    for iCh = 1:d.spikes.numChannels
        for iTrial = 1:length(times)
            sTimes = round(d.spikes.spk{1,iTrial,iCh}*1000 + times(iTrial));
            sTrain(iCh, sTimes) = 1;
        end
    end
end

% reconstruct stim file?
StimFile = []; 

% figure out channel map?
chanOrder = [];