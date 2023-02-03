rootDir = '~/Documents/code/corrStructure_V1MT/data/CJ223/002';

tmp = split(rootDir, filesep); % get the animal mame
expression = sprintf('%s\\.motionStim\\.[0-9]{6}\\.mat', tmp{end-1});

% get a list of the neurostim files that are part of this penetration
fileList = getFileListFromDirs([rootDir filesep], expression);
cfg = 'marmodata.cfgs.acute.H64FlexiH64FlexiIntan';
%%
d = marmodata.mdbase([rootDir filesep fileList{1}],'loadArgs', ...
    {'loadEye',false,'spikes',true,'source','ghetto', ...
    'reload',true, 'channels', 66, 'useCAR',false}); %% need to remove channels argument to process all

%%
load([rootDir filesep fileList{1}], 'c'); 
oris = get(c.nWave.prms.orientation, 'atTrialTime', Inf)';

%%
sc = zeros(1, length(d.spikes.spk)); 
for iTrial = 1:length(d.spikes.spk)
    sc(iTrial) = sum(d.spikes.spk{iTrial}(d.spikes.spk{iTrial} < 0.55));
end
%%
oriL = unique(oris); 
subSC = sc(2:end);
tc = zeros(1, length(oriL));
for oi = 1:length(oriL)
    theseTrials = oris == oriL(oi);
    tc(oi) = mean(subSC(theseTrials));
end

plot(tc);