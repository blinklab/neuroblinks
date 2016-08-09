function InitCam(ch,recdur)

ADAPTER = 'gentl'; % or 'gige'

% First delete any existing image acquisition objects
imaqreset

disp('Creating video object ...')
vidobj = videoinput(ADAPTER, ch, 'Mono8');

metadata=getappdata(0,'metadata');
src = getselectedsource(vidobj);
src.ExposureTimeAbs = metadata.cam.init_ExposureTime;

if isprop(src,'AllGainRaw')   % Tweak this based on IR light illumination (lower values preferred due to less noise)
    src.AllGainRaw=12;
else
    src.GainRaw=12;
end

src.StreamBytesPerSecond=80e6; % Set based on AVT's suggestion

if strcmpi(ADAPTER,'gige')
    src.PacketSize = 9014;        % Use Jumbo packets (ethernet card must support them) -- apparently not supported in VIMBA
    src.PacketDelay = 2000;     % Calculated based on frame rate and image size using Mathworks helper function
end

vidobj.LoggingMode = 'memory'; 
src.AcquisitionFrameRateAbs=200;
vidobj.FramesPerTrigger=ceil(recdur/(1000/200));

triggerconfig(vidobj, 'hardware', 'DeviceSpecific', 'DeviceSpecific');

% This needs to be toggled to switch between preview and acquisition mode
% It is changed to 'Line1' in MainWindow just before triggering Arduino and then
% back to 'Freerun' in 'endOfTrial' function
if isprop(src,'FrameStartTriggerMode')
    src.FrameStartTriggerMode = 'On';
    src.FrameStartTriggerActivation = 'LevelHigh';
    src.FrameStartTriggerSource = 'Freerun';
else
    src.TriggerMode = 'On';
    src.TriggerActivation = 'LevelHigh';
    src.TriggerSource = 'Freerun';
end

%% Save objects to root app data
setappdata(0,'vidobj',vidobj)
setappdata(0,'src',src)
