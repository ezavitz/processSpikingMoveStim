% RUN_exportSpikeTimes 

if ismac 
    cd('/Users/ezavitz/Documents/code/corrStructure_V1MT');
else
    cd('~/code/corrStructure_V1MT');
end

configureBatch;

fPre = '';

for pen = 1:length(allFiles)
    rootDir = [thisPathRoot allFiles{pen}];
    
    tmp = split(allFiles{pen}, '/');
    pName = tmp{3};
    ani   = tmp{2}; 
    
    load([rootDir filesep fPre 'combinedData.mat']);  

    nFiles = length(sTrain);
    nAreas = length(chanOrder); 

    timeIncrement = zeros(1, nFiles+1);

    for area = 1:nAreas
        [nCh, ~] = size(sTrain{1}{area});
        spikeTimes{area} = cell(1, nCh); 
        stim{area}.onTimes   = []; 
        stim{area}.offTimes  = [];
        stim{area}.direction = [];
        stim{area}.type      = {}; 
        for file = 1:nFiles
            getTimes = sTrain{file}{area};
            [nCh, timeIncrement(file+1)] = size(getTimes);
            for ch = 1:nCh
                spikeTimes{area}{ch} = [spikeTimes{area}{ch} ...
                    find(getTimes(ch, :))+sum(timeIncrement(1:file))];
            end
            stim{area}.onTimes = [stim{area}.onTimes ...
                onsetInds{file}{area}(1,:)+sum(timeIncrement(1:file))];
            stim{area}.offTimes = [stim{area}.offTimes ...
                onsetInds{file}{area}(1,:)+sum(timeIncrement(1:file))+500];
            stim{area}.direction = [stim{area}.direction ...
                onsetInds{file}{area}(2,:)];
            stim{area}.type = [stim{area}.type ...
                StimFile{file}.type(onsetInds{file}{area}(4,:))];
        end
    end

    sFile = sprintf('%s_%s_spikeTimeExport.mat', ani, pName);
    save(['~/Desktop/' sFile], 'spikeTimes', 'stim', 'clustInfo', 'chanOrder');
end