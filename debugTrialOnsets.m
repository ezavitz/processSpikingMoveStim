rootDir = '~/om94/data/CJ223/004';

tmp = split(rootDir, filesep); % get the animal mame
expression = sprintf('%s\\.motionStim\\.[0-9]{6}\\.mat', tmp{end-1});

% get a list of the neurostim files that are part of this penetration
fileList = getFileListFromDirs([rootDir filesep], expression);
cfg = 'marmodata.cfgs.acute.H64FlexiH64FlexiIntan';
%
for fileID = 1:3
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
 cla
 stats =[];
for iFile = 1:3%length(sc)
    oriL = unique(oris{iFile});
    stats = [stats; length(sc{iFile}) max(sc{iFile})];
        lengthDiff =  length(sc{iFile}) - length(oris{iFile});
        if lengthDiff
            subSC = sc{iFile}(1:end-lengthDiff);
        else
           subSC = sc{iFile};
        end
        size(subSC)
    tc = zeros(1, length(oriL));
    for oi = 1:length(oriL)
        theseTrials = oris{iFile} == oriL(oi);
        tc(oi) = mean(subSC(theseTrials));
    end

    plot(tc); hold on;
    
end
stats