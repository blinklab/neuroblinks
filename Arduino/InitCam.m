function InitCam(ch,recdur)

% First delete any existing image acquisition objects
imaqreset

disp('creating video object ...')
% vidobj = videoinput('gentl', ch, 'Mono8');
vidobj = videoinput('gige', ch, 'Mono8');
disp('video settings ....')

metadata=getappdata(0,'metadata');
src = getselectedsource(vidobj);
src.ExposureTimeAbs = metadata.cam.init_ExposureTime;

% Tweak this based on IR light illumination (lower values preferred due to less noise)
if isprop(src,'AllGainRaw')
    src.AllGainRaw=12;
else
    src.GainRaw=12;
end
				
% src.StreamBytesPerSecond=124e6; % Set based on AVT's suggestion
src.StreamBytesPerSecond=115e6; % Set based on AVT's suggestion

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

if isprop(src,'FrameStartTriggerMode')
    src.FrameStartTriggerMode = 'On';
    src.FrameStartTriggerActivation = 'LevelHigh';
    src.FrameStartTriggerSource = 'Freerun';
else
    src.TriggerMode = 'On';
    src.TriggerActivation = 'LevelHigh';
    src.TriggerSource = 'Freerun';
end

% This needs to be toggled to switch between preview and acquisition mode
% It is changed to 'Line1' in MainWindow just before triggering Arduino and then
% back to 'Freerun' in 'endOfTrial' function
% src.FrameStartTriggerSource = 'Line1';

% src.TriggerMode='On';
% src.TriggerSelector='FrameStart';
% src.TriggerSelector='AcquisitionStart';
% src.TriggerSource='Freerun';

%% Save objects to root app data
setappdata(0,'vidobj',vidobj)
setappdata(0,'src',src)
