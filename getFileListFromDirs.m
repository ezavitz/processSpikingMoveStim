% searches for the directories with the names that match the regex
% expression as these are directories representing data files. 
function [fileList] = getFileListFromDirs(pathRoot, expression)

contents = dir(pathRoot);
filenames = {contents.name};
fileInd = 1;
for ifile = 1:length(filenames)
    if regexp(filenames{ifile}, expression)
       fileList{fileInd} =  filenames{ifile};
       fileInd = fileInd + 1;
    end
end