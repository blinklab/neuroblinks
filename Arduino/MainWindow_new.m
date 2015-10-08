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

% Last Modified by GUIDE v2.5 08-Oct-2015 11:47:04

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


% --- Executes just before MainWindow_new is made visible.
function MainWindow_new_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainWindow_new (see VARARGIN)

% Choose default command line output for MainWindow_new
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MainWindow wait for user response (see UIRESUME)
% uiwait(handles.CamFig);
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


% UIWAIT makes MainWindow_new wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MainWindow_new_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox_record.
function checkbox_record_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.checkbox_record,'BackgroundColor',[0 1 0]); % green
else
    set(handles.checkbox_record,'BackgroundColor',[1 0 0]); % red
end

% Hint: get(hObject,'Value') returns toggle state of checkbox_record


% --- Executes on button press in checkbox_save_metadata.
function checkbox_save_metadata_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_save_metadata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_save_metadata


% --- Executes on button press in checkbox_verbose.
function checkbox_verbose_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_verbose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_verbose


% --- Executes on button press in pushbutton_abort.
function pushbutton_abort_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_abort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vidobj = getappdata(0,'vidobj');
src = getappdata(0,'src');

stop(vidobj);
flushdata(vidobj);

src.FrameStartTriggerSource = 'Freerun';


% --- Executes on button press in pushbutton_takeNote.
function pushbutton_takeNote_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_takeNote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

NoteWindow


% --- Executes on button press in pushbutton_oneana.
function pushbutton_oneana_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_oneana (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ghandles=getappdata(0,'ghandles');
ghandles.onetrialanagui=OneTrialAnaWindow;
setappdata(0,'ghandles',ghandles);

set(ghandles.onetrialanagui,'units','pixels')
set(ghandles.onetrialanagui,'position',[ghandles.pos_oneanawin ghandles.size_oneanawin])


% --- Executes on button press in pushbutton_instantreplay.
function pushbutton_instantreplay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_instantreplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
instantReplay(getappdata(0,'lastdata'),getappdata(0,'lastmetadata'));


% --- Executes on button press in checkbox_random.
function checkbox_random_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_random (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_random


% --- Executes on button press in pushbutton_loadParams.
function pushbutton_loadParams_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

paramtable = getappdata(0,'paramtable');

[paramfile,paramfilepath,filteridx] = uigetfile('*.csv');

if paramfile & filteridx == 1 % The filterindex thing is a hack to make sure it's a csv file
    paramtable.data=csvread(fullfile(paramfilepath,paramfile));
    setappdata(0,'paramtable',paramtable);
end


% --- Executes on button press in pushbutton_opentable.
function pushbutton_opentable_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_opentable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

paramtable.data=get(handles.uitable_params,'Data');
paramtable.randomize=get(handles.checkbox_random,'Value');
% paramtable.tonefreq=str2num(get(handles.edit_tone,'String'));
% if length(paramtable.tonefreq)<2, paramtable.tonefreq(2)=0; end
setappdata(0,'paramtable',paramtable);

ghandles=getappdata(0,'ghandles');
trialtablegui=TrialTable;
movegui(trialtablegui,[ghandles.pos_mainwin(1)+ghandles.size_mainwin(1)+20 ghandles.pos_mainwin(2)])

% take note of trial table generation
notedata = getappdata(0, 'notedata');
notedata.note{1,2} = 'Trial table';
notedata.note{1,3} = datestr(now, 'hh:mm:ss');
try
    nextTrial = metadata.eye.trialnum1;
catch ME
    nextTrial = 1;
end
notedata.note{1,4} = nextTrial - 1;  % assume the user is interested in the trial that just happened
notedata.note{1,5} = 'New trial table generated';
setappdata(0, 'notedata', notedata)
appendcell2csv(notedata.filename,notedata.note);



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


% --- Executes on button press in toggle_continuous.
function toggle_continuous_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_continuous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
notedata.note{1,3} = datestr(now, 'hh:mm:ss');
try
    nextTrial = metadata.eye.trialnum1;
catch ME
    nextTrial = 1;
end
notedata.note{1,4} = nextTrial - 1;  % assume the user is interested in the trial that just happened
notedata.note{1,5} = comment;
setappdata(0, 'notedata', notedata)
appendcell2csv(notedata.filename,notedata.note);

% Hint: get(hObject,'Value') returns toggle state of toggle_continuous


% --- Executes on button press in pushbutton_stim.
function pushbutton_stim_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TriggerArduino(handles)

% take note of stimulus delivered
notedata = getappdata(0, 'notedata');
notedata.note{1,2} = 'Puff';
notedata.note{1,3} = datestr(now, 'hh:mm:ss');
try
    nextTrial = metadata.eye.trialnum1;
catch ME
    nextTrial = 1;
end
notedata.note{1,4} = nextTrial - 1;  % assume the user is interested in the trial that just happened
notedata.note{1,5} = 'User delivered single trial manually';
setappdata(0, 'notedata', notedata)
appendcell2csv(notedata.filename,notedata.note);


% --- Executes on selection change in popupmenu_stimtype.
function popupmenu_stimtype_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_stimtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_stimtype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_stimtype


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


% --- Executes on button press in pushbutton_params.
function pushbutton_params_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_params (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ParamsWindow


% --- Executes on button press in setROI.
function setROI_Callback(hObject, eventdata, handles)
% hObject    handle to setROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
notedata.note{1,3} = datestr(now, 'hh:mm:ss');
try
    nextTrial = metadata.eye.trialnum1;
catch ME
    nextTrial = 1;
end
notedata.note{1,4} = nextTrial - 1;  % assume the user is interested in the trial that just happened
notedata.note{1,5} = 'ROI set';
setappdata(0, 'notedata', notedata)
appendcell2csv(notedata.filename,notedata.note);


% --- Executes on button press in pushbutton_CalbEye.
function pushbutton_CalbEye_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_CalbEye (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
src.FrameStartTriggerSource = 'Line1';

start(vidobj)

metadata.cam.cal=0;
metadata.ts(2)=etime(clock,datevec(metadata.ts(1)));
% --- trigger via arduino --
arduino=getappdata(0,'arduino');
fwrite(arduino,1,'int8');

% take note of calibration trial
notedata = getappdata(0, 'notedata');
notedata.note{1,2} = 'Puff';
notedata.note{1,3} = datestr(now, 'hh:mm:ss');
try
    nextTrial = metadata.eye.trialnum1;
catch ME
    nextTrial = 1;
end
notedata.note{1,4} = nextTrial - 1;  % assume the user is interested in the trial that just happened
notedata.note{1,5} = 'Calibration puff delivered';
setappdata(0, 'notedata', notedata)
appendcell2csv(notedata.filename,notedata.note);

setappdata(0,'metadata',metadata);


% --- Executes on button press in pushbutton_StartStopPreview.
function pushbutton_StartStopPreview_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_StartStopPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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


% --- Executes on button press in togglebutton_stream.
function togglebutton_stream_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_stream (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if get(hObject,'Value'),
    set(hObject,'String','Stop Streaming')
    stream(handles)
else
    set(hObject,'String','Start Streaming')
end

% Hint: get(hObject,'Value') returns toggle state of togglebutton_stream



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


% --- Executes on button press in togglebutton_tgframerate.
function togglebutton_tgframerate_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_tgframerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


vidobj=getappdata(0,'vidobj');
src=getappdata(0,'src');
metadata=getappdata(0,'metadata');

if get(hObject,'Value')
    % Turn on high frame rate mode
    metadata.cam.vidobj_ROIposition=max(metadata.cam.winpos+[-10 0 20 0],[0 0 0 0]);
    vidobj.ROIposition=metadata.cam.vidobj_ROIposition;
%     metadata.cam.fps=500;
    src.ExposureTimeAbs = 1900;
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
    src.ExposureTimeAbs = metadata.cam.init_ExposureTime;
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

% Hint: get(hObject,'Value') returns toggle state of togglebutton_tgframerate


% --- Executes on button press in pushbutton_quit.
function pushbutton_quit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
delete(handles.CamFig)

pause(0.5)

button=questdlg('Do you want to compress the videos from this session?');
if strcmpi(button,'Yes')
    makeCompressedVideos(metadata.folder,1);
end

%% user defined functions?

% this was in the previous version of MainWindow but I wasn't sure what to
% do with it so I just copied it here
function CamFig_KeyPressFcn(hObject, eventdata, handles)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
switch eventdata.Character
    case '`'
        pushbutton_stim_Callback(hObject, eventdata, handles);
    otherwise
        return
end
