% getExclusionCriteria
% 
% OK.byTime{ia}(nTypes, nUnits(ia), nTrials): for a time window, is the
%                   unit responding? 
% OK.isVisual{ia}(nTypes, nUnits(ia)): does the unit respond at all
%                   windows for the specified type?
% OK.anyVisual{ia}(1, nUnits(ia)): does the unit respond at all windows for
%                   at least one type?
% OK.DSI{ia}(nTypes, nUnits(ia)): what is the diresction selectivity?

function [OK] = getExclusions(tcs, varargin)
% figure out some data-related parameters
types = fieldnames(tcs.Move);                   % what types
[nAreas, nDirs] = size(tcs.Move.(types{4}));    % how many areas + dirs
nTypes = length(types);                         % how many types

tmp = cellfun(@(x) size(x, 1), ...
                tcs.Move.(types{4}));
nUnits = tmp(:, 1);                             % how many units per area                    

% Must respond more to move than blank throughout experiment
%   in at least one of the 12 directions

% parameters 
if nargin < 3
    pThresh = 0.05;
    if nargin < 2
        trialStep = 10;
    else 
        trialStep = varargin{2}; 
    end
else 
    pThresh = varargin{3};
end
% trialStep = 10; pThresh = 0.05;
nTrials = size(tcs.Blank.(types{4}){1,1}, 2);           % how many trials overall
nBins = ceil(nTrials/trialStep);    % how many bins to test for responsiveness
%%

for ia = 1:nAreas   
%preallocate

    OK.byTime{ia} = zeros(nTypes, nUnits(ia), nTrials);
    OK.isVisual{ia} = zeros(nTypes, nUnits(ia));   
    OK.anyVisual{ia} = zeros(1, nUnits(ia));   
    OK.DSI{ia} = zeros(nTypes, nUnits(ia));
for it = 1:nTypes
    p = nan(nUnits(ia), nBins, nDirs);
for id = 1:nDirs
    tmpMV = tcs.Move.(types{it}){ia,id};
    tmpBK = tcs.Blank.(types{it}){ia,id};
    
    nTrials = size(tmpBK, 2);           % how many trials overall
    nBins = ceil(nTrials/trialStep);    % how many bins to test for responsiveness
    binStarts = 1:trialStep:nTrials;
    
    if nTrials > 0
        for iu = 1:nUnits(ia)
        for ib = 1:nBins
            trialRange = binStarts(ib):binStarts(ib)+trialStep-1;
            trialRange = trialRange(trialRange <= length(tmpBK)); %last bin may have fewer trials
            % in this block of trials, does the move period have significantly 
            % higher spiking than the blank period?
            p(iu, ib, id) = ranksum(tmpBK(iu,trialRange), ...
                                    tmpMV(iu,trialRange), 'tail', 'left');
        end

        end
    end
end
    if size(OK.byTime{ia}, 3)
        for iu = 1:nUnits(ia)
            % if all bins are significantly modulated in at least one
            % direction
            if all(any(p(iu,:,:) > pThresh, 3))
                OK.isVisual{ia}(it, iu) = 1;
            end 
        end
        
        h = p < pThresh; % check p-value against alpha
        hAnyDir = sum(h, 3) > 0; % make sure at least one direction has p > alpha
        % restore trial resolution for ease of use (note that significance
        % testing is still only done in block resolution).
        OK.byTime{ia}(it, :, :) = repelem(hAnyDir, 1, trialStep); 
    end
end
    OK.anyVisual{ia} = sum(OK.isVisual{ia}) > 0;
end
 %%  
% DSI Calculation

for ia = 1:nAreas  
for it = 1:nTypes
    allMus = cellfun(@(x) mean(x, 2), ...
      tcs.Move.(types{it}), 'UniformOutput', false);     % mean rate over trials
    allMus = [allMus{ia,:}];
    if ~isempty(allMus)
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
end