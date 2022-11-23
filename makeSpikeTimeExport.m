% select valid units 
% clustInfo{area}.isUnit 

% then, select units that are visually responsive
% OK.anyVisual{area}

ani = 'CJ191'; 
pen = '002';

proot = sprintf('/Users/ezavitz/Documents/data/%s/%s/', ani, pen); 

load([proot 'combinedData.mat'])
load([proot 'exclusions.mat'])

nFiles = length(sTrain);
nAreas = length(chanOrder); 

timeIncrement = zeros(1, nFiles+1);

for area = 1:nAreas
    nCh = sum(OK.anyVisual{area});
    spikeTimes{area} = cell(1, nCh); 
    stim{area}.onTimes   = []; 
    stim{area}.offTimes  = [];
    stim{area}.direction = [];
    stim{area}.type      = {}; 
    for file = 1:nFiles
        getTimes = sTrain{file}{area}(OK.anyVisual{area}, :);
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

sFile = sprintf('%s_%s_spikeTimeExport.mat', ani, pen);
save(['~/Desktop/' sFile], 'spikeTimes', 'stim');