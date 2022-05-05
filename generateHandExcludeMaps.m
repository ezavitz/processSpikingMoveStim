clear
configureBatch;
configurePaths;

for pen =1:length(allFiles)
    thisCase = allFiles{pen};

    load([thisPathRoot thisCase '/combinedData.mat'], 'onsetInds', 'sTrain'); 

    for iArray = 1:2

    dirs = unique(onsetInds{1}{1}(2,:));
    nDirs = length(dirs); 
    nFiles = length(onsetInds);
    nTrials = length(onsetInds{1}{iArray})/nDirs;
    nCh = size(sTrain{1}{iArray}, 1);

    figure(1); clf; t1 = tiledlayout('flow');
    figure(2); clf; t2 = tiledlayout('flow'); 

    for iCh = 1:nCh
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
        end
        cMax = prctile(countMove(:), 99);
        if cMax > 0


            nexttile(t1); colormap('magma');
            imagesc(countBlank', [0 cMax]); axis off; hold on;
    %         xlabel('Direction'); ylabel('Trial'); 
    %         title('Blank');
            plot([0 nDirs+1],[nTrials nTrials], ':y', 'LineWidth', 1);
            plot([0 nDirs+1],[nTrials*2 nTrials*2], ':y', 'LineWidth', 1);
            plot([0 nDirs+1],[nTrials*3 nTrials*3], ':y', 'LineWidth', 1);

            nexttile(t2); colormap('Magma'); 
            imagesc(countMove', [0 cMax]); axis off; hold on;
            plot([0 nDirs+1],[nTrials nTrials], ':y', 'LineWidth', 1);
            plot([0 nDirs+1],[nTrials*2 nTrials*2], ':y', 'LineWidth', 1);
            plot([0 nDirs+1],[nTrials*3 nTrials*3], ':y', 'LineWidth', 1);
    %         xlabel('Direction'); ylabel('Trial'); 
        end

    end
        exportName = sprintf(['/Users/ezavitz/Documents/code/corrStructure_V1MT/results/' ...
                              '%s_%s_Array%i_Blank.pdf'], thisCase(2:6), thisCase(8:10), iArray);
        exportgraphics(t1, exportName);

        exportName = sprintf(['/Users/ezavitz/Documents/code/corrStructure_V1MT/results/' ...
                              '%s_%s_Array%i_Move.pdf'], thisCase(2:6), thisCase(8:10), iArray);
        exportgraphics(t2, exportName);
    end
end