function [sTrain, onsetInds, StimFile, chanOrder] = ...
    combineDataMarmolab(rootDir, allTypes, whichCh)
    
    tmp = split(rootDir, filesep); % get the animal mame
    expression = sprintf('%s\\.motionStim\\.[0-9]{6}\\.mat', tmp{end-1});
    penetration = sprintf('%s/%s', tmp{7}, tmp{8});

    % get a list of the neurostim files that are part of this penetration
    fileList = getFileListFromDirs([rootDir filesep], expression);
     aSplit = 64; % what channel to split to next area

    % some recordings need different headstage/electrode configurations 
    switch penetration 
        case 'CJ221/001'
            cfg = 'marmodata.cfgs.acute.H64FlexiH64FlexiIntan_NoPortC';
        otherwise
            cfg = 'marmodata.cfgs.acute.H64FlexiH64FlexiIntan';
    end
    
for iFile = 1:length(fileList)
    
    % marmodata lets you load channels willy-nilly but this will produce
    % unreliable output (you won't know what channels are in which brain
    % areas) if you don't provide a consecutive list of channels to load. 
    d = marmodata.mdbase([rootDir filesep fileList{iFile}],'loadArgs', ...
    {'loadEye',false,'spikes',true,'source','ghetto', ...
    'reload',true, 'channels', whichCh, 'useCAR',false, ...
      'cfg', cfg, 'ephys', 'neurostim.plugins.intan'}); %% need to remove channels argument to process all
    %, 'ephys', 'neurostim.plugins.intan'
    
    % CREATE ONSET INDS
    % load neurostim file
    load([rootDir filesep fileList{iFile}], 'c'); 
    
    oris = get(c.nWave.prms.orientation, 'atTrialTime', Inf)';
    contrast = get(c.nWave.prms.contrast, 'atTrialTime', Inf)';
    types = get(c.nWave.prms.type, 'atTrialTime', Inf)';
    typeMat = cell2mat(cellfun(@(x) find(strcmpi(allTypes, x)), types, 'UniformOutput', false)); 
    times = round(d.meta.cic.firstFrame.time*1000); 
    times = times-times(1)+1; 
    tmp = [times; oris; contrast; typeMat-1]; %1 is a magic number here for compatibility 
    onsetInds{iFile}{1} = tmp; onsetInds{iFile}{2} = tmp; %for backwards compatibility with V1/MT recordings on different systems
    % CREATE SPIKE TRAIN
    % preallocate
    
    % do some bookkeeping for separate sets of spike trains for separate
    % areas:
    nCh = min(d.spikes.numChannels, aSplit); % number of channels is either number asked for, 
                                             % or number in area1, whichever is smaller
    aInd = 1; offset = 0; % set the index for the area, and the iCh offset for area1.
    sTrain{iFile}{aInd} = zeros(nCh, times(end)+5000); % preallocate with a 5sec buffer
    
    for iCh = 1:d.spikes.numChannels
        if iCh > aSplit % if we're into the second area
            aInd = aInd + 1;                    % increment area index
            nCh = d.spikes.numChannels-aSplit;  % reset the number of channels
            offset = aSplit;                    % reset the offset (so we're back at channel 1)
            sTrain{iFile}{aInd} = zeros(nCh, times(end)+5000); % preallocate as before
        end
        
        for iTrial = 1:length(times)
            sTimes = round(d.spikes.spk{1,iTrial,iCh}*1000 + times(iTrial));
            sTrain{iFile}{aInd}(iCh, sTimes) = 1;
        end
    end
    
    % CREATE StimFile (for compatibility with non-neurostim based code)
    StimFile{iFile}.testList = unique(oris); 
    StimFile{iFile}.type = allTypes(unique(typeMat));
end

% figure out channel map?
chanOrder = [];