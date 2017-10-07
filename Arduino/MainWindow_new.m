function varargout = MainWindow_new(varargin)
% MAINWINDOW_NEW MATLAB code for MainWindow_new.fig
%      MAINWINDOW_NEW, by itself, creates a new MAINWINDOW_NEW or raises the existing
%      singleton*.
%
%      H = MAINWINDOW_NEW returns the handle to a new MAINWINDOW_NEW or the handle to
%      the existing singleton*.
%
%      MAINWINDOW_NEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINWINDOW_NEW.M with the given input arguments.
%
%      MAINWINDOW_NEW('Property','Value',...) creates a new MAINWINDOW_NEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainWindow_new_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainWindow_new_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainWindow_new

% Last Modified by GUIDE v2.5 14-Nov-2015 13:46:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainWindow_new_OpeningFcn, ...
                   'gui_OutputFcn',  @MainWindow_new_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%% STUFF THAT WAS IN PREVIOUS VERSION OF MAINWINDOW


% --- Executes just before MainWindow is made visible.
function MainWindow_new_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% varargin   command line arguments to MainWindow (see VARARGIN)

% Choose default command line output for MainWindow
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MainWindow wait for user response (see UIRESUME)
% uiwait(handles.MainFig);
src=getappdata(0,'src');
metadata=getappdata(0,'metadata');
metadata.date=date;
metadata.TDTblockname='TempBlk';
set(handles.text_status,'String',sprintf('Basename for session:\n%s',metadata.TDTblockname))
metadata.ts=[datenum(clock) 0]; % two element vector containing datenum at beginning of session and offset of current trial (in seconds) from beginning
metadata.folder=pwd; % For now use current folder as base; will want to change this later

metadata.cam.fps=src.AcquisitionFrameRateAbs; %in frames per second
metadata.cam.thresh=0.125;
metadata.cam.trialnum=1;
metadata.eye.trialnum1=1;  %  for conditioning
metadata.eye.trialnum2=1;

typestring=get(handles.popupmenu_stimtype,'String');
metadata.stim.type=typestring{get(handles.popupmenu_stimtype,'Value')};

% Set ITI using base time plus optional random range
% We have to initialize here because "stream" function uses metadata.stim.c.ITI
base_ITI = str2double(get(handles.edit_ITI,'String'));
rand_ITI = str2double(get(handles.edit_ITI_rand,'String'));
metadata.stim.c.ITI = base_ITI + rand(1,1) * rand_ITI;

metadata.cam.time(1)=str2double(get(handles.edit_pretime,'String'));
metadata.cam.time(3)=metadata.cam.recdurA-metadata.cam.time(1);
metadata.cam.cal=0;
metadata.cam.calib_offset=0;
metadata.cam.calib_scale=1;

trials.stimnum=0;
trials.savematadata=0;

setappdata(0,'metadata',metadata);
setappdata(0,'trials',trials);

% Open parameter dialog
h=ParamsWindow;
waitfor(h);

% pushbutton_StartStopPreview_Callback(handles.pushbutton_StartStopPreview, [], handles)

% --- Executes on button press in pushbutton_StartStopPreview.
function pushbutton_StartStopPreview_Callback(hObject, eventdata, handles)

vidobj=getappdata(0,'vidobj');
metadata=getappdata(0,'metadata');

if ~isfield(metadata.cam,'fullsize')
    metadata.cam.fullsize = [0 0 640 480];
end
metadata.cam.vidobj_ROIposition=vidobj.ROIposition;

% Start/Stop Camera
if strcmp(get(handles.pushbutton_StartStopPreview,'String'),'Start Preview')
    % Camera is off. Change button string and start camera.
    set(handles.pushbutton_StartStopPreview,'String','Stop Preview')
    % Send camera preview to GUI
    imx=metadata.cam.vidobj_ROIposition(1)+[1:metadata.cam.vidobj_ROIposition(3)];
    imy=metadata.cam.vidobj_ROIposition(2)+[1:metadata.cam.vidobj_ROIposition(4)];
    handles.pwin=image(imx,imy,zeros(metadata.cam.vidobj_ROIposition([4 3])), 'Parent',handles.cameraAx);

    preview(vidobj,handles.pwin);
    set(handles.cameraAx,'XLim', 0.5+metadata.cam.fullsize([1 3])),
    set(handles.cameraAx,'YLim', 0.5+metadata.cam.fullsize([2 4])),
    hp=findobj(handles.cameraAx,'Tag','roipatch');  delete(hp)
    if isfield(handles,'XY')
        handles.roipatch=patch(handles.XY(:,1),handles.XY(:,2),'g','FaceColor','none','EdgeColor','g','Tag','roipatch');
    end
else
    % Camera is on. Stop camera and change button string.
    set(handles.pushbutton_StartStopPreview,'String','Start Preview')
    closepreview(vidobj);
end

setappdata(0,'metadata',metadata);
guidata(hObject,handles)






% vidobj=getappdata(0,'vidobj');
% metadata=getappdata(0,'metadata');
%
% if isfield(metadata.cam,'fullsize')
%     metadata.cam.fullsize = vidobj.ROIposition;
% end
%
% if strcmp(get(handles.pushbutton_StartStopPreview,'String'),'Start Preview')
%     % Camera is off. Change button string and start camera.
%     set(handles.pushbutton_StartStopPreview,'String','Stop Preview')
%     handles.pwin=image(zeros(480,640),'Parent',handles.cameraAx);
%     preview(vidobj,handles.pwin);
% else
%     % Camera is on. Stop camera and change button string.
%     set(handles.pushbutton_StartStopPreview,'String','Start Preview')
%     closepreview(vidobj);
% end
% setappdata(0,'metadata',metadata);
% guidata(hObject,handles)


function pushbutton_quit_Callback(hObject, eventdata, handles)
vidobj=getappdata(0,'vidobj');
ghandles=getappdata(0,'ghandles');
metadata=getappdata(0,'metadata');
arduino=getappdata(0,'arduino');

button=questdlg('Are you sure you want to quit?','Quit?');
if ~strcmpi(button,'Yes')
    return
end

set(handles.togglebutton_stream,'Value',0);

try
    fclose(arduino);
    delete(arduino);
    delete(vidobj);
    rmappdata(0,'src');
    rmappdata(0,'vidobj');
catch err
    warning(err.identifier,'Problem cleaning up objects. You may need to do it manually.')
end
delete(handles.MainFig)

pause(0.5)

button=questdlg('Do you want to compress the videos from this session?');
if strcmpi(button,'Yes')
    makeCompressedVideos(metadata.folder,1);
end

% --- Outputs from this function are returned to the command line.
function varargout = MainWindow_new_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;


function MainFig_KeyPressFcn(hObject, eventdata, handles)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
switch eventdata.Character
    case '`'
        pushbutton_stim_Callback(hObject, eventdata, handles);
    otherwise
        return
end


function pushbutton_setROI_Callback(hObject, eventdata, handles)

vidobj=getappdata(0,'vidobj');   metadata=getappdata(0,'metadata');

if isfield(metadata.cam,'winpos')
    winpos=metadata.cam.winpos;
    winpos(1:2)=winpos(1:2)+metadata.cam.vidobj_ROIposition(1:2);
else
    winpos=[0 0 640 480];
end

% Place rectangle on vidobj
% h=imrect(handles.cameraAx,winpos);
h=imellipse(handles.cameraAx,winpos);

% fcn = makeConstrainToRectFcn('imrect',get(handles.cameraAx,'XLim'),get(handles.cameraAx,'YLim'));
fcn = makeConstrainToRectFcn('imellipse',get(handles.cameraAx,'XLim'),get(handles.cameraAx,'YLim'));
setPositionConstraintFcn(h,fcn);

% metadata.cam.winpos=round(wait(h));
XY=round(wait(h));  % only use for imellipse
metadata.cam.winpos=round(getPosition(h));
metadata.cam.winpos(1:2)=metadata.cam.winpos(1:2)-metadata.cam.vidobj_ROIposition(1:2);
metadata.cam.mask=createMask(h);

wholeframe=getsnapshot(vidobj);
binframe=im2bw(wholeframe,metadata.cam.thresh);
eyeframe=binframe.*metadata.cam.mask;
metadata.cam.pixelpeak=sum(sum(eyeframe));

hp=findobj(handles.cameraAx,'Tag','roipatch');
delete(hp)
% handles.roipatch=patch([xmin,xmin+width,xmin+width,xmin],[ymin,ymin,ymin+height,ymin+height],'g','FaceColor','none','EdgeColor','g','Tag','roipatch');
% XY=getVertices(h);
delete(h);
handles.roipatch=patch(XY(:,1),XY(:,2),'g','FaceColor','none','EdgeColor','g','Tag','roipatch');
handles.XY=XY;

setappdata(0,'metadata',metadata);
guidata(hObject,handles)

% take note of ROI set
notedata = getappdata(0, 'notedata');
notedata.note{1,2} = 'ROI set';
notedata.note{1,3} = datestr(now, 'hh:MM:ss');
trials=getappdata(0,'trials');
try
    notedata.note{1,4} = trials.stimnum;
catch ME
    notedata.note{1,4} = 1;
end
notedata.note{1,5} = 'ROI set';
setappdata(0, 'notedata', notedata)
appendcell2csv(notedata.filename,notedata.note);











% vidobj=getappdata(0,'vidobj');  metadata=getappdata(0,'metadata');
% if isfield(metadata.cam,'winpos')
%     winpos=metadata.cam.winpos;
% else
%     winpos=[0 0 640 480];
% end
% h=imellipse(handles.cameraAx,winpos);
% fcn = makeConstrainToRectFcn('imellipse',get(handles.cameraAx,'XLim'),get(handles.cameraAx,'YLim'));
% setPositionConstraintFcn(h,fcn);
%
% % metadata.cam.winpos=round(wait(h));
% XY=round(wait(h));  % only use for imellipse
% metadata.cam.winpos=getPosition(h);
% metadata.cam.mask=createMask(h);
%
% wholeframe=getsnapshot(vidobj);
% binframe=im2bw(wholeframe,metadata.cam.thresh);
% eyeframe=binframe.*metadata.cam.mask;
% metadata.cam.pixelpeak=sum(sum(eyeframe));
%
% hp=findobj(handles.cameraAx,'Tag','roipatch');
% delete(hp)
%
% delete(h);
% handles.roipatch=patch(XY(:,1),XY(:,2),'g','FaceColor','none','EdgeColor','g','Tag','roipatch');
%
% setappdata(0,'metadata',metadata);
% guidata(hObject,handles)


function pushbutton_CalbEye_Callback(hObject, eventdata, handles)
metadata=getappdata(0,'metadata');
metadata.cam.cal=1;
setappdata(0,'metadata',metadata);

refreshPermsA(handles);
sendto_arduino();

metadata=getappdata(0,'metadata');
vidobj=getappdata(0,'vidobj');
vidobj.TriggerRepeat = 0;
vidobj.StopFcn=@CalbEye;   % this will be executed after timer stop
flushdata(vidobj);         % Remove any data from buffer before triggering

% Set camera to hardware trigger mode
src.FrameStartTriggerSource = 'FixedRate';
start(vidobj)

metadata.cam.cal=0;
metadata.ts(2)=etime(clock,datevec(metadata.ts(1)));
% --- trigger via arduino --
arduino=getappdata(0,'arduino');
fwrite(arduino,1,'int8');

% take note of calibration trial
notedata = getappdata(0, 'notedata');
notedata.note{1,2} = 'Puff';
notedata.note{1,3} = datestr(now, 'hh:MM:ss');
trials=getappdata(0,'trials');
try
    notedata.note{1,4} = trials.stimnum;
catch ME
    notedata.note{1,4} = 1;
end
notedata.note{1,5} = 'Calibration puff delivered';
setappdata(0, 'notedata', notedata)
appendcell2csv(notedata.filename,notedata.note);

setappdata(0,'metadata',metadata);


% --- Executes on button press in togglebutton_tgframerate.
function togglebutton_tgframerate_Callback(hObject, eventdata, handles)

vidobj=getappdata(0,'vidobj');
src=getappdata(0,'src');
metadata=getappdata(0,'metadata');

if get(hObject,'Value')
    % Turn on high frame rate mode
    metadata.cam.vidobj_ROIposition=max(metadata.cam.winpos+[-10 0 20 0],[0 0 0 0]);
    vidobj.ROIposition=metadata.cam.vidobj_ROIposition;
%     metadata.cam.fps=500;
    src.ExposureTimeAbs = 1900 + metadata.cam.rignum;  % add rig number so exposure time remains reliable indicator of camera-rig assc.
%     src.AllGainRaw=metadata.cam.init_AllGainRaw+round(20*log10(metadata.cam.init_ExposureTime/src.ExposureTimeAbs));
    % --- size fit for roi and mask ----
    vidroi_x=metadata.cam.vidobj_ROIposition(1)+[1:metadata.cam.vidobj_ROIposition(3)];
    vidroi_y=metadata.cam.vidobj_ROIposition(2)+[1:metadata.cam.vidobj_ROIposition(4)];
    metadata.cam.mask = metadata.cam.mask(vidroi_y, vidroi_x);
    metadata.cam.winpos(1:2)=metadata.cam.winpos(1:2)-metadata.cam.vidobj_ROIposition(1:2);
else
    % Turn off high frame rate mode
    vidobj.ROIposition=metadata.cam.fullsize;
%     metadata.cam.fps=200;
    src.ExposureTimeAbs = metadata.cam.init_ExposureTime + metadata.cam.rignum;  % add rig number so exposure time remains reliable indicator of camera-rig assc.
%     src.AllGainRaw=metadata.cam.init_AllGainRaw;
    % --- size fit for roi and mask ----
    mask0=metadata.cam.mask; s_mask0=size(mask0);
    metadata.cam.mask = false(metadata.cam.fullsize([4 3]));
    metadata.cam.mask(metadata.cam.vidobj_ROIposition(2)+[1:s_mask0(1)], metadata.cam.vidobj_ROIposition(1)+[1:s_mask0(2)])=mask0;
    metadata.cam.winpos(1:2)=metadata.cam.winpos(1:2)+metadata.cam.vidobj_ROIposition(1:2);
    metadata.cam.vidobj_ROIposition=metadata.cam.fullsize;
end

pushbutton_StartStopPreview_Callback(handles.pushbutton_StartStopPreview, [], handles)
pause(0.02)
pushbutton_StartStopPreview_Callback(handles.pushbutton_StartStopPreview, [], handles)

setappdata(0,'vidobj',vidobj);
setappdata(0,'src',src);
setappdata(0,'metadata',metadata);





% vidobj=getappdata(0,'vidobj');
% src=getappdata(0,'src');
% metadata=getappdata(0,'metadata');
%
% if get(hObject,'Value')
%     % Turn on high frame rate mode
%     vidobj.ROIposition=metadata.cam.winpos;
% %     metadata.cam.fps=500;
%     src.ExposureTimeAbs = 1900;
% %     src.AllGainRaw=round(12*4900/1900);
% else
%     % Turn off high frame rate mode
%     vidobj.ROIposition=metadata.cam.fullsize;
% %     metadata.cam.fps=200;
%     src.ExposureTimeAbs = 4900;
% %     src.AllGainRaw=12;
% end
%
% setappdata(0,'vidobj',vidobj);
% setappdata(0,'src',src);
% setappdata(0,'metadata',metadata);



function checkbox_record_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.checkbox_record,'BackgroundColor',[0 1 0]); % green
else
    set(handles.checkbox_record,'BackgroundColor',[1 0 0]); % red
end


function pushbutton_instantreplay_Callback(hObject, eventdata, handles)
instantReplay(getappdata(0,'lastdata'),getappdata(0,'lastmetadata'));


function toggle_continuous_Callback(hObject, eventdata, handles)
if get(hObject,'Value'),
    set(hObject,'String','Pause Continuous')
    comment = 'Start Continuous';
else
    set(hObject,'String','Start Continuous')
    comment = 'Pause Continuous';
end

% take note of toggling continuous session
notedata = getappdata(0, 'notedata');
notedata.note{1,2} = 'Toggle trial mode';
notedata.note{1,3} = datestr(now, 'hh:MM:ss');
trials=getappdata(0,'trials');
try
    notedata.note{1,4} = trials.stimnum;
catch ME
    notedata.note{1,4} = 1;
end
notedata.note{1,5} = comment;
setappdata(0, 'notedata', notedata)
appendcell2csv(notedata.filename,notedata.note);


function pushbutton_stim_Callback(hObject, eventdata, handles)
TriggerArduino(handles)

% take note of stimulus delivered
notedata = getappdata(0, 'notedata');
notedata.note{1,2} = 'Puff';
notedata.note{1,3} = datestr(now, 'hh:MM:ss');
trials=getappdata(0,'trials');
try
    notedata.note{1,4} = trials.stimnum + 1;
catch ME
    notedata.note{1,4} = 1;
end  % assume the user is interested in the trial that just happened
notedata.note{1,5} = 'User delivered single trial manually';
setappdata(0, 'notedata', notedata)
appendcell2csv(notedata.filename,notedata.note);

function popupmenu_stimtype_Callback(hObject, eventdata, handles)
% --- updating metadata ---
metadata=getappdata(0,'metadata');
val=get(hObject,'Value');
str=get(hObject,'String');
metadata.stim.type=str{val};
setappdata(0,'metadata',metadata);

% ------ highlight for uipanel -----
set(handles.uipanel_puff,'BackgroundColor',[240 240 240]/255);
set(handles.uipanel_conditioning,'BackgroundColor',[240 240 240]/255);
switch lower(metadata.stim.type)
    case 'puff'
        set(handles.uipanel_puff,'BackgroundColor',[225 237 248]/255); % light blue
    case 'conditioning'
        set(handles.uipanel_conditioning,'BackgroundColor',[225 237 248]/255); % light blue
end


function togglebutton_stream_Callback(hObject, eventdata, handles)

if get(hObject,'Value'),
    set(hObject,'String','Stop Streaming')
    stream(handles)
else
    set(hObject,'String','Start Streaming')
end


function pushbutton_params_Callback(hObject, eventdata, handles)
ParamsWindow


function uipanel_TDTMode_SelectionChangeFcn(hObject, eventdata, handles)
% switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
%     case 'togglebutton_NewSession'
%         dlgans = inputdlg({'Enter session name'},'Create');
%         if isempty(dlgans)
%             ok=0;
%         elseif isempty(dlgans{1})
%             ok=0;
%         else
%             ok=1;  session=dlgans{1};
%             set(handles.checkbox_save_metadata,'Value',0);
%         end
%         % take note of new seesion pushed
%         notedata = getappdata(0, 'notedata');
%         notedata.note{1,2} = 'Session';
%         notedata.note{1,3} = datestr(now, 'hh:MM:ss');
%         try
%             nextTrial = metadata.eye.trialnum1;
%         catch ME
%             nextTrial = 1;
%         end
%         notedata.note{1,4} = nextTrial - 1;  % assume the user is interested in the trial that just happened
%         notedata.note{1,5} = 'New Session pressed';
%         setappdata(0, 'notedata', notedata)
%         appendcell2csv(notedata.filename,notedata.note);
%     case 'togglebutton_StopSession'
%         button=questdlg('Are you sure you want to stop this session?','Yes','No');
%         if ~strcmpi(button,'Yes')
%             ok=0;
%         else
%             session='s00';     ok=1;
%         end
%         % take note of new seesion pushed
%         notedata = getappdata(0, 'notedata');
%         notedata.note{1,2} = 'Session';
%         notedata.note{1,3} = datestr(now, 'hh:MM:ss');
%         try
%             nextTrial = metadata.eye.trialnum1;
%         catch ME
%             nextTrial = 1;
%         end
%         notedata.note{1,4} = nextTrial - 1;  % assume the user is interested in the trial that just happened
%         notedata.note{1,5} = 'Stop Session pressed';
%         setappdata(0, 'notedata', notedata)
%         appendcell2csv(notedata.filename,notedata.note);
%     otherwise
%         warndlg('There is something wrong with the mode selection callback','Mode Select Problem!')
%         return
% end
%
% if ok
%     set(eventdata.NewValue,'Value',1);
%     set(eventdata.OldValue,'Value',0);
%     set(handles.uipanel_TDTMode,'SelectedObject',eventdata.NewValue);
% else
%     set(eventdata.NewValue,'Value',0);
%     set(eventdata.OldValue,'Value',1);
%     set(handles.uipanel_TDTMode,'SelectedObject',eventdata.OldValue);
%     return
% end
% ResetCamTrials()
% set(handles.edit_SessionName,'String',session);
% metadata=getappdata(0,'metadata');
% metadata.TDTblockname=sprintf('%s_%s_%s', metadata.mouse, datestr(now,'yymmdd'),session);
% set(handles.text_status,'String',sprintf('Basename for session:\n%s',metadata.TDTblockname))
% setappdata(0,'metadata',metadata);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% user defined functions %%%%%%%%%%%%%%%%%

function refreshPermsA(handles)
metadata=getappdata(0,'metadata');
trials=getappdata(0,'trials');

trials.savematadata=get(handles.checkbox_save_metadata,'Value');
val=get(handles.popupmenu_stimtype,'Value');
str=get(handles.popupmenu_stimtype,'String');
metadata.stim.type=str{val};
if metadata.cam.cal, metadata.stim.type='Puff'; end % for Cal

metadata.stim.c.csdur=0;
metadata.stim.c.csnum=0;
metadata.stim.c.csint=0;
metadata.stim.c.isi=0;
metadata.stim.c.usdur=0;
metadata.stim.c.usnum=0;
metadata.stim.c.cstone=[0 0];

metadata.stim.l.delay=0;
metadata.stim.l.dur=0;
metadata.stim.l.amp=0;
metadata.stim.l.freq = 0;
metadata.stim.l.pulsewidth = 0;

metadata.stim.p.puffdur=str2double(get(handles.edit_puffdur,'String'));

switch lower(metadata.stim.type)
    case 'none'
        metadata.stim.totaltime=0;
    case 'puff'
        metadata.stim.totaltime=metadata.stim.p.puffdur;
    case 'conditioning'
        trialvars=readTrialTable(metadata.eye.trialnum1);
        metadata.stim.c.csdur=trialvars(1);
        metadata.stim.c.csnum=trialvars(2);
        metadata.stim.c.csint=trialvars(3);
        metadata.stim.c.isi=trialvars(4);
        metadata.stim.c.usdur=trialvars(5);
        metadata.stim.c.usnum=trialvars(6);
        metadata.stim.c.cstone=str2num(get(handles.edit_tone,'String'))*1000;
        if length(metadata.stim.c.cstone)<2, metadata.stim.c.cstone(2)=0; end
        metadata.stim.totaltime=metadata.stim.c.isi+metadata.stim.c.usdur;
        metadata.stim.l.delay = trialvars(7);
        metadata.stim.l.dur = trialvars(8);
        metadata.stim.l.amp = trialvars(9);
        metadata.stim.l.freq = trialvars(10);
        metadata.stim.l.pulsewidth = trialvars(11);
    otherwise
        metadata.stim.totaltime=0;
        warning('Unknown stimulation mode set.');
end

% Set ITI using base time plus optional random range
base_ITI = str2double(get(handles.edit_ITI,'String'));
rand_ITI = str2double(get(handles.edit_ITI_rand,'String'));
metadata.stim.c.ITI = base_ITI + rand(1,1) * rand_ITI;

metadata.cam.time(1)=str2double(get(handles.edit_pretime,'String'));
metadata.cam.time(2)=metadata.stim.totaltime;
metadata.cam.time(3)=str2double(get(handles.edit_posttime,'String'))-metadata.stim.totaltime;

metadata.now=now;

setappdata(0,'metadata',metadata);
setappdata(0,'trials',trials);


function sendto_arduino()
metadata=getappdata(0,'metadata');
config=getappdata(0,'config');
datatoarduino=zeros(1,10);

datatoarduino(3)=metadata.cam.time(1);
datatoarduino(9)=sum(metadata.cam.time(2:3));
if strcmpi(metadata.stim.type, 'puff')
    datatoarduino(6)=metadata.stim.p.puffdur;
    datatoarduino(10)=3;    % This is the puff channel
elseif  strcmpi(metadata.stim.type, 'conditioning')
    datatoarduino(4)=metadata.stim.c.csnum;
    datatoarduino(5)=metadata.stim.c.csdur;
    datatoarduino(6)=metadata.stim.c.usdur;
    datatoarduino(7)=metadata.stim.c.isi;
    if ismember(metadata.stim.c.csnum,[5 6]),
        datatoarduino(8)=metadata.stim.c.cstone(metadata.stim.c.csnum-4);
    end
    if ismember(metadata.stim.c.usnum,[5 6]),
        datatoarduino(8)=metadata.stim.c.cstone(metadata.stim.c.usnum-4);
    end
    datatoarduino(10)=metadata.stim.c.usnum;
    datatoarduino(11)=metadata.stim.l.delay;
    datatoarduino(12)=metadata.stim.l.pulsewidth;
    datatoarduino(13)=metadata.stim.l.amp;
    datatoarduino(14)=metadata.stim.c.csint;
    datatoarduino(15)=round(1./metadata.stim.l.freq.*1e3);
    datatoarduino(16)=round(metadata.stim.l.freq .* (metadata.stim.l.dur ./ 1e3));
    datatoarduino(17)=config.laser.gain;
    datatoarduino(18)=config.laser.offset;
end

% ---- send data to arduino ----
arduino=getappdata(0,'arduino');
for i=3:length(datatoarduino),
    fwrite(arduino,i,'int8');                  % header
    fwrite(arduino,datatoarduino(i),'int16');  % data
    if mod(i,4)==0,
        pause(0.010);
    end
end


function TriggerArduino(handles)
refreshPermsA(handles)
sendto_arduino()

metadata=getappdata(0,'metadata');
vidobj=getappdata(0,'vidobj');
src=getappdata(0,'src');
vidobj.TriggerRepeat = 0;

vidobj.StopFcn=@endOfTrial;

flushdata(vidobj); % Remove any data from buffer before triggering

% Set camera to hardware trigger mode
if isprop(src, 'FrameStartTriggerSource')
    src.FrameStartTriggerSource = 'FixedRate';
else
    src.TriggerSource = 'FixedRate';
end
vidobj.FramesPerTrigger=metadata.cam.fps*(sum(metadata.cam.time)/1e3);

% Now get camera ready for acquisition -- shouldn't start yet
start(vidobj)

metadata.ts(2)=etime(clock,datevec(metadata.ts(1)));


% --- trigger via arduino --
arduino=getappdata(0,'arduino');
fwrite(arduino,1,'int8');

% ---- write status bar ----
trials=getappdata(0,'trials');
set(handles.text_status,'String',sprintf('Total trials: %d\n',metadata.cam.trialnum));
if strcmpi(metadata.stim.type,'conditioning')
    trialvars=readTrialTable(metadata.eye.trialnum1+1);
    csdur=trialvars(1);
    csnum=trialvars(2);
    isi=trialvars(3);
    usdur=trialvars(4);
    usnum=trialvars(5);
    cstone=str2num(get(handles.edit_tone,'String'));
    if length(cstone)<2, cstone(2)=0; end

    str2=[];
    if ismember(csnum,[5 6]),
        str2=[' (' num2str(cstone(csnum-4)) ' KHz)'];
    end

    str1=sprintf('Next:  No %d,  CS ch %d%s,  ISI %d,  US %d, US ch %d',metadata.eye.trialnum1+1, csnum, str2, isi, usdur, usnum);
    set(handles.text_disp_cond,'String',str1)
end
setappdata(0,'metadata',metadata);

function stream(handles)
ghandles=getappdata(0,'ghandles');
vidobj=getappdata(0,'vidobj');
src=getappdata(0,'src');
updaterate=0.017;   % ~67 Hz
% updaterate=0.1;   % 10 Hz
t1=clock-10;
t0=clock;

eyedata=NaN*ones(500,2);
plt_range=-2100;

if get(handles.togglebutton_stream,'Value')
    set(0,'currentfigure',ghandles.maingui)
    set(ghandles.maingui,'CurrentAxes',handles.axes_eye)
    cla
    pl1=plot([plt_range 0],[1 1]*0,'k-'); hold on
    set(gca,'color',[240 240 240]/255,'YAxisLocation','right');
    set(gca,'xlim',[plt_range 0],'ylim',[-0.1 1.1])
    set(gca,'xtick',[-3000:500:0],'box','off')
    set(gca,'ytick',[0:0.5:1],'yticklabel',{'0' '' '1'})
end

try
    while get(handles.togglebutton_stream,'Value') == 1
        t2=clock;
        metadata=getappdata(0,'metadata');  % get updated metadata within this loop, otherwise we'll be using stale data

        % --- eye trace ---
        wholeframe=getsnapshot(vidobj);
        roi=wholeframe.*uint8(metadata.cam.mask); % multiply the frame by the mask --> everything outside of the ROI becomes 0 and everything inside the ROI remains the same (is multiplied by 1)
        eyelidpos=sum(roi(:)>=256*metadata.cam.thresh); % find everywhere in roi that is > your threshold value converted into 8-bit-integer units

        % --- eye trace buffer ---
        etime0=round(1000*etime(clock,t0));
        eyedata(1:end-1,:)=eyedata(2:end,:);
        eyedata(end,1)=etime0;
        eyedata(end,2)=(eyelidpos-metadata.cam.calib_offset)/metadata.cam.calib_scale; % eyelid pos

        set(pl1,'XData',eyedata(:,1)-etime0,'YData',eyedata(:,2))

        % --- Trigger ----
        if get(handles.toggle_continuous,'Value') == 1

            stopTrial = str2double(get(handles.edit_StopAfterTrial,'String'));
            if stopTrial > 0 && metadata.cam.trialnum > stopTrial
                set(handles.toggle_continuous,'Value',0);
                set(handles.toggle_continuous,'String','Start Continuous');
            end

            etime1=round(1000*etime(clock,t1))/1000;
            if etime1>metadata.stim.c.ITI,
                eyeok=checkeye(handles,eyedata);
                if eyeok
                    TriggerArduino(handles)
                    t1=clock;
                end
            end
        end

        t=round(1000*etime(clock,t2))/1000;
        % -- pause in the left time -----
        d=updaterate-t;
        if d>0
            pause(d)        %   java.lang.Thread.sleep(d*1000);     %     drawnow
        else
            if get(handles.checkbox_verbose,'Value') == 1
                disp(sprintf('%s: Unable to sustain requested stream rate! Loop required %f seconds.',datestr(now,'HH:MM:SS'),t))
            end
        end

        % Try to deal with dropped frames silently
        % if strcmp(src.FrameStartTriggerSource,'Freerun') & strcmp(vidobj.Previewing,'off')
        %     handles.pwin=image(zeros(480,640),'Parent',handles.cameraAx);
        %     preview(vidobj,handles.pwin);
        % end

        % if strcmp(src.FrameStartTriggerSource,'Line1') & strcmp(vidobj.Running,'off')
        %     start(vidobj);
        % end

    end
catch

    try % If it's a dropped frame, see if we can recover
        handles.pwin=image(zeros(480,640),'Parent',handles.cameraAx);
        pause(0.5)
        closepreview(vidobj);
        pause(0.2)
        preview(vidobj,handles.pwin);
    %     guidata(handles.cameraAx,handles)
        stream(handles)
        disp('Caught camera error')
    catch
        disp('Aborted eye streaming.')
        set(handles.togglebutton_stream,'Value',0);
    %     set(handles.pushbutton_StartStopPreview,'String','Start Preview')
    %     closepreview(vidobj);
        return
    end
end

function eyeok=checkeye(handles,eyedata)
eyethrok = (eyedata(end,2)<str2double(get(handles.edit_eyethr,'String')));
eyedata(:,1)=eyedata(:,1)-eyedata(end,1);
recenteye=eyedata(eyedata(:,1)>-1000*str2double(get(handles.edit_stabletime,'String')), 2);
eyestableok = ((max(recenteye)-min(recenteye))<str2double(get(handles.edit_stableeye,'String')));
eyeok = eyethrok && eyestableok;


%%%%%%%%%% end of user functions %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes during object creation, after setting all properties.
function popupmenu_stimtype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_stimtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_pretime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pretime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_pretime as text
%        str2double(get(hObject,'String')) returns contents of edit_pretime as a double


% --- Executes during object creation, after setting all properties.
function edit_pretime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pretime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on button press in pushbutton7.
% function pushbutton7_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton7 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in checkbox_save_metadata.
function checkbox_save_metadata_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_save_metadata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_save_metadata


function edit_ITI_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ITI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_ITI as text
%        str2double(get(hObject,'String')) returns contents of edit_ITI as a double


% --- Executes during object creation, after setting all properties.
function edit_ITI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ITI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_puffdur_Callback(hObject, eventdata, handles)
% hObject    handle to edit_puffdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_puffdur as text
%        str2double(get(hObject,'String')) returns contents of edit_puffdur as a double


% --- Executes during object creation, after setting all properties.
function edit_puffdur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_puffdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_SessionName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_SessionName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_SessionName as text
%        str2double(get(hObject,'String')) returns contents of edit_SessionName as a double


% --- Executes during object creation, after setting all properties.
function edit_SessionName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_SessionName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end



function edit_stabletime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stabletime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stabletime as text
%        str2double(get(hObject,'String')) returns contents of edit_stabletime as a double


% --- Executes during object creation, after setting all properties.
function edit_stabletime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stabletime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_stableeye_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stableeye (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stableeye as text
%        str2double(get(hObject,'String')) returns contents of edit_stableeye as a double


% --- Executes during object creation, after setting all properties.
function edit_stableeye_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stableeye (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_eyethr_Callback(hObject, eventdata, handles)
% hObject    handle to edit_eyethr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_eyethr as text
%        str2double(get(hObject,'String')) returns contents of edit_eyethr as a double


% --- Executes during object creation, after setting all properties.
function edit_eyethr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_eyethr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_verbose.
function checkbox_verbose_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_verbose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_verbose



function edit_posttime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_posttime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_posttime as text
%        str2double(get(hObject,'String')) returns contents of edit_posttime as a double


% --- Executes during object creation, after setting all properties.
function edit_posttime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_posttime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_abort.
function pushbutton_abort_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_abort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If camera gets hung up for any reason, this button can be pressed to
% reset it.

vidobj = getappdata(0,'vidobj');
src = getappdata(0,'src');

stop(vidobj);
flushdata(vidobj);

src.FrameStartTriggerSource = 'Freerun';




function edit_ITI_rand_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ITI_rand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ITI_rand as text
%        str2double(get(hObject,'String')) returns contents of edit_ITI_rand as a double


% --- Executes during object creation, after setting all properties.
function edit_ITI_rand_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ITI_rand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_StopAfterTrial_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StopAfterTrial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StopAfterTrial as text
%        str2double(get(hObject,'String')) returns contents of edit_StopAfterTrial as a double


% --- Executes during object creation, after setting all properties.
function edit_StopAfterTrial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StopAfterTrial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Generate trial table stuff
function pushbutton_opentable_Callback(hObject, eventdata, handles)

% go to other gui
GenTrialTableWin



%% TAKE NOTE STUFF
% --- Executes on button press in pushbutton_takeNote.
function pushbutton_takeNote_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_takeNote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

NoteWindow

%% Other GUI STUFF

function edit_tone_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tone as text
%        str2double(get(hObject,'String')) returns contents of edit_tone as a double


% --- Executes during object creation, after setting all properties.
function edit_tone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton_NewSession.
function togglebutton_NewSession_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_NewSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dlgans = inputdlg({'Enter session name'},'Create');
if isempty(dlgans)
    ok=0;
elseif isempty(dlgans{1})
    ok=0;
else
    ok=1;  session=dlgans{1};
    set(handles.checkbox_save_metadata,'Value',0);
end
% take note of new seesion pushed
notedata = getappdata(0, 'notedata');
notedata.note{1,2} = 'Session';
notedata.note{1,3} = datestr(now, 'hh:MM:ss');
trials=getappdata(0,'trials');
try
    notedata.note{1,4} = trials.stimnum;
catch ME
    notedata.note{1,4} = 1;
end
notedata.note{1,5} = 'New Session pressed';
setappdata(0, 'notedata', notedata)
appendcell2csv(notedata.filename,notedata.note);

ResetCamTrials()
set(handles.edit_SessionName,'String',session);
metadata=getappdata(0,'metadata');
metadata.TDTblockname=sprintf('%s_%s_%s', metadata.mouse, datestr(now,'yymmdd'),session);
set(handles.text_status,'String',sprintf('Basename for session:\n%s',metadata.TDTblockname))
setappdata(0,'metadata',metadata);

% Hint: get(hObject,'Value') returns toggle state of togglebutton_NewSession


% --- Executes on button press in togglebutton_StopSession.
function togglebutton_StopSession_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_StopSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button=questdlg('Are you sure you want to stop this session?','Yes','No');
if ~strcmpi(button,'Yes')
    ok=0;
else
    session='s00';     ok=1;
end
% take note of new seesion pushed
notedata = getappdata(0, 'notedata');
notedata.note{1,2} = 'Session';
notedata.note{1,3} = datestr(now, 'hh:MM:ss');
trials=getappdata(0,'trials');
try
    notedata.note{1,4} = trials.stimnum;
catch ME
    notedata.note{1,4} = 1;
end
notedata.note{1,5} = 'Stop Session pressed';
setappdata(0, 'notedata', notedata)
appendcell2csv(notedata.filename,notedata.note);

ResetCamTrials()
set(handles.edit_SessionName,'String',session);
metadata=getappdata(0,'metadata');
metadata.TDTblockname=sprintf('%s_%s_%s', metadata.mouse, datestr(now,'yymmdd'),session);
set(handles.text_status,'String',sprintf('Basename for session:\n%s',metadata.TDTblockname))
setappdata(0,'metadata',metadata);
% Hint: get(hObject,'Value') returns toggle state of togglebutton_StopSession


% --- Executes on button press in pushbutton_oneana.
function pushbutton_oneana_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_oneana (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ghandles=getappdata(0,'ghandles');
ghandles.onetrialanagui=OneTrialAnaWindow_new;
setappdata(0,'ghandles',ghandles);

set(ghandles.onetrialanagui,'units','pixels')
%set(ghandles.onetrialanagui,'position',[ghandles.pos_oneanawin ghandles.size_oneanawin])
