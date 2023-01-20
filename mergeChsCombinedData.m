configureBatch; 
configurePaths;

dataDir = sprintf('%s%s%s', thisPathRoot, allFiles{pen}, filesep);
fileNames = getFileListFromDirs(dataDir, 'combinedData_P[0-9]*_Ch[0-9]*\.mat');

nCh = length(fileNames); 
whichCh = 1; %make for loop

areaBreak = 64; 

sTrainAll = cell(1,4); 

aInd = 1; nChTot = min(areaBreak, nCh);
chInd = 1; 
for iCh = 1:nCh
    filename = sprintf('combinedData_P%i_Ch%i.mat', pen, iCh);
    fprintf('Loading %s \n', filename); 
    load([dataDir filename])

    if iCh == 1 || iCh == areaBreak+1 %if this is the first V1 or MT channel
        for subfile = 1:length(sTrain)
            if iCh == 1
                sTrainAll{subfile} = cell(1,2); 
            end
            sTrainAll{subfile}{aInd} = ... %initialise
                zeros(nChTot, size(sTrain{subfile}{1}, 2)); 
        end
    end

    % copy over the spiking data
    for subfile = 1:length(sTrain)
        sTrainAll{subfile}{aInd}(chInd, :) = ...
            sTrain{subfile}{1};
    end

    chInd = chInd + 1;
    
    if iCh == areaBreak
        aInd  = 2;
        chInd = 1; 
    end
end

clear sTrain 
sTrain = sTrainAll;
clear sTrainAll
%%
save([dataDir 'combinedData.mat'], ...
    'sTrain', 'onsetInds', 'StimFile', 'param',  '-v7.3');