function [sdfs] = getTrialSDFs(sTrain, onsetInds, Stim, sWin, sBin)

theseDirs = Stim.testList; 
theseTypes = Stim.type;

nAreas = length(sTrain);
nDirs  = length(theseDirs); 
nTypes  = length(theseTypes); 


for p = 1:nTypes
   fprintf('Beginning %s ... \n', Stim.type{p});
   sdfs.(Stim.type{p}) = cell(nAreas, nDirs);
   for a = 1:nAreas
      [nCh, ~] = size(sTrain{a}); 
      for d = 1:nDirs
          fprintf('-%i-', theseDirs(d));
         theseTrials = onsetInds{a}(2,:) == theseDirs(d) & ...
                       onsetInds{a}(4,:) == p;
         theseTimes  = onsetInds{a}(1,theseTrials); 
         
         nTrials = length(theseTimes); 
         
         sdfs.(Stim.type{p}){a,d} = ...
             zeros(nTrials, nCh, sWin);
         for t = 1:nTrials
            thisOn = theseTimes(t);
            tmp = movsum(sTrain{a}(:, thisOn:thisOn+sWin-1), sBin, 2);
            sdfs.(Stim.type{p}){a,d}(t, :, :) = ...
                tmp;
            
         end
         
      end
      fprintf('\n');
   end
end