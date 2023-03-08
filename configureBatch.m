if getenv('SLURM_ARRAY_TASK_ID')
    idStr = getenv('SLURM_ARRAY_TASK_ID'); % get task ID string 
    fprintf('ID %s\n', idStr);
	arrayTaskID = str2num(idStr); % conv string to number
    
    [chs, pens] = meshgrid(1:128, 9:10);
    
    whichCh = chs(arrayTaskID); 
    pen     = pens(arrayTaskID);
    
    thisJob = getenv('$SLURM_JOB_NAME');
else
    whichCh = 32;
    pen = 9;
end

allFiles = {'/CJ177/007', ...
            '/CJ177/008', ...
            '/CJ179/012', ...
            '/CJ179/013', ...
            '/CJ179/016', ...
            '/CJ190/001', ...
            '/CJ190/003', ...
            '/CJ191/002', ...
            '/CJ223/003', ...
            '/CJ223/004'};
        
fprintf('Pen %i Ch %i \n', pen, whichCh); 

configurePaths;
rootDir = [thisPathRoot allFiles{pen}];