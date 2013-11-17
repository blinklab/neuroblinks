function InitCamA(ch,recdur)

% First delete any existing image acquisition objects
% imaqreset

disp('creating video object ...')
vidobj = videoinput('gige', ch, 'Mono8');
disp('video settings ....')

metadata=getappdata(0,'metadata');
src = getselectedsource(vidobj);
src.ExposureTimeAbs = metadata.cam.init_ExposureTime;
% src.AllGainRaw=12;

src.PacketSize = '9014';
vidobj.LoggingMode = 'memory'; 
src.AcquisitionFrameRateAbs=200;
vidobj.FramesPerTrigger=ceil(recdur/(1000/200));

triggerconfig(vidobj, 'hardware', 'RisingEdge', 'Line1-AcquisitionStart');

%% Save objects to root app data
setappdata(0,'vidobj',vidobj)
setappdata(0,'src',src)
