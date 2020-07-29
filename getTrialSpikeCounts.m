function [tcs] = getTrialSpikeCounts(sTrain, onsetInds, Stim, countWin)
% GETTRIALSPIKECOUNTS (sTrain, onsetInds, Stim, countWin)
% Written by LZ, sometime in late 2017
%
% sTrain:       {f} nCh x nMs matrix of 1 = spike, 0 = no spike
% onsetInds:    {f} (nParam + 1) x nTrials matrix of trial info. 
% Stim:         Stimulus data structure saved by corresponding stim file
% countWin:     [t1 t2] vector. Spikes between t1 and t2 (relative to trial
%                   start) are counted.  
% The file index {f} allows multiple recordings to be analysed as one. 
%
% Output: tcs. tcs.<stimType>{f, dir}(nChs, nReps). In this case,
% stimType is either Dots, SineWave, Square, or PSsquare. 
% 
% Use OPENFILESGETDATA to construct all the necessary inputs for this
% function. 

theseDirs = Stim.testList; 
theseTypes = Stim.type;

nFiles = length(sTrain);
nDirs  = length(theseDirs); 
nTypes  = length(theseTypes); 

% this won't generalise if we record more than two data files at once. 
if sum(diff(cellfun(@length, onsetInds))) > 0 % there are missing trials on the first array
    onsetInds{2} = onsetInds{2}(:, 1:length(onsetInds{1}));
elseif sum(diff(cellfun(@length, onsetInds))) < 0 % there are missing trials on the second array
    onsetInds{1} = onsetInds{1}(:, 1:length(onsetInds{2}));
end

for p = 1:nTypes % loop through types
    tcs.(Stim.type{p}) = cell(nFiles, nDirs);
    for f = 1:nFiles % loop through files   
        [nCh, ~] = size(sTrain{f});
         nT = zeros(nFiles, nDirs); 
         for d = 1:nDirs
             % find the trial times associated with each type and direction
            theseTrials = onsetInds{f}(2,:) == theseDirs(d) & ...
                          onsetInds{f}(4,:) == p;
            theseTimes  = onsetInds{f}(1,theseTrials); 
            
            tcs.(Stim.type{p}){f,d} = zeros(nCh,length(theseTimes));
            
            % loop through the times, and sum the spikes within the
            % specified count window
            for t = 1:length(theseTimes)
                tcs.(Stim.type{p}){f,d}(:, t) = ...
                    sum(sTrain{f}(:, theseTimes(t)+countWin(1):theseTimes(t)+countWin(2)), 2);
            end
            
        end
    end
end