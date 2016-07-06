function makeCompressedVideos(varargin)
% makeCompressedVideos({folder,verbose})
% Compress videos from raw data array in MAT files, putting them in subdirectory called "compressed" and writing metadata as "[BASE]_meta.mat" file,
% where BASE is the base file name of the video file. Videos are written using WriteStimVideo() function so that the color coded boxes are 
% displayed during stimulation. Optionally, include the name of the folder containing the original MAT files; current directory is used by default.
% If verbose flag is set (second argument set to 1), message is displayed each time a video is written to disk.

if nargin > 0
	folder=varargin{1};
else
	folder=pwd;
end

if nargin > 1
	VERBOSE=1;
else
	VERBOSE=0;
end

fnames=getFileNames(dir([folder '/*.mat']));

mkdir([folder '/compressed'])

% if matlabpool('size') == 0
%     matlabpool open	% Start a parallel computing pool using default number of labs (usually 4-8).
%     cleaner = onCleanup(@() matlabpool('close'));
% end
% Note, this is called implicitly in >2014a

fprintf('Compressing %d video files...\n',length(fnames));

parfor i=1:length(fnames)
	loadAndWrite([folder '/' fnames{i}],VERBOSE)	
	% testLoop();
end

fprintf('Done compressing video files\n');
% matlabpool close		% Note, this is called implicitly in >2014a






function loadAndWrite(fullfname,VERBOSE)
load(fullfname);

if ~exist('data','var') || ~exist('metadata','var')	
	return	% Not a normal video file so skip this one
end

[p,basename,ext]=fileparts(fullfname);

writeStimVideo(data,metadata,sprintf('%s/compressed/%s',p,basename));
save(sprintf('%s/compressed/%s_meta',p,basename),'metadata');

if VERBOSE
	fprintf('Compressed file %s written to disk.\n',basename)
end


function testLoop()
	% Do nothing other than delay for a little while
	pause(0.5);


function fnames=getFileNames(fn)
    lg=length(fn);
    fnames=cell(lg,1);
    for i=1:lg,
        fnames{i}=fn(i).name;
    end
    
    
    
        
        
        