% getExclusionCriteria
function [OK] = getExclusions(tcs)


% figure out some data-related parameters
types = fieldnames(tcs.Move);                   % what types
[nAreas, nDirs] = size(tcs.Move.(types{1}));    % how many areas + dirs
nTypes = length(types);                         % how many types

tmp = cellfun(@(x) size(x, 1), ...
                tcs.Move.(types{1}));
nUnits = tmp(:, 1);                             % how many units per area                    

% preallocate
for ia = 1:nAreas
   OK.isVisual{ia} = zeros(nTypes, nUnits(ia));   
   OK.anyVisual{ia} = zeros(1, nUnits(ia));   
   OK.isResponsive{ia} = zeros(nTypes, nUnits(ia));
   OK.DSI{ia} = zeros(nTypes, nUnits(ia));
end

% Criterion 1: Must be above threshold responsiveniss throughout experiment
%   in at least one of the 12 directions

% parameters 
minResp  = 1.5;  % minimum responsiveness
trialBin = 100; % number of trials to average over
trialDur = 0.5; 

for ia = 1:nAreas   
for it = 1:nTypes
    overThresh = zeros(nUnits(ia), nDirs);
for id = 1:nDirs
    tmp = movmean(tcs.Move.(types{it}){ia,id},trialBin,2);
    rate = tmp(:, trialBin:trialBin:end)/trialDur;
    overThresh(:, id) = prod(rate > minResp, 2);
end
    OK.isResponsive{ia}(it, :) = sum(overThresh, 2) > 1;
end
end

% Criterion 2: More responsive to Move period than to Blank period for at 
%               least one direction

% parameters
pThresh = 0.05;

for ia = 1:nAreas   
for it = 1:nTypes
    p = zeros(nUnits(ia), nDirs);
    for iu = 1:nUnits(ia)
    for id = 1:nDirs    
        d1 = tcs.Move.(types{it}){ia, id}(iu, :)';
        d2 = tcs.Blank.(types{it}){ia, id}(iu, :)';
        p(iu, id) = kruskalwallis([d1 d2], [], 'off');
    end
    end
    
    OK.isVisual{ia}(it, :) = sum(p<pThresh, 2) > 1;
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