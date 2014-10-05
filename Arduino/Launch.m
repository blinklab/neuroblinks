function Launch(rig,cam)
config;

%% Initialize Camera
InitCam(cam, metadata.cam.recdurA); % src and vidobj are now saved as root app data so no global vars

%% -- start serial communication to arduino ---
arduino=serial(comport{rig},'BaudRate',9600);
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



