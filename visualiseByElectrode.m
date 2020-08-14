clear
load('/Users/ezavitz/Documents/data/CJ177/007/fRates.mat', 'param', 'tcs')
load('/Users/ezavitz/Documents/data/CJ177/007/combinedData.mat', 'clustInfo')
load('/Users/ezavitz/Documents/data/CJ177/007/SDFs.mat')

%% Show the tuning curves for each electrode. 
ai = 2;
t=2;
%


muRates  = cellfun(@(x) mean(x, 2), tcs.Move.(param.allTypes{t}), 'UniformOutput', false);
steRates = cellfun(@(x) std(x,[], 2)/sqrt(size(x,2)), tcs.Move.(param.allTypes{t}), 'UniformOutput', false);
tMean = cellfun(@(x) squeeze(mean(x, 2)), ...
                all_sdfs.(param.allTypes{t}), 'UniformOutput', false);
tmp = cellfun(@(x) max(x, [], 2), tMean, 'UniformOutput', false);

%%
elecList = arrayfun(@str2num, clustInfo{ai}.ch);
elecs = unique(elecList);
nElec = length(elecs); 

theseRates = [muRates{ai,:}];
theseSTEs  = [steRates{ai,:}];
peakResp = [tmp{ai,:}];
%
figure(1); clf; figure(2); clf;
nS   = sqrt(nElec);
nCol = ceil(nS);
nRow = nCol - (nCol * nCol - nElec > nCol - 1);
SUs = clustInfo{ai}.isSU(clustInfo{ai}.isUnit);
cList = colormap('lines');

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
        err = theseSTEs(myCells(ci), :);
        if isSU(ci)
            plot(0:30:330, mu, 'o-', 'LineWidth', 1.5, 'MarkerFaceColor', 'w'); hold on;
        else
            plot(0:30:330, mu, '.-', 'LineWidth', 1.5); hold on;
        end
    end
end
