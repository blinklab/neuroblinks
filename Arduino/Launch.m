function Launch(rig,cam)

% Load local configuration for these rigs
% Should be somewhere in path but not "neuroblinks" directory or subdirectory
neuroblinks_config;	% Per user settings
configure; % Configuration script

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
