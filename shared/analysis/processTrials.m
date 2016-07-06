function trials=processTrials(folder,calib,varargin)
% TRIALS=processConditioningTrials(FOLDER,CALIB,{MAXFRAMES})
% Return trials structure containing eyelid data and trial parameters for all trials in a session
% Specify either filename of trial to use for calibration or "calib" structure containing pre-calculated scale and offset.
% Optionally, specify threshold for binary image and maximum number of video frames per trial to use for extracting eyelid trace


if length(varargin) > 0
	thresh=varargin{1};
end

% Error checking
if isstruct(calib)
	if ~isfield(calib,'scale') || ~isfield(calib,'offset')
		error('You must specify a valid calibration structure or file from which the structure can be computed')
	end
elseif exist(calib,'file')
	[data,metadata]=loadCompressed(calib);
	if ~exist('thresh')
		thresh=metadata.cam.thresh;
	end
	[y,t]=vid2eyetrace(data,metadata,thresh,5);
	calib=getcalib(y,40,50);
else
	error('You must specify a valid calibration structure or file from which the structure can be computed')
end

% By now we should have a valid calib structure to use for calibrating all files

if ~exist(folder,'dir')
	error('The directory you specified (%s) does not exist',folder);
end

% Get our directory listing, assuming the only AVI files containined in the directory are the trials
% Later we will sort out those that aren't type='conditioning' based on metadata
% fnames=getFullFileNames(folder,dir(fullfile(folder,'*.avi')));
fnames=getFullFileNames(folder,dir(fullfile(folder,'*.mp4')));

% Preallocate variables so we can use parfor loop to process the files
eyelidpos=cell(length(fnames),1);	% We have to use a cell array because trials may have different lengths
tm=cell(length(fnames),1);			% Same for time

c_isi=NaN(length(fnames),1);
c_csnum=NaN(length(fnames),1);
c_csdur=NaN(length(fnames),1);
c_usnum=NaN(length(fnames),1);
c_usdur=NaN(length(fnames),1);

trialnum=zeros(length(fnames),1);
ttype=cell(length(fnames),1);

numframes=zeros(length(fnames),1);

% % Use a parallel for loop to speed things up
% if matlabpool('size') == 0
%     matlabpool open	% Start a parallel computing pool using default number of labs (usually 4-8).
% %     cleaner = onCleanup(@() matlabpool('close'));
% end


parfor i=1:length(fnames)

	[p,basename,ext]=fileparts(fnames{i});

    try
        [data,metadata]=loadCompressed(fnames{i});
    catch
        disp(sprintf('Problem with file %s', fnames{i}))
    end
    
    [eyelidpos{i},tm{i}]=vid2eyetrace(data,metadata,thresh,5,calib);

	c_isi(i)=metadata.stim.c.isi;
	c_csnum(i)=metadata.stim.c.csnum;
	c_csdur(i)=metadata.stim.c.csdur;
	c_usnum(i)=metadata.stim.c.usnum;
	c_usdur(i)=metadata.stim.c.usdur;
	
	trialnum(i)=metadata.cam.trialnum;
	ttype{i}=metadata.stim.type;

	numframes(i)=length(eyelidpos{i});

	fprintf('Processed file %s\n',basename)
	
end


disp('Done reading data')

% matlabpool close

if length(varargin) > 1
	MAXFRAMES=varargin{2};
else
	MAXFRAMES=max(numframes);
end

% Now that we know how long each trial is turn the cell arrays into matrices

traces=NaN(length(fnames),MAXFRAMES);
times=NaN(length(fnames),MAXFRAMES);
try
	for i=1:length(fnames) 
		trace=eyelidpos{i}; 
		t=tm{i}; 
		en=length(trace); 
		if en > MAXFRAMES
			en=MAXFRAMES; 
		end 
		traces(i,1:en)=trace(1:en); 
		times(i,1:en)=t(1:en); 
	end
catch
    disp(i)
end

sess_cell = regexp(fnames,'_[sS](\d\d)_','tokens','once');
session_of_day = cellfun(@str2double, sess_cell);

trials.eyelidpos=traces;
trials.tm=times;
trials.fnames=fnames;

trials.c_isi=c_isi;
trials.c_csnum=c_csnum;
trials.c_csdur=c_csdur;
trials.c_usnum=c_usnum;
trials.c_usdur=c_usdur;

trials.trialnum=trialnum;
trials.type=ttype;
trials.session_of_day=session_of_day;