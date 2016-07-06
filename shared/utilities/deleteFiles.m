function deleteFiles(folder)
% Traverse directories starting at ROOTFOLDER and recursively check for 
% compressed video subdirectory. Delete relevant *mat files in directory 
% containing a compressed video subdirectory.

% Check current directory for subdirectory containing the compressed files
% and if there is none, recursively go to the next nested directory
dirInfo= dir(folder);

isDir=[dirInfo.isdir];
dirNames={dirInfo(isDir).name};
dirNames(strcmp(dirNames, '.') | strcmp(dirNames, '..'))=[];
count = 0; 

if isempty(dirNames)
	return	% This will allow us to stop recursion
end

for i=1:length(dirNames)
    if strcmp(dirNames{i},'compressed') % Only delete files in folder containing 'compressed' folder.
        fileInfo= dir(fullfile(folder,'*.mat'));
        names= {fileInfo.name};
        for j=1:length(names)
            if isempty(strfind(names{j},'meta')) == 1 && ...
                    isempty(strfind(names{j},'trialdata')) == 1 
                delete(fullfile(folder,names{j})); % Comment in/out to actually delete files.
                disp(['Deleted file ' names{j}])
                count = count +1;
            end
        end
	else
		deleteFiles(fullfile(folder,dirNames{i}))
    end
 
end
disp(['Deleted ' num2str(count) ' files in ' num2str(folder)])
end
