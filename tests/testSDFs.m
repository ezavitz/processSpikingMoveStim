% Find and load SDFs
dataFile = sprintf('%s%s%s', rootDir, filesep, 'SDFs.mat');
load(dataFile);
dataFile = sprintf('%s%s%s', rootDir, filesep, 'combinedData.mat');
load(dataFile, 'onsetInds', 'StimFile', 'clustInfo');
dataFile = sprintf('%s%s%s', rootDir, filesep, 'exclusions.mat');
load(dataFile, 'OK');


typeList = fieldnames(all_sdfs);
nFiles = length(onsetInds); 
thisDirOrder = cell(1, length(typeList)); 

%%
dirs = unique(onsetInds{1}{1}(2,:)); 
nDir = length(dirs);
nTypes = length(typeList); 
for iArray = 1:2
    isSU = clustInfo{iArray}.isSU(clustInfo{iArray}.isUnit);
    [nCh, nReps, nMs] = size(all_sdfs.Dots{iArray,1});
    
for iCh = 1:nCh
    figure(); set(gcf, 'Position', [342 32 1225 832]);
    imSaveName = sprintf('%s%sSDF_A%i_ch%i.%s', ...
        testOutPath, filesep, iArray, iCh, exportFmt); 
    if isSU(iCh); uType = 'SU'; else; uType = 'MUA'; end
    for iType = 1:nTypes
        sdfMap = zeros(nReps, nDir*nMs); 
        tInd = 0; 
        for iDir = 1:nDir 
            sdfMap(:, iDir+tInd:iDir+tInd+nMs-1) = squeeze(all_sdfs.(typeList{iType}){iArray,iDir}(iCh, :, :));
            tInd = iDir+tInd+nMs;
        end
        subplot(2,2,iType); 
        imagesc(sdfMap); 
        if OK.isVisual{iArray}(iType, iCh)
            colormap('inferno');freezeColors
        else
            colormap('gray');freezeColors
        end

        set(gca, 'xTick', nMs/2:nMs:nMs*nDir, 'xTickLabel', dirs);
        xlabel('Direction x Time'); ylabel('Trial Index'); 

        tString = sprintf('%s %i, %s, DSI = %1.2f', uType, iCh, typeList{iType}, OK.DSI{iArray}(iType, iCh)); 
        title(tString); 

    end
    exportgraphics(gcf, imSaveName);
    close gcf;
end
end

