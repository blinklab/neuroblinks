function InitCam(rig,recdur)

% First delete any existing image acquisition objects
%imaqreset % try commenting out imaqreset and see if you can store the
%camera exposuretime

disp('creating video object ...')
% vidobj = videoinput('gentl', ch, 'Mono8');
ch = 1; % arbitrarily try to connect to the first camera
vidobj = videoinput('gige', ch, 'Mono8');

metadata=getappdata(0,'metadata');
metadata.cam.rignum = rig;
setappdata(0, 'metadata', metadata);  % store the cam number in the metadata
src = getselectedsource(vidobj);
% src.ExposureTimeAbs = metadata.cam.init_ExposureTime;  % commented out to
%   % preservecamera-specific exposure time settings

%% Now, use the exposure time to check which camera you are connected to
% The exposure time on camera 1 should end with 1, and the exposure time on
% camera 2 should end with 2. If it ends with 0 instead, display a video
% stream from the camera and ask the user which rig the video is from. The
% user can check this by 1) making sure that there's something in frame
% that distinguishes the two rigs [e.g., write "o" on the brass headplate
% bar of rig 1 and write "t" on the headplate bar of rig 2] or by 2)
% watching the video stream while moving something in front of the camera.

checkCamRigAssc = num2str(src.ExposureTimeAbs); 
%display(src.ExposureTimeAbs)
checkMe = str2num(checkCamRigAssc(length(checkCamRigAssc))); % pull out the last digit of ExposureTimeAbs
if checkMe == 0 % the camera ID cannot be determined using ExposureTimeAbs
    display('Camera/rig association unknown...')
    preview(vidobj)     % display an image from the rig
    prompt = {'Which rig is this (1/2)?'};
    dlg_title = 'Rig ID';
    num_lines = 1;
    defaultans = {''};
    input = inputdlg(prompt, dlg_title, num_lines, defaultans); % ask the user to say which rig the image is from
    while ~strcmpi(input, '1') && ~strcmpi(input, '2') % your user messed up (assuming you only have 2 rigs connected)
        msgbox('User entered unacceptable input. Please type 1 if the frame is from inside rig 1. Please type 2 if the frame is from inside rig 2. Please type 0 is you would like to see a new frame. No other inputs are accepted.');
        input = inputdlg(prompt, dlg_title, num_lines, defaultans); % make the user enter good input
    end
    
    addme = str2double(input);
    src.ExposureTimeAbs = metadata.cam.init_ExposureTime + addme; % set exposure time for this cam so user doesn't have to verify rig assc again


    rigNum = str2double(input);
    if rigNum - rig ~= 0
        display('Camera was not associated with desired rig.')
        display('Connecting to other camera...')

        % connect to the other camera
        closepreview
        delete(vidobj) % get rid of the old video object
        ch = 2;
        imaqreset
        vidobj = videoinput('gige', ch, 'Mono8');
        metadata=getappdata(0,'metadata');
        src = getselectedsource(vidobj);
        src.ExposureTimeAbs = metadata.cam.init_ExposureTime + rig; % set this camera so that its rig association is encoded by ExposureTimeAbs     
    else
        display('Camera was associated with desired rig.')
        closepreview
    end
elseif checkMe ~= rig
    display('This camera-s exposure time indicates that it is associated with the other rig.')
    display('Connecting to the other camera.')
    ch = 2;
    imaqreset
    vidobj = videoinput('gige', ch, 'Mono8');
    metadata=getappdata(0,'metadata');
    src = getselectedsource(vidobj);
    src.ExposureTimeAbs = metadata.cam.init_ExposureTime;
end

disp('video settings ....')
src.AllGainRaw=12;				% Tweak this based on IR light illumination (lower values preferred due to less noise)
% src.StreamBytesPerSecond=124e6; % Set based on AVT's suggestion
%src.StreamBytesPerSecond=115e6; % Set based on AVT's suggestion
src.StreamBytesPerSecond=80e6; % Shane says

% src.PacketSize = 9014;		% Use Jumbo packets (ethernet card must support them) -- apparently not supported in VIMBA
src.PacketSize = 8228;		% Use Jumbo packets (ethernet card must support them) -- apparently not supported in VIMBA
src.PacketDelay = 2000;		% Calculated based on frame rate and image size using Mathworks helper function
vidobj.LoggingMode = 'memory'; 
src.AcquisitionFrameRateAbs=200;
vidobj.FramesPerTrigger=ceil(recdur/(1000/200));

% triggerconfig(vidobj, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
% set(src,'AcquisitionStartTriggerMode','on')
% set(src,'FrameStartTriggerSource','Freerun')
% set(src,'AcquisitionStartTriggerActivation','RisingEdge')
% set(src,'AcquisitionStartTriggerSource','Line1')

triggerconfig(vidobj, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
src.FrameStartTriggerMode = 'On';
src.FrameStartTriggerActivation = 'LevelHigh';

% This needs to be toggled to switch between preview and acquisition mode
% It is changed to 'Line1' in MainWindow just before triggering Arduino and then
% back to 'Freerun' in 'endOfTrial' function
% src.FrameStartTriggerSource = 'Line1';
src.FrameStartTriggerSource = 'Freerun';

% src.TriggerMode='On';
% src.TriggerSelector='FrameStart';
% src.TriggerSelector='AcquisitionStart';
% src.TriggerSource='Freerun';

%% Save objects to root app data
setappdata(0,'vidobj',vidobj)
setappdata(0,'src',src)
