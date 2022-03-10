
% Find and load combined data
dataFile = sprintf('%s%s%s', rootDir, filesep, 'combinedData.mat');
load(dataFile);

assert(length(onsetInds) == length(sTrain), ...
    'File count mismatch between trial onsets and spike trains!');

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
    figure(1); clf; set(gcf, 'Position', [14 185 1307 490]);
imSaveName = sprintf('%s%scombined_SpikeCounts.%s', ...
    testOutPath,filesep, exportFmt); 
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
           legend(lText{iArray}, 'Location', 'NorthWest');
           
           titleText = sprintf('Array %i, %i SU and %i MU', ...
               iArray, nMU(iArray), nSU(iArray));
           title(titleText);
           
        end
    end
end 
exportgraphics(gcf, imSaveName);
    close gcf;

%% Examine onset inds triall totals and timing

nFiles = length(onsetInds); 
nArrays = length(onsetInds{1}); 

nTrials = zeros(nArrays,nFiles);
for iFile = 1:nFiles
    nTrials(:, iFile) = cellfun(@(x) size(x, 2), onsetInds{iFile});
end

disp(table(nTrials)); 
if length(unique(nTrials(:))) == 1
   fprintf('All arrays and files contain data for %i trials \n', ...
       nTrials(1)); 
else
    if sum(diff(nTrials)) == 0 
        fprintf('All files contain the same number of trials between arrays \n');
    else
        fprintf('Trial mismatch between arrays - something may have gone wrong! \n');
    end
end

fprintf('Generating Figure 2 to summarise inter-trial latency... \n')
figure(2); clf; set(gcf, 'Position', [45 148 1368 556]);
imSaveName = sprintf('%s%scombined_trialTiming.%s',...
    testOutPath,filesep, exportFmt); 
hold on;
y = -10:1:10; %ms offset to examine
filex = zeros(nFiles, length(y)-1);  % accumulate fine delay freq by file
nPlus = zeros(nFiles);               % count large delay freq by file

for iFile = 1:nFiles
    itiGoal = 1000*(StimFile{iFile}.tMove + StimFile{iFile}.tBlank);
    for iArray = 1:nArrays
        subplot(1, nArrays, iArray); hold on;
        itiActual = diff(onsetInds{iFile}{iArray}(1,:));
        filex(iFile, :) = histcounts(itiActual-itiGoal, y);
        
        smallMiss = sum(abs(itiActual-itiGoal) > 10);
        bigMiss = sum(abs(itiActual-itiGoal) > 100);
        
        lText{iArray}{iFile} = sprintf('File %i, n > 10ms = %i, n > 100ms = %i', ...
            iFile, smallMiss, bigMiss);
        
        if iFile == nFiles
            bar(filex', 'stacked');
            set(gca, 'XTick', 1:length(y), 'XTickLabel', y);
            title(['Array ' num2str(iArray)])
            legend(lText{iArray});
            ylabel('Trial Count'); 
            xlabel('Trial onset relative to target (ms)');
        end
    end
end
exportgraphics(gcf, imSaveName);
close gcf;

%% report file types across recordings.

clear nTrials
for iFile = 1:nFiles
for iArray = 1:nArrays
    dirList  = unique(onsetInds{iFile}{iArray}(2,:));
    typeList = unique(onsetInds{iFile}{iArray}(4,:));

    nDirs   = length(dirList); 
    nTypes  = length(typeList); 

    nTrials{iArray} = zeros(nTypes, nDirs); 
    for iType = 1:nTypes
        for iDir = 1:nDirs
            nTrials{iArray}(iType, iDir) = sum(onsetInds{1}{1}(2,:) == 0 & ...
                                       onsetInds{1}{1}(4,:) == 1);
        end
    end
end

fprintf('File %i: Type 1 = %s, 2 = %s', ...
            iFile, StimFile{iFile}.type{1}, StimFile{iFile}.type{2});
if nTypes > 2; fprintf(', 3 = %s',  StimFile{iFile}.type{3}); end
if nTypes > 3; fprintf(', 4 = %s',  StimFile{iFile}.type{4}); end
fprintf('\n');

if ~sum(nTrials{1}(:)-nTrials{2}(:))
    typeInd = [nan; typeList']; 
    trialTable = [typeInd [dirList; nTrials{1}]];
    
    
    disp(trialTable);
else
    fprintf(['Trial types do not match between simultaneously recorded' ...
             ' arrays! Something has gone wrong. \n']);
end
end

%% does the stimulus file agree with onsetInds about 
%% how many trials there should be?

checkSum = 0;
for iArray = 1:nArrays
for iFile = 1:nFiles
    onSize= size(onsetInds{iFile}{iArray}, 2);
    stimSize = StimFile{iFile}.nTrials;
    if onSize ~= stimSize
        checkSum = checkSum + 1;
        warning(['Trial count mismatch between stimulus '...
                    'file and recording in Array %i, File %i'], iArray, iFile);
    end
end
end

if ~checkSum
    fprintf('All stimulus files and recordings agree on trial count. \n');
end

%% Rasters of ALL THE SPIKES
%%% -------- you probably don't want this, this is a terrible idea

% figure(3); clf;
% % raster of one channel
% iArray = 1; iCh = 3; 
% tInd = 1;
% for iFile = 1:nFiles
%     isSpike = sTrain{iFile}{iArray}(iCh,:); 
%     trialOns = onsetInds{iFile}{iArray}(1,:);
%     itis = diff(trialOns);
%     itis = [itis mode(itis)];
% 
%     fprintf('plotting %i spikes \n', sum(isSpike));
%     for iTrial = 1:length(trialOns)
%        ms = 1:itis(iTrial);
%        tStart = trialOns(iTrial);
%        theseSpikes = logical(isSpike(tStart:tStart+itis(iTrial)-1));
%        yLevel = ones(1, length(ms))*tInd; 
%        plot(ms(theseSpikes), yLevel(theseSpikes), '.', ...
%            'Color', a(iFile, :)); hold on;
%        tInd = tInd + 1; 
%     end
% end


%%
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