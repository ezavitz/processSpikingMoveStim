clear; clc;

allFiles = {'/CJ177/007', ...
            '/CJ177/008', ...
            '/CJ179/012', ...
            '/CJ179/013', ...
            '/CJ179/016', ...
            '/CJ190/003', ...
            '/CJ191/002'};

pen = 2;        
t=2; % just sine wave for diagnostic

thisPathRoot = '/Users/ezavitz/Documents/data'; 
rootDir = [thisPathRoot allFiles{pen}];


load([rootDir '/fRates.mat'], 'param', 'tcs')
load([rootDir '/combinedData.mat'], 'clustInfo')
load([rootDir '/SDFs.mat'])
load([rootDir '/exclusions.mat']);

%%
cList = colormap('lines');

muRates  = cellfun(@(x) mean(x, 2), tcs.Move.(param.allTypes{t}), 'UniformOutput', false);
tMean = cellfun(@(x) squeeze(mean(x, 2)), ...
                all_sdfs.(param.allTypes{t}), 'UniformOutput', false);
maxResp = cellfun(@(x) max(x, [], 2), tMean, 'UniformOutput', false);

%%
for ai = 1:2

    elecList = arrayfun(@str2num, clustInfo{ai}.ch);
    elecs = unique(elecList);
    nElec = length(elecs); 

    theseRates = [muRates{ai,:}];
    peakResp = [maxResp{ai,:}];

    figure(1); clf; set(gcf, 'Position', [44 22 1660 922], 'Color', 'w');  
    figure(2); clf; set(gcf, 'Position', [44 22 1660 922], 'Color', 'w'); 
    nS   = sqrt(nElec);
    nCol = ceil(nS);
    nRow = nCol - (nCol * nCol - nElec > nCol - 1);
    SUs = clustInfo{ai}.isSU(clustInfo{ai}.isUnit);
    
    for ei = 1:nElec

        myCells = find(elecList == elecs(ei));
        isSU    = SUs(myCells);    
        figure(1); subplot(nRow, nCol, ei); cla;
        for ci = 1:length(myCells)
            [~, here] = max(peakResp(myCells(ci), :)');
            mu = tMean{ai, here}(myCells(ci), :);
            if OK.isVisual{ai}(t, myCells(ci))
                thisCol = cList(ci, :);
            else
                thisCol = [0.5 0.5 0.5];
            end
            plot(1:1000, mu, '-', 'LineWidth', 2, 'Color', thisCol); hold on;
        end
    
        figure(2); subplot(nRow, nCol, ei); cla;
        for ci = 1:length(myCells)
            mu = theseRates(myCells(ci), :);
            if OK.isVisual{ai}(t, myCells(ci))
                thisCol = cList(ci, :);
            else 
                thisCol = [0.5 0.5 0.5];
            end
            
            if isSU(ci)
                thisStyle = 'o-';
            else
                thisStyle = '.-';
            end
            
            plot(0:30:330, mu, thisStyle, 'LineWidth', 1.5, ...
                    'MarkerFaceColor', 'w', ...
                    'Color', thisCol); hold on;
        end     
    end
    figure(1); saveas(gcf, [rootDir '/' num2str(ai) '-tuningByElec.jpg']);
    figure(2); saveas(gcf, [rootDir '/' num2str(ai) '-tCourseByElec.jpg']);
end
