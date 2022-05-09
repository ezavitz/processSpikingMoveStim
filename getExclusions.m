% getExclusionCriteria
function [OK] = getExclusions(tcs)

% figure out some data-related parameters
types = fieldnames(tcs.Move);                   % what types
[nAreas, nDirs] = size(tcs.Move.(types{1}));    % how many areas + dirs
nTypes = length(types);                         % how many types

tmp = cellfun(@(x) size(x, 1), ...
                tcs.Move.(types{1}));
nUnits = tmp(:, 1);                             % how many units per area                    

% Must respond more to move than blank throughout experiment
%   in at least one of the 12 directions

% parameters 
pThresh = 0.05;
trialStep = 10; %test 10 trials at a time for visual responsiveness (move > blank)

for ia = 1:nAreas   
for it = 1:nTypes
    p = nan(nUnits(ia), nBins, nDirs);
for id = 1:nDirs
    tmpMV = tcs.Move.(types{it}){ia,id};
    tmpBK = tcs.Blank.(types{it}){ia,id};
    
    nTrials = size(tmpBK, 2);
    nBins = ceil(nTrials/trialStep);
    binStarts = 1:trialStep:nTrials;
    
    %preallocate
    if it == 1 && id == 1
        OK.byTime{ia} = zeros(nTypes, nUnits(ia), nTrials);
        OK.isVisual{ia} = zeros(nTypes, nUnits(ia));   
        OK.anyVisual{ia} = zeros(1, nUnits(ia));   
        OK.DSI{ia} = zeros(nTypes, nUnits(ia));
    end
    
    for iu = 1:nUnits(ia)
        for ib = 1:nBins
            trialRange = binStarts(ib):binStarts(ib)+trialStep-1;
            trialRange = trialRange(trialRange <= length(tmpBK)); %last bin may have fewer trials
            p(iu, ib, id) = ranksum(tmpBK(iu,trialRange), ...
                                    tmpMV(iu,trialRange), 'tail', 'left');
        end
        % if all bins are significantly modulated
        if prod(p < pThresh) ~= 0 
            OK.isVisual{ia}(it, iu) = 1;
        end
    end
end
    h = p < pThresh; % check p-value against alpha
    hAnyDir = sum(h, 3) > 0;
    OK.byTime{ia}(it, :, :) = repelem(hAnyDir, 1, trialStep);
end
    OK.anyVisual{ia} = sum(OK.isVisual{ia}) > 0;
end
   
% DSI Calculation

for ia = 1:nAreas  
for it = 1:nTypes
    allMus = cellfun(@(x) mean(x, 2), ...
      tcs.Move.(types{it}), 'UniformOutput', false);     % mean rate over trials
    allMus = [allMus{ia,:}];
    
    [pref_val, pref_ind] = max(allMus, [],2);
    apref_ind = pref_ind + (nDirs/2);
    apref_ind(apref_ind > nDirs) = ...
        apref_ind(apref_ind > nDirs)-nDirs;
    
    for iu = 1:nUnits(ia)
        apref_val = allMus(iu, apref_ind(iu));
        OK.DSI{ia}(it, iu) = ...
            (pref_val(iu)-apref_val)/(pref_val(iu)+apref_val);
    end    
end
end