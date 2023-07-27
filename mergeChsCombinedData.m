% when data has been processed with spiking from each channel in a separate
% file, these need to be combined into one file with the appropriate data
% structures. 
function [sTrain, onsetInds, StimFile, param] = mergeChsCombinedData(rootDir)

configurePaths;

dataDir = [rootDir filesep]; %sprintf('%s%s%s', thisPathRoot, allFiles{pen}, filesep);
fileNames = getFileListFromDirs(dataDir, 'combinedData_[0-9]+\.mat');

nCh = length(fileNames);
chNums = sort(cellfun(@(x) str2double(extractBefore(x(14:end),'.')), fileNames)); 

areaBreak = 64; % what channel is the last channel in V1?
nChTot = min(areaBreak, nCh);

% these increment in loop 
aInd = 1; 
chInd = 1; 

for iCh = 1:nCh
    % load the data
    filename = sprintf('combinedData_%i.mat', chNums(iCh));
    fprintf('Loading %s \n', filename); 
    load([dataDir filename])
    
    % initialise the data structures
    if iCh == 1 || iCh == areaBreak+1 %if this is the first V1 or MT channel
        for subfile = 1:length(sTrain) % data is broken across multiple recordings
            if iCh == 1
                sTrainAll{subfile} = cell(1,2);
            end
            maxSize(subfile) = max(onsetInds{subfile}{aInd}(1, :))+4500;
            sTrainAll{subfile}{aInd} = ... %initialise
                zeros(nChTot, maxSize(subfile)); 
        end
    end

    % copy over the spiking data
    for subfile = 1:length(sTrain)
        sTrainAll{subfile}{aInd}(chInd, :) = ...
            sTrain{subfile}{1}(1:maxSize(subfile));
    end

    % increment counters
    chInd = chInd + 1;
    
    if iCh == areaBreak
        aInd  = 2;
        chInd = 1; 
    end
end

sTrain = sTrainAll;


