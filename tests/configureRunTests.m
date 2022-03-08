if getenv('SLURM_ARRAY_TASK_ID')
    idStr = getenv('SLURM_ARRAY_TASK_ID'); % get task ID string
    fprintf('ID %s\n', idStr);
	  arrayTaskID = str2num(idStr); % conv string to number
	  pen = arrayTaskID;
else
    pen = 1;
end

% setup paths for my laptop vs. on the cluster
if ismac 
    thisPathRoot = '/Users/ezavitz/Documents/code/corrStructure_V1MT';
    codeRoot = '~/Documents/code/';
else
    thisPathRoot = '~/code/corrStructure_V1MT';
    codeRoot = '~/code/';
end

% make sure the path root is valid
assert(exist(thisPathRoot, 'dir'), ...
    'Path root %s is invalid', thisPathRoot);

addpath(genpath([codeRoot 'utilities']))
addpath(genpath([codeRoot 'corrStructure_V1MT/scripts']))
addpath(genpath([codeRoot 'processSpikingMoveStim'])) 

allFiles = {'/CJ177/007', ...
            '/CJ177/008', ...
            '/CJ179/012', ...
            '/CJ179/013', ...
            '/CJ179/016', ...
            '/CJ190/001', ...
            '/CJ190/003', ...
            '/CJ191/002'};

for pen = 1:length(allFiles)        
    rootDir = [thisPathRoot '/data' allFiles{pen}];

    testOutPath = [thisPathRoot '/results/dataQuality' allFiles{pen}];
    if ~exist(testOutPath, 'dir')
        mkdir(testOutPath);
    end

    diaryName = 'dataTestOutput.txt';


    if exist([testOutPath filesep diaryName], 'file') 
        delete([testOutPath filesep diaryName])
    end

    diary([testOutPath filesep diaryName]);
    exportFmt = 'jpg';

    fprintf('Array & Penetration ID: %s \n', allFiles{pen});

    fprintf('Running tests on combinedData.mat... \n');
    testCombinedData;

    fprintf('Running tests on fRates.mat... \n');
    testFRates;

    fprintf('Running tests on SDFs.mat... \n');
    testSDFs;

    diary off
end

