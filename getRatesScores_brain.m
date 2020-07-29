% BATCH_RatesScores (creates _fRates.mat file)

% run this to go through all the combinedData files and sum up the spike
% rates in the specified windows for each stimulus condition. 
% This is where "Tcs" comes from - it stands for "tuning curves".
% Tcs_byFile keeps it the trial counts from different recordings separate.
% This is mostly for sanity checks.
% Then, go on to do the Z scoring and calculate Z-score rates as specified.

function [tcs, Zscs, tcs_byFile] = getRatesScores_brain(param, sTrain, onsetInds, StimFile)                   

    % === Count some things === %
    nDirs     = length(StimFile{1}.testList); % get a direction list, assume same for all files in batch.
    nTypes    = length(param.allTypes); 
    nFiles    = length(sTrain); 
    nWindows  = length(param.windows);
    [~, nAreas]    = size(sTrain{1});
    
    % === Preallocate some things === %
    for p = 1:nTypes %pre-allocate tuning curve structurebinRes
        for w = 1:nWindows
            % this keeps multiple recording .nev files separate (useful for
            % evaluating the recordings)
            tcs_byFile.(param.windows{w}).(param.allTypes{p}) = cell(1,nFiles); 
            % this lumps them all together (more useful for publication)
            tcs.(param.windows{w}).(param.allTypes{p}) = cell(nAreas,nDirs);    
        end
    end

    % === Find spike counts for each trial by stim parameters === %
    for f = 1:nFiles % loop through each of the files in the penetration
        fprintf('Counting spikes per trial in %i/%i ... \n', f, nFiles);
        for w = 1:nWindows

            tcs_tmp = getTrialSpikeCounts(sTrain{f}, onsetInds{f}, StimFile{f}, param.window{w});

            for p = 1:length(StimFile{f}.type) % merge the spike counts from different files to matching types
                tcs.(param.windows{w}).(StimFile{f}.type{p}) = ...
                    cellfun(@horzcat, tcs.(param.windows{w}).(StimFile{f}.type{p}),...
                    tcs_tmp.(StimFile{f}.type{p}), 'UniformOutput', false);

                tcs_byFile.(param.windows{w}).(StimFile{f}.type{p}){f} = ...
                        tcs_tmp.(StimFile{f}.type{p});
            end

            clear tcs_tmp;
        end
    end

    % === Z-score to remove slow fluctuations === %
    % each stimulus type and direction is z-scored independently for a
    % channel, so direction tuning is destroyed. This is meant for calculating
    % noise correlations. 

    % note that you will lose param.nTrialsSlowWin*2 trials to calculating the average
    for w = 1:nWindows
    for type = 1:nTypes
         Zscs.(param.windows{w}).(param.allTypes{type}) = cell(nAreas,nDirs); 
         for f = 1:nAreas
             for d = 1:nDirs
                fRate = [tcs.(param.windows{w}).(param.allTypes{type}){f,:}];
                if param.nTrialsSlowWin > 0
                    runMean = movmean(fRate, param.nTrialsSlowWin, 2);
                    runSTD  = movstd(fRate, param.nTrialsSlowWin,0,2);

                    % convert to a running Z-score
                    runZ = (fRate - runMean)./runSTD;                      

                 else % use all responses to this direction
                    runMean = mean(fRate); 
                    runSTD  = std(fRate);  
                    runZ    = (fRate-runMean)/runSTD;
                end

                % save in a data structure in the same format as tcs.
                Zscs.(param.windows{w}).(param.allTypes{type}){f,d} = ...
                    runZ(:, param.nTrialsSlowWin+1:end-param.nTrialsSlowWin); 
             end
         end
    end
    end


