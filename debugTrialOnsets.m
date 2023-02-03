rootDir = '~/om94/data/CJ223/003';

tmp = split(rootDir, filesep); % get the animal mame
expression = sprintf('%s\\.motionStim\\.[0-9]{6}\\.mat', tmp{end-1});

% get a list of the neurostim files that are part of this penetration
fileList = getFileListFromDirs([rootDir filesep], expression);
cfg = 'marmodata.cfgs.acute.H64FlexiH64FlexiIntan';
%
for fileID = 1:4
    fprintf('File %i \n', fileID);
    d{fileID} = marmodata.mdbase([rootDir filesep fileList{fileID}],'loadArgs', ...
    {'loadEye',false,'spikes',true,'source','ghetto', ...
    'reload',true, 'channels', 66, 'useCAR',false}); %% need to remove channels argument to process all

    load([rootDir filesep fileList{fileID}], 'c'); 
    oris{fileID} = get(c.nWave.prms.orientation, 'atTrialTime', Inf)';
    
    sc{fileID} = zeros(1, length(d{fileID}.spikes.spk)); 
    for iTrial = 1:length(d{fileID}.spikes.spk)
        sc{fileID}(iTrial) = sum(d{fileID}.spikes.spk{iTrial}(d{fileID}.spikes.spk{iTrial} < 0.55));
    end
end




%%
 
for iFile = 1:length(sc)
    oriL = unique(oris{iFile});
        if length(sc{iFile}) > length(oris{iFile})
            subSC = sc{iFile}(2:end);
        else
           subSC = sc{iFile};
        end
    tc = zeros(1, length(oriL));
    for oi = 1:length(oriL)
        theseTrials = oris{iFile} == oriL(oi);
        tc(oi) = mean(subSC(theseTrials));
    end

    plot(tc); hold on;
end