
% Find and load fRates
dataFile = sprintf('%s%s%s', rootDir, filesep, 'fRates.mat');
assert(exist(dataFile, 'file'), [dataFile ' not found']);
load(dataFile);

%% show tuning curves for the same stimulus type for each file (in order of recording)
typeList = fieldnames(tcs_byFile.Move);
nFiles = length(tcs_byFile.Move.(typeList{1}));
nArrays = max(cellfun(@(x) size(x, 1), tcs_byFile.Move.(typeList{1})));
nDir = max(cellfun(@(x) size(x, 2), tcs_byFile.Move.(typeList{1})));

a = make2Dmap(length(typeList), nFiles, 'linear');


for iArray = 1:nArrays
    figure(iArray); clf; set(gcf, 'Position', [26 31 1376 766]);
    imSaveName = sprintf('%s%sfRates_A%i_tCurveByFile.%s',...
        testOutPath,filesep, iArray, exportFmt);

    nCh = size(tcs.Move.(typeList{1}){iArray, 1}, 1);


    subplot(8, ceil((nCh+1)/8), 1); image(a); xlabel('File'); ylabel('Type'); 
    title(['Array ' num2str(iArray)]);
    
    for iCh = 1:nCh
        subplot(8, ceil((nCh+1)/8), iCh+1); 
    for iType = 1:length(typeList)
    for iFile = 1:nFiles
       if ~isempty(tcs_byFile.Move.(typeList{iType}){iFile})
            allCounts = [tcs_byFile.Move.(typeList{iType}){iFile}{iArray,:}];
            allCounts = reshape(allCounts(iCh, :), [], nDir);
            plot(mean(allCounts), 'LineWidth', 2, 'Color', a(iType, iFile, :)); 
            axis off; axis square;
            hold on;
       end
    end
    end
    end

    exportgraphics(gcf, imSaveName);
    close gcf;
end


%% tuning curves from tcs and Zscs

for iArray = 1:nArrays
    figure(iArray); clf; set(gcf, 'Position', [26 31 1376 766]);
    imSaveName = sprintf('%s%sfRates_A%i_tCurveZandT.%s',...
        testOutPath,filesep, iArray, exportFmt);

    nCh = size(tcs.Move.(typeList{1}){iArray, 1}, 1);

    subplot(8, ceil((nCh+1)/8), 1); image(a(:, 1:2, :)); 
    ylabel('Type');set(gca, 'XTick', [1 2], 'XTickLabel', {'Zscs', 'Tcs'});
    title(['Array ' num2str(iArray)]);
    
    for iCh = 1:nCh
        subplot(8, ceil((nCh+1)/8), iCh+1); 
    for iType = 1:length(typeList)
        yyaxis left
        allCounts = [Zscs.Move.(typeList{iType}){iArray,:}];
        allCounts = reshape(allCounts(iCh, :), [], nDir);
        plot(mean(allCounts), '-', 'LineWidth', 2, 'Color', a(iType, 1, :));
        hold on;
        
        
        hold on;
        
        yyaxis right;
        allCounts = [tcs.Move.(typeList{iType}){iArray,:}];
        allCounts = reshape(allCounts(iCh, :), [], nDir);
        plot(mean(allCounts), '-', 'LineWidth', 2, 'Color', a(iType, 2, :));
        
        axis off; axis square;
        
    end
    end
    
    exportgraphics(gcf, imSaveName);
    close gcf;
end

 %% tuning curves from move vs blank period

for iArray = 1:nArrays
    figure(iArray); clf; set(gcf, 'Position', [26 31 1376 766]);
    imSaveName = sprintf('%s%sfRates_moveBlank.%s',...
        testOutPath,filesep, exportFmt);

    nCh = size(tcs.Move.(typeList{1}){iArray, 1}, 1);

    subplot(8, ceil((nCh+1)/8), 1); image(a(:, 1:2, :)); 
    ylabel('Type');set(gca, 'XTick', [1 2], 'XTickLabel', {'Blk', 'Mv'});
    title(['Array ' num2str(iArray)]);
    
    for iCh = 1:nCh
        subplot(8, ceil((nCh+1)/8), iCh+1); 
    for iType = 1:length(typeList)
        allCounts = [tcs.Blank.(typeList{iType}){iArray,:}];
        allCounts = reshape(allCounts(iCh, :), [], nDir);
        plot(mean(allCounts), '-', 'LineWidth', 2, 'Color', a(iType, 1, :));
        hold on;
        
        allCounts = [tcs.Move.(typeList{iType}){iArray,:}];
        allCounts = reshape(allCounts(iCh, :), [], nDir);
        plot(mean(allCounts), '-', 'LineWidth', 2, 'Color', a(iType, 2, :));
        
        axis off; axis square;
        
    end
    end
    
    exportgraphics(gcf, imSaveName);
    close gcf;

end

%% rates in Zscs over time

a = make2Dmap(length(typeList), 7, 'linear');
for iArray = 1:2
    figure(iArray); clf; set(gcf, 'Position', [26 31 1376 766]);
    imSaveName = sprintf('%s%sfRates_zscsByTime.%s',...
        testOutPath,filesep, exportFmt);

    nCh = size(tcs.Move.(typeList{1}){iArray, 1}, 1);

    subplot(8, ceil((nCh+1)/8), 1); image(a(:, 1, :)); 
    ylabel('Type');
    title(['Array ' num2str(iArray)]);
        for iCh = 1:nCh
            subplot(8, ceil((nCh+1)/8), iCh+1); 
            for iType = 1:length(typeList)
                allCounts = [Zscs.Move.(typeList{iType}){iArray, :}];
                allCounts = reshape(allCounts(iCh, :), [], nDir);
                dirAvg = mean(allCounts,2);
                plot(movmean(dirAvg, 10), 'LineWidth', 2, 'Color', a(iType, 2,:)); hold on
            end
        end
    exportgraphics(gcf, imSaveName);
    close gcf;
end



