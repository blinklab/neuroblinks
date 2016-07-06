function names=getFullFileNames(folder,dirstruct)

m=length(dirstruct);
names=cell(m,1);

for i=1:m
    names{i}=fullfile(folder,dirstruct(i).name);
end

end