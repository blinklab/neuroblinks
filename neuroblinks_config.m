% Configuration settings that might be different for different users/computers
% Should be somewhere in path but not "neuroblinks" directory or subdirectory

% If you specify a default device here you can launch neuroblinks by simply typing "neuroblinks"
% at the command prompt without needing to specify any arguments. To use a non-default device, 
% launch neuroblinks as for example "neuroblinks('arduino')". 
DEFAULTDEVICE = 'arduino';
% DEFAULTDEVICE = 'tdt';

% Rig number corresponds to the index into ALLOWEDCAMS and ARDUINO_IDS, which is how we match the 
% correct Arduino to the correct camera on multi-rig systems. If you're just using a single rig
% or are using the TDT version (which doesn't support multiple rigs at this time), you can safely
% leave this as is. 
DEFAULTRIG = 1;

% Rig specific settings
ALLOWEDDEVICES = {'arduino','tdt'};

% The ALLOWEDCAMS and ARDUINO_IDS cell arrays are used to match the right Arduino to the
% right camera on computers that are controlling more than one rig. If you are using the 
% TDT version or are only using a single camera/Arduino you can ignore them. 
% Change this string to the unique camera ID of your camera (displayed in AVT Viewer)
% e.g. ALLOWEDCAMS = {'02-2020C-07321','02-2020C-07420'};
% If you only plan to use one camera you can leave it as a blank string as long as you 
% set the variable "cam" to 1 on the "neuroblinks.m" file.
ALLOWEDCAMS = {'02-2020C-06921','02-2020C-06823'};

% If you use Arduino, this list will include the USB IDs for your Arduinos (see comments in MainWindow.m
% for Arduino version for details)
% e.g. ARDUINO_IDS = {'0','753303030353514071B0'};
ARDUINO_IDS = {'0','753303030353514071B0'};

% NOTE: In the future this should be dynamically set based on pre and post time
% For now this variable isn't actually used by TDT version. 
metadata.cam.recdurA=1000;

% --- camera settings ----
% Value is in microseconds and should be slightly less than interframe interval, e.g. 1/200*1e6-100 for 200 FPS
metadata.cam.init_ExposureTime=4900;
metadata.cam.init_GainRaw = 12;

% TDT tank -- not necessary for Arduino version
% The tank should be registered using TankMon (really only matters for TDT version)
tank='conditioning'; 
% tank='optoelectrophys'; 


% GUI
% -- specify the location of bottomleft corner of MainWindow & AnalysisWindow  --
switch lower(DEFAULTDEVICE)
    case 'tdt'
        ghandles.pos_mainwin=[8,450];     ghandles.size_mainwin=[840 720]; 
        ghandles.pos_oneanawin=[8,48];    ghandles.size_oneanawin=[840,364];  
    case 'arduino'
        ghandles.pos_mainwin=[5,550];      ghandles.size_mainwin=[840 600];  
        ghandles.pos_oneanawin=[5 45];    ghandles.size_oneanawin=[560 380];  
end
ghandles.pos_anawin=[470 50];     ghandles.size_anawin=[1030 840]; 
ghandles.pos_lfpwin=[470 50];     ghandles.size_lfpwin=[600 380];

ghandles.shift_for_2nd_rig=[0 -400];

