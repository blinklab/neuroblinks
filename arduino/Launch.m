function Launch(rig,cam)

% Load local configuration for these rigs
% Should be somewhere in path but not "neuroblinks" directory or subdirectory
neuroblinks_config;	% Per user settings
configure; % Configuration script

%% Initialize Camera
InitCam(cam, metadata.cam.recdurA); % src and vidobj are now saved as root app data so no global vars

%% -- start serial communication to arduino ---
disp('Finding Arduino...')
com_ports = findArduinos(ARDUINO_IDS);

if isempty(com_ports{rig}),
	error('No Arduino found for requested rig (%d)', rig);
end

arduino=serial(com_ports{rig},'BaudRate',115200);
arduino.InputBufferSize = 512*8;
% arduino.DataTerminalReady='off';	% to prevent resetting Arduino on connect
fopen(arduino);
setappdata(0,'arduino',arduino);


%% Open GUI
clear MainWindow;    % Need to do this to clear persisent variables defined within MainWindow and subfunctions
ghandles.maingui=MainWindow;
set(ghandles.maingui,'units','pixels')
set(ghandles.maingui,'position',[ghandles.pos_mainwin ghandles.size_mainwin])

% Save handles to root app data
setappdata(0,'ghandles',ghandles)



function com_ports = findArduinos(ids)
com_ports = cell(size(ids));

% Call external function 'wmicGet' to pull in PnP info
infostruct = wmicGet('Win32_PnPEntity');

names={infostruct.Name};  % roll struct field into cell array for easy searching
device_ids={infostruct.DeviceID};  % roll struct field into cell array for easy searching

match = strfind(names,'Arduino');   % All devices with "Arduino" in the name field
idx = find(~cellfun(@isempty,match));

if isempty(idx)
    return
end

arduino_names = names(idx);
arduino_device_ids = device_ids(idx);

for i=1:length(ids)
    % Figure out which line the ID appears on...
    match = strfind(arduino_device_ids,ids{i});
    idx = find(~cellfun(@isempty,match));
    if ~isempty(idx)
        %...and find the corresponding COM port on that line
        com_ports{i} = regexp(arduino_names(idx),'(COM\d+)','match','once');
    end
end
