load('/Users/ezavitz/Documents/code/corrStructure_V1MT/data/CJ177/007/fRates.mat', 'tcs', 'Zscs', 'tcs_byFile')
load('/Users/ezavitz/Documents/code/corrStructure_V1MT/data/CJ177/007/SDFs.mat')
load('/Users/ezavitz/Documents/code/corrStructure_V1MT/data/CJ177/007/combinedData.mat', 'onsetInds', 'sTrain'); 
%%
configurePaths;
% specify parameters
fSize = 10;
thresh = 0.5;

window = {'Move', 'Blank'}; nWin = 2;

% figure out parameters
types = fieldnames(Zscs.Move);                   % what types
[nAreas, nDirs] = size(Zscs.Move.(types{1}));    % how many areas + dirs
nTypes = length(types);                         % how many types
nTrials = size(Zscs.Move.(types{1}){1,1}, 2);   

tmp = cellfun(@(x) size(x, 1), ...
                Zscs.Move.(types{1}));
nUnits = tmp(:, 1);                             % how many units per area                    





filt = [ones(1,fSize)./fSize ones(1,fSize)./-fSize];


dirs = 0:30:330;

iCh = 20;
iArray = 2;
iType = 2;

nMs = size(all_sdfs.Dots{iArray,1}, 3);


sdfMap = zeros(nTrials, nDirs*nMs); 
zMove = zeros (nDirs, nTrials);
zBlank = zeros(nDirs, nTrials); 
tInd = 0;
for iDir = 1:nDirs
    zMove(iDir, :) = Zscs.Move.(types{iType}){iArray,iDir}(iCh,:);
    zBlank(iDir, :) = Zscs.Blank.(types{iType}){iArray,iDir}(iCh,:);
    
    sdfMap(:, iDir+tInd:iDir+tInd+nMs-1) = squeeze(all_sdfs.(types{iType}){iArray,iDir}(iCh, :, :));
    tInd = iDir+tInd+nMs;
end

convMove = conv(mean(zMove),filt, 'valid'); 
convBlank = conv(mean(zBlank),filt, 'valid');     

x = 1:nTrials; 
fx = x(fSize:nTrials-fSize); 

clf;


subplot(3,2,1); %zscore 
plot(x, mean(zMove, 1), '-k'); hold on;
plot(x, mean(zBlank, 1), '-b'); hold on;
xlabel('Trial Number'); ylabel('Mean Zscore'); 
legend('Move', 'Blank'); 

subplot(3,2,3); %convolution
plot(fx, convMove, '-k'); hold on;
plot(fx, convBlank, '-b'); hold on;
plot([1 nTrials],[thresh thresh], '-r'); 
plot([1 nTrials],[-thresh -thresh], '-r'); 
plot([1 nTrials],[0 0], ':k'); 
set(gca, 'YLim', [-1 1]);
xlabel('Trial Number'); ylabel('P(cluster transition)')
%%
subplot(1,3,1); 
imagesc(sdfMap); colormap('magma'); hold on;

set(gca, 'xTick', nMs/2:nMs:nMs*nDirs, 'xTickLabel', dirs);
xlabel('Direction x Time'); ylabel('Trial Index'); 

tString = sprintf('Cluster %i, %s', iCh, types{iType}); 
        title(tString); 
%%
nFiles = length(onsetInds);
% iArray = 1;
% iCh = 26;
t = 1;
% subplot(3,2,[5 6]); 
for f = 1%:nFiles
    nTrials = length(onsetInds{f}{iArray});
    onTimes = onsetInds{f}{iArray}(1,:);
    countBlank = zeros(1, nTrials); 
    countMove = zeros(1, nTrials); 
    for on = 1:nTrials
        countBlank(on) = sum(sTrain{f}{iArray}(iCh, onTimes(on):onTimes(on) + 550));
        countMove(on) = sum(sTrain{f}{iArray}(iCh, onTimes(on)+550 :onTimes(on) +1050));
%         plot(t, countBlank, 'ok', 'MarkerFaceColor', 'k'); hold on;
%         plot(t, countMove, 'ob', 'MarkerFaceColor', 'b'); hold on;
        t = t+1;
    end
    plot(1:nTrials, countBlank, '-k'); hold on;
    plot(1:nTrials, countMove, '-b'); 
end
xlabel('Trial'); ylabel('SpikeCount'); 

%%
subplot(3,2,5);
movcount = [tcs.Move.Dots{iArray,:}];
imagesc(reshape(movcount(iCh,:), [], 12))


%%
nDirs = length(dirs); 

clf;


nTrials = length(onsetInds{1}{iArray})/nDirs;
countBlank = zeros(nDirs, nTrials*nFiles); 
countMove = zeros(nDirs, nTrials*nFiles);
onInd = ones(1, nDirs); 
for f = 1:nFiles
    for d = 1:nDirs
        theseTrials = onsetInds{f}{iArray}(2,:) == dirs(d);
        onTimes = onsetInds{f}{iArray}(1,theseTrials);
        for on = 1:length(onTimes)
            countMove(d, onInd(d)) = sum(sTrain{f}{iArray}(iCh, onTimes(on):onTimes(on) + 550));
            countBlank(d, onInd(d)) = sum(sTrain{f}{iArray}(iCh, onTimes(on)+550 :onTimes(on) +1050));
            onInd(d) = onInd(d) + 1;
        end
    end
%     plot(1:nTrials, countBlank, '-k'); hold on;
%     plot(1:nTrials, countMove, '-b'); 
    

end
%%
clf; 
cMax = prctile(countMove(:), 99);
subplot(1,3,2); colormap('magma');
    imagesc(countBlank', [0 cMax]); hold on;
    xlabel('Direction'); ylabel('Trial'); 
    title('Blank');
    plot([0 nDirs+1],[nTrials nTrials], ':y', 'LineWidth', 2);
    plot([0 nDirs+1],[nTrials*2 nTrials*2], ':y', 'LineWidth', 2);
    plot([0 nDirs+1],[nTrials*3 nTrials*3], ':y', 'LineWidth', 2);
    set(gca, 'FontSize', 16)
subplot(1,3,3);     
	imagesc(countMove', [0 cMax]); hold on;
    plot([0 nDirs+1],[nTrials nTrials], ':y', 'LineWidth', 2);
    plot([0 nDirs+1],[nTrials*2 nTrials*2], ':y', 'LineWidth', 2);
    plot([0 nDirs+1],[nTrials*3 nTrials*3], ':y', 'LineWidth', 2);
    xlabel('Direction'); ylabel('Trial'); 
    title('Move'); set(gca, 'FontSize', 16)