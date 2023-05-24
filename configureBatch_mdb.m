% the marmodata version of processing things - with channel-by-channel
% spike extraction
allFiles = {'/CJ221/001', ...
            '/CJ223/001', ...
            '/CJ223/003'};

if getenv('SLURM_ARRAY_TASK_ID')
    idStr = getenv('SLURM_ARRAY_TASK_ID'); % get task ID string 
    fprintf('ID %s\n', idStr);
	arrayTaskID = str2num(idStr); % conv string to number
    
    [chs, pens] = meshgrid(1:128, 1:length(allFiles));
    
    whichCh = chs(arrayTaskID); 
    pen     = pens(arrayTaskID);
    
    thisJob = getenv('$SLURM_JOB_NAME');
else
    whichCh = 32;
    pen = 1;
end


        
fprintf('Pen %i Ch %i \n', pen, whichCh); 

configurePaths;
rootDir = [thisPathRoot allFiles{pen}];          

