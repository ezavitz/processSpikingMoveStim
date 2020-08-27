% show tuning curves for each channel, for each file. 
configureBatch;

fPre = 'NEV'; % use this to prefix other versions of preprocessed data

load([rootDir filesep fPre 'fRates.mat'], 'tcs_byFile', 'param')

ti = 2; 
ai = 2;
clf; 
cMap = colormap('magma'); 
rateFactor = 1000/diff(param.window{1}); % for spikes per second
for fi = 1:4
    if ~isempty(tcs_byFile.Move.(param.allTypes{ti}){fi})
        rates = cellfun(@(x) mean(x, 2)*rateFactor, tcs_byFile.Move.(param.allTypes{ti}){fi}, ...
            'UniformOutput', false);

        tuneCurves = [rates{ai, :}];

        nCh = size(tuneCurves,1);
        for ch = 1:nCh
            subplot(10,10, ch); hold on;
            plot(tuneCurves(ch, :), '-', 'LineWidth', 2, 'Color', cMap(fi*10, :));
        end
    end
end
