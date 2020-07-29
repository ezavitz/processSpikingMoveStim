function [all_sdfs] = getSDF_brain(param, sTrain, onsetInds, StimFile)

nTypes  = length(StimFile{1}.type); 
theseDirs = unique(onsetInds{1}{1}(2,:));   % get a direction list
nDirs     = length(theseDirs); 
nFiles    = length(sTrain); 

for p = 1:length(param.allTypes) %pre-allocate tuning curve structurebinRes
    all_sdfs.(param.allTypes{p}) = cell(2,nDirs);    
end
 
for f = 1:nFiles % loop through each of the files in the penetration
    fprintf('File %i of %i \n', f, nFiles);
    sdfs = getTrialSDFs(sTrain{f}, onsetInds{f}, ...
                        StimFile{f}, param.sWin, param.sBin);
    
    for p = 1:nTypes
        all_sdfs.(StimFile{f}.type{p}) = ...
            cellfun(@(a, b) horzcat(a, permute(b, [2 1 3])), all_sdfs.(StimFile{f}.type{p}), ...
                    sdfs.(StimFile{f}.type{p}), 'UniformOutput', false);
    end
end