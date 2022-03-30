% root dir: directory that contains data for this batch
% prefixes: batch prefixes, i.e. {'MT', 'V1'}

function [sTrain, onsetInds, StimFile, clusters, sortInfo] = ...
    combineData(rootDir, prefixes, ksFlag)

    tmp = split(rootDir, filesep);
    batch  = tmp{end};
    
    if nargin < 3 % if there's no request for sort data, don't include it
        ksFlag = 0;
        sortInfo = [];
    end

for a = 1:length(prefixes)
    fprintf('\nProcessing Recordings from %s :', prefixes{a})
    
    pathRoot = [rootDir filesep prefixes{a} '-' batch filesep];
    fileList = getFileListFromDirs(pathRoot, '[0-9][0-9][0-9]');
        
    % LOAD (ONE BATCH)
    clust.clusterInfo = readmatrix([pathRoot 'kilosort2/cluster_info.tsv'], 'FileType', 'Text', 'OutputType', 'string');
    clust.index = 1:size(clust.clusterInfo,1);

    clust.isUnit = clust.clusterInfo(:,9) == 'good' | ...
                   clust.clusterInfo(:,9) == 'mua';
    clust.isSU   = clust.clusterInfo(:,9) == 'good';
    clust.ch     = clust.clusterInfo(clust.isUnit, 6); 
    clusters{a} = clust; 
    
    for f = 1:length(fileList)
        fprintf(' %s ', fileList{f})
        fileNum = fileList{f};
        % LOAD EVERYTHING (ONE PARTICULAR FILE)
        % ------- load NEV 
        nFile = dir([pathRoot fileNum filesep '*.nev']);
        nevData = openNEV([nFile.folder filesep nFile.name], 'read', 'nosave');
        clear nFile;
        % ------- load metadata
        fid = fopen([pathRoot fileNum filesep 'ephys.json']);
        metastrings = textscan(fid, '%s');
        fclose(fid);

        metadata = jsondecode([metastrings{1}{:}]);
        clear fid metastrings;
        % ------- load stimulus information
        sFile = dir([rootDir filesep fileNum filesep '*.mat']);
        stimData = load([sFile.folder filesep sFile.name]);
        clear sFile;
        % ------- load spike times + cluster IDs
        spike.times   = readNPY([pathRoot fileNum filesep 'kilosort2/spike_times.npy']); % in samples
        spike.cluster = readNPY([pathRoot fileNum filesep 'kilosort2/spike_clusters.npy']);
        spike.amp     = readNPY([pathRoot fileNum filesep 'kilosort2/amplitudes.npy']);
        
        % GET TIMING INTO MS
        % ------- stimulus onsets
        [onsetTimes] = NevDatatoStimOnsets(nevData);
        % if the number of blanks and the number of moves are the same as the
        % planned number of trials we've won! 

        blanksGood = length(onsetTimes.blank) == stimData.Stim.nTrials;
        movesGood  = length(onsetTimes.move) == stimData.Stim.nTrials;

        if ~(blanksGood && movesGood)
            if blanksGood % try to use a good one
                onsetTimes.move = onsetTimes.blank - ...
                    stimData.Stim.tMove*1000;
            elseif movesGood
                onsetTimes.blank = onsetTimes.move + ...
                    stimData.Stim.tBlank*1000;
            elseif length(onsetTimes.blank) < stimData.Stim.nTrials && ...
                   length(onsetTimes.move) < stimData.Stim.nTrials
                    warning('Too few trials (found %i) - maybe early abort?', ...
                        length(onsetTimes.move));
            end
        end
        clear blanksGood movesGood

        % ------- SPIKING EVENTS
        % correct sample times for recording skips. 
        nSegments = length(metadata.timestamps);
        if nSegments == 1
            spike.times = spike.times + uint64(metadata.timestamps);
        else
            totSamps = 0;
            nSamps = [0; metadata.samples];
            for seg = 1:length(nSamps)-1
               totSamps = totSamps + nSamps(seg);
               sampLoss = metadata.timestamps(seg)-totSamps;
               thisBlock = spike.times > nSamps(seg);
               if seg > 1
                fprintf('\nLost %i samples, incrementing subsequent spike times.', sampLoss);
                    spike.times(thisBlock) = ...  
                    spike.times(thisBlock) + uint64(sampLoss);
               end
            end
        end
        spike.ms = double(spike.times)/metadata.sampleRate*1000;

        % make that spike train
        getUnits = ismember(spike.cluster, clust.index(clust.isUnit));
        sTrain{f}{a} = buildSpikeTrain(spike.ms(getUnits), spike.cluster(getUnits), 1000, clust.index(clust.isUnit)); 
        isSU{a}      = ismember(clust.index(clust.isUnit), clust.index(clust.isSU)); % logical index to SU clusters
        % ------- STIMULUS EVENTS
        permFields = fieldnames(stimData.Stim.trials); % get the kinds of things the stimulus varied.
        nFields = length(permFields);
        nTrialsActual = length(onsetTimes.move); 

        onsetInds{f}{a} = zeros(nFields+1, nTrialsActual);
        onsetInds{f}{a}(1, :) = ceil(onsetTimes.move); 

        for param = 1:nFields
            onsetInds{f}{a}(param+1, :) = ...
                stimData.Stim.trials.(permFields{param})(1:nTrialsActual);
        end
        
        StimFile{f}   = stimData.Stim;
        
        if ksFlag
            sortInfo{f,a}.useClusters = clust.index(clust.isUnit);
            sortInfo{f,a}.sTimes      = spike.ms;
            sortInfo{f,a}.amps        = spike.amp;
            sortInfo{f,a}.cluster     = spike.cluster;
        end
    end
end