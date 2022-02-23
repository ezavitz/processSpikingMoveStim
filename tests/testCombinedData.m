clear; clc;
configureBatch;

% Find and load combined data
dataFile = sprintf('%s%s%s', rootDir, filesep, 'combinedData.mat');
assert(exist(dataFile, 'file'), [dataFile ' not found']);
load(dataFile);

% Does the chanOrder = the number of units (if not KS)
fprintf('TESTING: chanOrder. Are maps consistent with spike train? \n'); 
if exist('clustInfo', 'var') % data is kilosorted
    fprintf('--- chanOrder will not be tested, as data has been sorted into clusters \n');
else
    mapChan = cellfun(@length, chanOrder);
    checkSum = checkSpikeTrain(sTrain, mapChan, 'channel map');
    if ~checkSum
        fprintf('--- chanOrder and spike train are consistent \n'); 
    end
end

%% Summary of single and multiunits identified
for iArray = 1:length(clustInfo)
    nMU(iArray) = sum(clustInfo{iArray}.isUnit & ~clustInfo{iArray}.isSU);
    nSU(iArray) = sum(clustInfo{iArray}.isSU);
    fprintf ('In Area %i, %i single units and %i multiunits identified \n', ...
        iArray, nSU(iArray), nMU(iArray)); 
end
fprintf('TESTING: clustInfo. Are clusters consistent with spike train? \n'); 
checkSum = checkSpikeTrain(sTrain, nMU+nSU, 'clustInfo');
if ~checkSum
    fprintf('--- clustInfo and spike train are consistent \n'); 
end

%% spike train marginal information

nFiles = length(sTrain); 

a = colormap('magma');
a = a(1:floor(length(a)/nFiles):length(a), :); 

fprintf('Generating Figure 1 to show spike counts and recording duration for each file overall... \n')
figure(1); clf;
for iFile = 1:nFiles
    recMin = cellfun(@(x) size(x,2)/(1000*60), sTrain{iFile});
    for iArray = 1:length(sTrain{iFile})
        
        spikeCount{iFile, iArray} = sum(sTrain{iFile}{iArray}, 2);
        subplot(1,length(sTrain{iFile}), iArray);
        
        % how frequent are different rates
        [x,y] = histcounts(log10(spikeCount{iFile, iArray}), 0:0.25:6);
        
        plot(y(1:end-1),x, 'Color', a(iFile, :), 'LineWidth', 3);
        lText{iArray}{iFile} = sprintf('File %i, %3.2f min', ...
            iFile, recMin(iArray));
        hold on;
        
        if iFile == nFiles
           xlabel('Log-10 Spike Count');
           ylabel('Frequency'); 
           legend(lText{iArray});
           
           titleText = sprintf('Array %i, %i SU and %i MU', ...
               iArray, nMU(iArray), nSU(iArray));
           title(titleText);
           
        end
    end
end 

%% Examine onset inds




% FUNCTION
% iterate through the spike train and check that the number of channels
% matches our expectation. 
function checkSum = checkSpikeTrain(sTrain, mapChan, groundTruth)
    checkSum = 0;
    for iFile = 1:length(sTrain)
       nCh = cellfun(@(x) size(x, 1), sTrain{iFile});
       for iArray = 1:length(mapChan)
          if mapChan(iArray)-nCh(iArray) ~= 0
             checkSum = checkSum + 1;
             fprintf('File %i, array %i: ', iFile, iArray); 
             fprintf('%s has %i channels, %i found in spike train \n', ...
                 groundTruth, mapChan(iArray), nCh(iArray)); 
          end
       end
    end
    if checkSum ~= 0
        warning('--- Spike train irregularity. Incorrect number of channels detected compared to %s.', groundTruth); 
    end
end