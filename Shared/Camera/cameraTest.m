function cameraTest()
% Created by Shane Heiney [sheiney@gmail.com]
% This is the main function that will be called to set up the camera and create a basic figure window to show the camera preview 
% If using GenTL do not install gige adaptor as Matlab has a bug when both are enabled (or disable it by renaming the dll, 
% e.g "C:\Program Files\MATLAB\R2013b\toolbox\imaq\imaqadaptors\win64\mwgigeimaq.dll")

% This function call will set up the camera with reasonable defaults
InitCam(1)	% Number specifies which camera to use if multiple cameras connected

hf=figure;
ha=axes;

% Set up preview window
h_preview=image(zeros(480,640),'Parent',ha);

metadata.cam.trialnum=1;	% Normally this whole struct, which contains many fields, would be created by our GUI but I'm just initializing it now so we don't get errors below


setappdata(0,'hf',hf);
setappdata(0,'ha',ha);
setappdata(0,'h_preview',h_preview);
setappdata(0,'metadata',metadata);
setappdata(0,'STREAM',0);
setappdata(0,'PREVIEWING',0);
setappdata(0,'defaultTitle','p: Toggle preview, s: Toggle streaming, t: Start trial, q: Quit');

togglePreview()	% Start previewing video in a Matlab axes

setROI()	% User places im* object (default ellipse) around eye.

% Now just wait for the user to do something
set(hf,'KeyPressFcn',@processKey)
set(hf,'Name',getappdata(0,'defaultTitle'))








function InitCam(ch)
% See Image Acquisition Toolbox documentation for details. Some settings depend on particular camera driver
% Use Universal Library adaptor GIGE in Matlab for best results.

% First delete any existing image acquisition objects
imaqreset

% We use the GenTL driver (camera connected to computer over gigabit ethernet)
disp('creating video object ...')
vidobj = videoinput('gige', ch, 'Mono8');
disp('video settings ....')
src = getselectedsource(vidobj);

% Exposure time is constrained by frame rate
src.ExposureTimeAbs = 4900;		% In microseconds

% Tweak this based on IR light illumination (lower values preferred due to less noise)
if isprop(src,'AllGainRaw')   
    src.AllGainRaw=12;
else
    src.GainRaw=12;
end	

src.PacketSize = 9014;		% Use Jumbo packets (ethernet card must support them) -- apparently not supported in VIMBA
src.StreamBytesPerSecond=115e6; % Set based on AVT's suggestion
src.AcquisitionFrameRateAbs=200;	% Our camera can sustain 200 FPS at full resolution (640x480) but can go up to 500 FPS if you reduce ROI or do vertical binning of frames

vidobj.LoggingMode = 'memory'; 	% Can log straight to disk as well but older versions of Matlab are weird about compression because of licensing of codecs. 
vidobj.FramesPerTrigger=200;		% We trigger for every frame acquired (value of 1) but this is definitely not necessary. You could, e.g. set this value to 200 if you want 1 second of video @ 200 FPS and then just trigger at the beginning

% To trigger using a TTL pulse, which is what we do, you'll want to use the following line instead
% triggerconfig(vidobj, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
% src.FrameStartTriggerMode = 'On';
% src.FrameStartTriggerActivation = 'LevelHigh';
% I'm only using this line for demonstration purposes so that this program can run without external hardware
triggerconfig(vidobj, 'manual');

% Normally, the following two values need to be toggled to switch between preview and acquisition mode, 
% but they're both commented out for now because we're doing manual trigger
% src.FrameStartTriggerSource = 'Line1';
% src.FrameStartTriggerSource = 'Freerun';

%% Save objects to root app data - for ease of passing variables between functions in GUI
setappdata(0,'vidobj',vidobj)
setappdata(0,'src',src)



function streamEyelid()
% This function grabs the current frame from the preview, converts it to a trace, and sends it somewhere else for subsequent control, e.g. TDT hardware.
% For illustration, I'm just sending it to STDOUT but you might want to comment out that line below.

updaterate=0.015;   % ~67 Hz

% Load objects from root app data
vidobj=getappdata(0,'vidobj');
metadata=getappdata(0,'metadata');	% Metadata is just a general purpose struct that holds our trial-by-trial parameters and is saved along with the video data

if getappdata(0,'STREAM') == 0
	setappdata(0,'STREAM',1)
else
	setappdata(0,'STREAM',0)
end


try
    while getappdata(0,'STREAM') == 1 		% STREAM is a flag that corresponds to a toggle button in our GUI.
        tic
        wholeframe=getsnapshot(vidobj);		% This grabs the current frame from the camera
        % We set a binary mask based on the ROI, which can be any arbibrary shape (elliptical seems to work well) and then only 
        % apply the eyelid position algorithm on the ROI region
        % Mask is a logical matrix with the same dimensions as the frame 
        roi=wholeframe.*uint8(metadata.cam.mask); 		% convert to uint8 so we can do element by element matrix multiplication
        % The following line just gives us essentially the area of the eyelid covering the pupil (or the area of whatever is one after thresholding)
        % The reason why this works is because under IR illumination the fur of Black 6 mice appears grayish/white, whereas the pupil and iris are much darker
        eyelidpos=sum(roi(:)>=30);		% Thresh should be an integer between 0 and 255 that is determined empirically (values of 30-40 usually work for us)
       
		% eyelidpos now contains the eyelid trace in raw pixel counts. 
		% At this point we calibrate it based known pixel counts for a fully open and fully closed eye and then send the calibrated trace
		% to our TDT hardware, which monitors things like the "stability" of the eyelid and how open it is in order to determine when to 
		% trigger a trial. 
		% You could also just display it in a rolling Matlab figure window or something....
		% Here I'm just going to dump it to STDOUT, which you probably don't want to do.
		fprintf('Raw eyelid pos pixel count: %d\n',eyelidpos);
        
        t=toc;
        % Ghetto timer - don't rely on Matlab to time things well, even if you use the Java timer (see commented out code section below),
        % because it's limited by the Windows kernel scheduling and is not good for even "pseudo realtime" applications. 
        d=updaterate-t;
        if d>0
            pause(d)        %   java.lang.Thread.sleep(d*1000);     %     drawnow
        else
            % disp(sprintf('%s: Unable to sustain requested stream rate! Loop required %f seconds.',datestr(now,'HH:MM:SS'),t))
        end
    end
catch exception
	% Sometimes we get dropped frames from the camera during "preview" mode, which returns an error code. You can catch the exception and 
	% try to recover, or you can just stop streaming and wait for the user to intervene (usually by just toggling the "preview" mode). 
    disp('Aborted eye streaming.')
    return
end



function togglePreview()

vidobj=getappdata(0,'vidobj');
h_preview=getappdata(0,'h_preview');
PREVIEWING=getappdata(0,'PREVIEWING');

% Start/Stop Camera
if ~PREVIEWING		% PREVIEWING is a flag that in our program corresponds to the state of a toggle button
	% Camera is off. Change button string and start camera.	
	preview(vidobj,h_preview);		% h_preview is an axes handle
	setappdata(0,'PREVIEWING',1);
else
% Camera is on. Stop camera and change button string.
	closepreview(vidobj);
	setappdata(0,'PREVIEWING',0);
end



function setROI()
% I usually include the mouse's entire face in the frame and then select a region of interest corresponding to the eyelid to process with our algorithm. 
% You can put the camera closer and get less of the face but you'll probably still need a crop the image a little using an ROI. 

vidobj=getappdata(0,'vidobj');
metadata=getappdata(0,'metadata');
ha=getappdata(0,'ha');
hf=getappdata(0,'hf');

set(hf,'Name','Resize ROI then double click it to activate')

if isfield(metadata.cam,'winpos')
    winpos=metadata.cam.winpos;
else
    winpos=[0 0 640 480];
end

% Place resizeable ellipse on vidobj
h=imellipse(ha,winpos);
% h=imrect(handles.cameraAx,winpos);	% can alternatively do a rectangle
fcn = makeConstrainToRectFcn('imellipse',get(ha,'XLim'),get(ha,'YLim'));
setPositionConstraintFcn(h,fcn);

XY=round(wait(h));  % only use for imellipse
metadata.cam.winpos=getPosition(h);
metadata.cam.mask=createMask(h);

% Find and remove any previously drawn ROIs in case we're not calling this function for the first time
hp=findobj(ha,'Tag','roipatch');	
delete(hp)

% Remove the im* object and replace it with a patch object to show the bounded region
delete(h);
patch(XY(:,1),XY(:,2),'g','FaceColor','none','EdgeColor','g','Tag','roipatch');

set(hf,'Name',getappdata(0,'defaultTitle'))

setappdata(0,'metadata',metadata);


function startTrial()
% This sets up the camera for a trial but with our normal program the trial doesn't actually start until the camera receives an externally generated trigger - here I'm triggering with software

% Load objects from root app data
src=getappdata(0,'src');
vidobj=getappdata(0,'vidobj');
metadata=getappdata(0,'metadata');
hf=getappdata(0,'hf');


% Set up camera to record
% When we capture a single frame per trigger we need the following two lines of code
% frames_per_trial=ceil(metadata.cam.fps.*(sum(metadata.cam.time))./1000);	% metadata.cam.time is a 3 element vector of [pretime ISI posttime]
% vidobj.TriggerRepeat = frames_per_trial-1;
% Right now I'm just using this because I've already set the camera to acquire 200 frames per trigger, i.e. 1 second of data @ 200 FPS
vidobj.TriggerRepeat = 0;

% This function is called after all of the pre-specified frames have been acquired for a trial. If you don't want to save the data for a particular trial just remove the StopFcn. 
vidobj.StopFcn=@savetrial;	

% Remove any data from buffer before triggering
set(hf,'Name','Acquiring frames')
flushdata(vidobj)
start(vidobj)	% Normally this would put the camera in a ready and waiting state to receive TTL pulses for triggering acquisition, but the line
				% just below is bypassing this and immediately triggering the camera when we start it.
% vidobj.StartFcn = @trigger;
trigger(vidobj)


function processKey(obj,event)


switch event.Key
	case 'p'
		togglePreview()
	case 'r'
		setROI()
	case 's'
		streamEyelid()
	case 't'
		startTrial()
	case 'q'
		quitProgram()
end



function savetrial(obj,event)	
% Callback function when camera stops acquiring frames
% The data and metadata for each trial are saved into an individual MAT file, one file per trial so you'll need a way to increment file names

% Load objects from root app data
vidobj=getappdata(0,'vidobj');
metadata=getappdata(0,'metadata');
hf=getappdata(0,'hf');

data=getdata(vidobj,200);

videoname=sprintf('Trial%03d.mat',metadata.cam.trialnum);

% DATA is a 4D uint8 matrix corresponding to the video frames, metadata is our struct containing per-trial parameters for the camera and stimuli. 
save(videoname,'data','metadata','-v6')

fprintf('Data from trial %03d successfully written to disk.\n',metadata.cam.trialnum)

metadata.cam.trialnum=metadata.cam.trialnum+1;
setappdata(0,'metadata',metadata)
set(hf,'Name',getappdata(0,'defaultTitle'))



function quitProgram()

vidobj=getappdata(0,'vidobj');
hf=getappdata(0,'hf');

stop(vidobj)	% Make sure camera is stopped

delete(vidobj)
close(hf)