if getenv('SLURM_ARRAY_TASK_ID')
    idStr = getenv('SLURM_ARRAY_TASK_ID'); % get task ID string 
    fprintf('ID %s\n', idStr);
	arrayTaskID = str2num(idStr); % conv string to number
	pen = arrayTaskID; 
    thisJob = getenv('$SLURM_JOB_NAME');
else
    pen = 1;
end

if ismac 
    thisPathRoot = '/Users/ezavitz/Documents/data';
else
    thisPathRoot = '~/sz11/data/';
    addpath(genpath('~/code/utilities'))
    addpath(genpath('~/code/NPMK'))
    addpath(genpath('~/code/processSpikingMoveStim')) 
end

allFiles = {'/CJ177/007', ...
            '/CJ177/008', ...
            '/CJ179/012', ...
            '/CJ179/013', ...
            '/CJ179/016', ...
            '/CJ190/001', ...
            '/CJ190/003', ...
            '/CJ191/002'};

fprintf('Array & Penetration ID: %s \n', allFiles{pen});
rootDir = [thisPathRoot allFiles{pen}];