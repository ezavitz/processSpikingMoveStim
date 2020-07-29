% INPUT: s  -- spike time output from spiking network simulation
%        param -- parameters output from spiking network simulation
%        option -- output from simulation
%        trialLength -- number of ms to count as a 'trial'
%        subpopsize  -- number of neurons to grab counts from
%       

function [tcs, Zscs] = getRatesScores_model(s, param, option, trialLength, subpopsize)

[nLayer, nType, nOri] = size(s);
nSample = subpopsize;

trialBins = 0:trialLength:param.T;
nTrials = length(trialBins)-1;

exciteList = 1:param.Ne;
subNeuronList = randsample(exciteList, nSample);

for iLayer = 2:nLayer
    for iType = 1:nType
        % preallocate mtcs.Move.(stimList{1})
        tcs.Move.(option.stimList{iType}) = cell(nLayer-1, nOri);
        Zscs.Move.(option.stimList{iType}) = cell(nLayer-1, nOri);
        for iOri = 1:nOri 
            % preAllocate Neurons
            countMat = zeros(nSample, nTrials);
            allNeurons = s{iLayer,iType,iOri}(2,:);

            for iNeuron = 1:nSample
                myNeuron = subNeuronList(iNeuron);
                myTimes = s{iLayer,iType,iOri}(1, allNeurons == myNeuron); % spike times in ms.

                countMat(iNeuron, :) = histcounts(myTimes, trialBins); % problem for future liz: edge effects
            end

            tcs.Move.(option.stimList{iType}){iLayer-1, iOri} = countMat;
            Zscs.Move.(option.stimList{iType}){iLayer-1, iOri} = zscore(countMat, [], 2);

        end; clear iOri
    end; clear iType
end; clear iLayer
