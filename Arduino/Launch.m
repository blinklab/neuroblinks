function Launch(rig)

% Load local configuration for these rigs
% Should be somewhere in path but not "neuroblinks" directory or subdirectory
neuroblinks_config;	% Per user settings

% If Neuroblinks is launched from the root directory of the mouse, make a new directory for the session, otherwise leave that up to the user
cwd=regexp(pwd,'\\','split');

configure; % Configuration script

%% make a file to contain this day's notes
% the if statement condtion below was taken from teh configure file. Might make
%   sense to just do this in configure. But I'm not sure configure is on
%   git, so I decided to duplicate it here
notedata.header = {'Subject', 'Event Type', 'Time', 'Trial', 'Comments'};
notedata.subj = cwd{end};
notedata.note = {notedata.subj, 'file made', datestr(now, 'hh:mm:ss'), 0, ''};
if regexp(cwd{end},'[A-Z]\d\d\d')  % Will match anything of the form LDDD, where L is single uppercase letter and DDD is a seq of 3 digits
    thisdate = datestr(now,'yymmdd');
    notedata.filename = strcat(notedata.subj, '_', thisdate, '.csv');
    checkMe = dir('*.csv');
    found = 0;
    for i = 1 : length(checkMe)
        if strcmp(notedata.filename, checkMe(1).name)
            found = 1;
            break
        end
    end
    if found == 1
        display('Warning: Notes file already exists for this mouse.')
    else
        saveme = [notedata.header; notedata.note];
        cell2csv(notedata.filename, saveme)  % this cell2csv function was written by a Matlab user and is located in C:shane\matlab on Sherrington as of 10/7/15
        display('Notes csv created.')
    end
end
setappdata(0, 'notedata', notedata)
clear cwd filename checkMe thisdate mouse found notedata

%% Initialize Camera
InitCam(rig, metadata.cam.recdurA); % src and vidobj are now saved as root app data so no global vars

%% -- start serial communication to arduino ---
com_ports = findArduinos(ARDUINO_IDS);

if isempty(com_ports{rig}),
	error('No Arduino found for requested rig (%d)', rig);
end

arduino=serial(com_ports{rig},'BaudRate',9600);
% arduino.DataTerminalReady='off';	% to prevent resetting Arduino on connect
fopen(arduino);
setappdata(0,'arduino',arduino);

%% Set up timer for eyelid streaming
% 200 Hz timer
% First delete old instances
% t=timerfind('Name','eyelidTimer');
% delete(t)
% eyelidTimer=timer('Name','eyelidTimer','Period',0.005,'ExecutionMode','FixedRate','TimerFcn',@eyelidstream,'BusyMode','drop');

%% make a file for 

%% Open GUI
ghandles.maingui=MainWindow;
set(ghandles.maingui,'units','pixels')
set(ghandles.maingui,'position',[ghandles.pos_mainwin ghandles.size_mainwin])

% Save handles to root app data
setappdata(0,'ghandles',ghandles)



function com_ports = findArduinos(ids)
	com_ports = cell(size(ids));

	% Use external function "listComPorts", which should be in your Windows PATH
	% Download from https://github.com/todbot/usbSearch/
	[status,result]=system('listComPorts');

	% Turn multiline result into list of the lines
	result_list = regexp(result,'\n','split');

	for i=1:length(ids)
	    % Figure out which line the ID appears on...
	    match = strfind(result_list,ids{i});
	    idx = find(~cellfun(@isempty,match));
	    if ~isempty(idx)
	        %...and find the corresponding COM port on that line
	        com_ports{i} = regexp(result_list(idx),'(COM\d+)','match','once');
	    end
	end
