function varargout = MainWindow(varargin)
% MAINWINDOW MATLAB code for MainWindow.fig
%      MAINWINDOW, by itself, creates a new MAINWINDOW or raises the existing
%      singleton*.
%
%      H = MAINWINDOW returns the handle to a new MAINWINDOW or the handle to
%      the existing singleton*.
%
%      MAINWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINWINDOW.M with the given input arguments.
%
%      MAINWINDOW('Property','Value',...) creates a new MAINWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainWindow

% Last Modified by GUIDE v2.5 15-Jun-2013 13:11:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @MainWindow_OutputFcn, ...
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


% --- Executes just before MainWindow is made visible.
function MainWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainWindow (see VARARGIN)

metadata=getappdata(0,'metadata');
src=getappdata(0,'src');
% TDT=getappdata(0,'tdt');

metadata.date=date;
metadata.ts=[datenum(clock) 0]; % two element vector containing datenum at beginning of session and offset of current trial (in seconds) from beginning
% metadata.mouse='Sxxx';
metadata.TDTblockname='';
metadata.folder=pwd; % For now use current folder as base; will want to change this later

metadata.cam.fps=src.AcquisitionFrameRateAbs; %in frames per second
metadata.cam.thresh=0.125;
metadata.cam.trialnum=1;
metadata.eye.trialnum1=1;  %  for conditioning
metadata.eye.trialnum2=1;

typestring=get(handles.popupmenu_stimtype,'String');
metadata.stim.type=typestring{get(handles.popupmenu_stimtype,'Value')};

% metadata.thresh=str2double(get(handles.edit_eyelidThresh,'String'));
metadata.cam.time(1)=str2double(get(handles.edit_pretime,'String'));
metadata.cam.time(3)=str2double(get(handles.edit_posttime,'String'));

metadata.cam.calib_offset=0;
metadata.cam.calib_scale=1;
% metadata.stim.c.table=get(handles.table_condition,'Data');

% Make trial structure for saving things that won't get saved with video
% data, such as the trial count for a particular stim type.
trials.stimnum=0;
trials.savematadata=0;
% trials.tnum=1;

% Save metadata to root object's appdata
setappdata(0,'metadata',metadata);
setappdata(0,'trials',trials);

% Choose default command line output for MainWindow
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% Open parameter dialog
h=ParamsWindow;
waitfor(h);

pushbutton_StartStopPreview_Callback(handles.pushbutton_StartStopPreview, [], handles)

% Create timer to check if we are recording every 5 seconds
% First delete old instances
t=timerfind('Name','TDTcheckmodeTimer');
delete(t)
TDTcheckmodeTimer=timer('Name','TDTcheckmodeTimer','Period',5,'ExecutionMode','FixedRate',...
    'TimerFcn',@TDTcheckmodetimer,'BusyMode','queue','StartDelay',5);
start(TDTcheckmodeTimer);


if isappdata(0,'paramtable')
    paramtable=getappdata(0,'paramtable');
    set(handles.uitable_params,'Data',paramtable.data);
end
% UIWAIT makes MainWindow wait for user response (see UIRESUME)
% uiwait(handles.CamFig);


% --- Outputs from this function are returned to the command line.
function varargout = MainWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_stim.
function pushbutton_stim_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TriggerStim(hObject, handles)



function edit_estimfreq_Callback(hObject, eventdata, handles)
% hObject    handle to edit_estimfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_estimfreq as text
%        str2double(get(hObject,'String')) returns contents of edit_estimfreq as a double
resetStimTrials()

% --- Executes during object creation, after setting all properties.
function edit_estimfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_estimfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_epulsewidth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_epulsewidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_epulsewidth as text
%        str2double(get(hObject,'String')) returns contents of edit_epulsewidth as a double
resetStimTrials()

% --- Executes during object creation, after setting all properties.
function edit_epulsewidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_epulsewidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_etraindur_Callback(hObject, eventdata, handles)
% hObject    handle to edit_etraindur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_etraindur as text
%        str2double(get(hObject,'String')) returns contents of edit_etraindur as a double

resetStimTrials()

% --- Executes during object creation, after setting all properties.
function edit_etraindur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_etraindur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_estimamp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_estimamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_estimamp as text
%        str2double(get(hObject,'String')) returns contents of edit_estimamp as a double

resetStimTrials()

% --- Executes during object creation, after setting all properties.
function edit_estimamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_estimamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_StartStopPreview.
function pushbutton_StartStopPreview_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_StartStopPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vidobj=getappdata(0,'vidobj');
metadata=getappdata(0,'metadata');
% ROI=vidobj.ROIposition;
%   if ROI(3)~=480 || ROI(4)~=640
%      % Set ROI
% %      SetRoi;
%   end
metadata.cam.roi = vidobj.ROIposition;

% Start/Stop Camera
if strcmp(get(handles.pushbutton_StartStopPreview,'String'),'Start Preview')
% Camera is off. Change button string and start camera.
set(handles.pushbutton_StartStopPreview,'String','Stop Preview')
%Send camera preview to GUI
handles.pwin=image(zeros(480,640),'Parent',handles.cameraAx);
preview(vidobj,handles.pwin);
else
% Camera is on. Stop camera and change button string.
set(handles.pushbutton_StartStopPreview,'String','Start Preview')
closepreview(vidobj);
end

setappdata(0,'metadata',metadata);
guidata(hObject,handles)


% --- Executes on button press in checkbox_record.
function checkbox_record_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_record

if get(hObject,'Value')
    set(handles.checkbox_record,'BackgroundColor',[0 1 0]); % green
else
    set(handles.checkbox_record,'BackgroundColor',[1 0 0]); % red
end





% --- Executes on button press in pushbutton_setROI.
function pushbutton_setROI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load objects from root app data
% TDT=getappdata(0,'tdt');
vidobj=getappdata(0,'vidobj');metadata=getappdata(0,'metadata');

if isfield(metadata.cam,'winpos')
    winpos=metadata.cam.winpos;
else
    winpos=[0 0 640 480];
end

% Place rectangle on vidobj
% h=imrect(handles.cameraAx,winpos);
h=imellipse(handles.cameraAx,winpos);
% h=imellipse(handles.cameraAx,winpos);
% fcn = makeConstrainToRectFcn('imrect',get(handles.cameraAx,'XLim'),get(handles.cameraAx,'YLim'));
fcn = makeConstrainToRectFcn('imellipse',get(handles.cameraAx,'XLim'),get(handles.cameraAx,'YLim'));
setPositionConstraintFcn(h,fcn);

% metadata.cam.winpos=round(wait(h));
XY=round(wait(h));  % only use for imellipse
metadata.cam.winpos=getPosition(h);
metadata.cam.mask=createMask(h);

wholeframe=getsnapshot(vidobj);
binframe=im2bw(wholeframe,metadata.cam.thresh);
eyeframe=binframe.*metadata.cam.mask;
metadata.cam.pixelpeak=sum(sum(eyeframe));


xmin=metadata.cam.winpos(1);
ymin=metadata.cam.winpos(2);
width=metadata.cam.winpos(3);
height=metadata.cam.winpos(4);

% Save indices that delineate border of ROI
handles.x1=ceil(metadata.cam.winpos(1));
handles.x2=floor(metadata.cam.winpos(1)+metadata.cam.winpos(3));
handles.y1=ceil(metadata.cam.winpos(2));
handles.y2=floor(metadata.cam.winpos(2)+metadata.cam.winpos(4));

hp=findobj(handles.cameraAx,'Tag','roipatch');
delete(hp)
% handles.roipatch=patch([xmin,xmin+width,xmin+width,xmin],[ymin,ymin,ymin+height,ymin+height],'g','FaceColor','none','EdgeColor','g','Tag','roipatch');
% XY=getVertices(h);
delete(h);
handles.roipatch=patch(XY(:,1),XY(:,2),'g','FaceColor','none','EdgeColor','g','Tag','roipatch');

setappdata(0,'metadata',metadata);
guidata(hObject,handles)


% --- Executes on button press in togglebutton_.
function togglebutton_stream_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_stream (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_stream

% global eyelidTimer
% 
% if get(handles.togglebutton_stream,'Value') == 1
%     start(eyelidTimer)
% else
%     stop(eyelidTimer)
% end
streamEyelid(hObject, handles)


% --- Executes on button press in pushbutton_setThresh.
function pushbutton_setThresh_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pushbutton_setThresh

% Call new gui to deal with setting threshold
ghandles=getappdata(0,'ghandles');

ghandles.threshgui=ThreshWindow;
setappdata(0,'ghandles',ghandles);

% Have to do the following 3 lines because we can't call drawhist and
% drawbinary directly from the ThreshWindow opening function since the
% ghandles struct doesn't exist yet. 
threshguihandles=guidata(ghandles.threshgui);
ThreshWindow('drawhist',threshguihandles);
ThreshWindow('drawbinary',threshguihandles);

% if get(hObject,'Value') == 1
%     set(handles.text_eyelidThresh,'Visible','on')
%     set(handles.edit_eyelidThresh,'Visible','on')
%     
%     % Create image object to hold binary image
%     handles.binimage=image(zeros(480,640),'Parent',handles.cameraAx);
%     guidata(hObject,handles)
%     
%     % Set up timer for redrawing binary image
%     % First delete old instances
%     t=timerfind('Name','thresdispTimer');
%     delete(t)
%     treshdispTimer=timer('Name','threshdispTimer','Period',0.05,'ExecutionMode','FixedRate','TimerFcn',{@threshupdate,handles},'BusyMode','drop');
%     start(treshdispTimer)
% else
%     set(handles.text_eyelidThresh,'Visible','off')
%     set(handles.edit_eyelidThresh,'Visible','off')
%     t=timerfind('Name','thresdispTimer');
%     delete(t)
%     delete(handles.binimage)
%     return
% end


function pushbutton_params_Callback(hObject, eventdata, handles)
ParamsWindow


function pushbutton_quit_Callback(hObject, eventdata, handles)
% Load objects from root app data
TDT=getappdata(0,'tdt');
vidobj=getappdata(0,'vidobj');
ghandles=getappdata(0,'ghandles');
metadata=getappdata(0,'metadata');

button=questdlg('Are you sure you want to quit?','Quit?');
if ~strcmpi(button,'Yes')
    return
end

try
    TDT.CloseConnection;
    close(ghandles.TDTfig)
    delete(vidobj);
    
    rmappdata(0,'tdt');
    rmappdata(0,'src');
    rmappdata(0,'vidobj');
    
    t=timerfind('Name','TDTcheckmodeTimer');
    stop(t);
    delete(t);
catch err
    warning(err.identifier,'Problem cleaning up objects. You may need to do it manually.')
end
delete(handles.CamFig)

button=questdlg('Do you want to compress the videos from this session?');
if strcmpi(button,'Yes')
    makeCompressedVideos(metadata.folder,1);
end


% --- Executes on selection change in popupmenu_stimtype.
function popupmenu_stimtype_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_stimtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_stimtype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_stimtype

% --- updating metadata ---
metadata=getappdata(0,'metadata');
val=get(hObject,'Value');
str=get(hObject,'String');
metadata.stim.type=str{val};
setappdata(0,'metadata',metadata);

% ------ highlight for uipanel -----
set(handles.uipanel_stim,'BackgroundColor',[240 240 240]/255); 
set(handles.uipanel_puff,'BackgroundColor',[240 240 240]/255);
set(handles.uipanel_conditioning,'BackgroundColor',[240 240 240]/255);
switch lower(metadata.stim.type)
    case 'puff'
        set(handles.uipanel_puff,'BackgroundColor',[245 249 253]/255); % light blue
    case 'conditioning'
        set(handles.uipanel_conditioning,'BackgroundColor',[245 249 253]/255); % light blue
    case {'electrical','optical','optoelectric'}
        set(handles.uipanel_stim,'BackgroundColor',[245 249 253]/255); % light blue
    case 'optocondition'
        set(handles.uipanel_stim,'BackgroundColor',[245 249 253]/255); % light blue
        set(handles.uipanel_puff,'BackgroundColor',[245 249 253]/255); % light blue
end   
resetStimTrials()
refreshParams(hObject);
sendParamsToTDT(hObject);


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



function edit_lstimfreq_Callback(hObject, eventdata, handles)
resetStimTrials()

% --- Executes during object creation, after setting all properties.
function edit_lstimfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lstimfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_lpulsewidth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lpulsewidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lpulsewidth as text
%        str2double(get(hObject,'String')) returns contents of edit_lpulsewidth as a double
resetStimTrials()


% --- Executes during object creation, after setting all properties.
function edit_lpulsewidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lpulsewidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ltraindur_Callback(hObject, eventdata, handles)
resetStimTrials()

% --- Executes during object creation, after setting all properties.
function edit_ltraindur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ltraindur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_lstimamp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lstimamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lstimamp as text
%        str2double(get(hObject,'String')) returns contents of edit_lstimamp as a double
resetStimTrials()

% --- Executes during object creation, after setting all properties.
function edit_lstimamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lstimamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_estimdelay_Callback(hObject, eventdata, handles)
resetStimTrials()

% --- Executes during object creation, after setting all properties.
function edit_estimdelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_estimdelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_lstimdelay_Callback(hObject, eventdata, handles)
resetStimTrials()

% --- Executes during object creation, after setting all properties.
function edit_lstimdelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lstimdelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_estimdepth_Callback(hObject, eventdata, handles)
resetStimTrials()

% --- Executes during object creation, after setting all properties.
function edit_estimdepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_estimdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_lstimdepth_Callback(hObject, eventdata, handles)
resetStimTrials()

% --- Executes during object creation, after setting all properties.
function edit_lstimdepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lstimdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function togglebutton_ampblank_Callback(hObject, eventdata, handles)
sendParamsToTDT(hObject)

function edit_blankampextratime_Callback(hObject, eventdata, handles)
sendParamsToTDT(hObject)

% --- Executes during object creation, after setting all properties.
function edit_blankampextratime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_blankampextratime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton_instantreplay_Callback(hObject, eventdata, handles)
instantReplay(getappdata(0,'lastdata'),getappdata(0,'lastmetadata'));



function pushbutton_TDTcheckconnection_Callback(hObject, eventdata, handles)
TDT=getappdata(0,'tdt');
metadata=getappdata(0,'metadata');
ghandles=getappdata(0,'ghandles');

try
    if TDT.CheckServerConnection()==0
        if ~TDT.SetSysMode(2)
            ghandles.TDTfig=figure;
            TDT=actxcontrol('TDevAcc.X', [0 0 0 0],ghandles.TDTfig); 
            set(ghandles.TDTfig,'Visible','off');     
            ok=TDT.ConnectServer('Local'); %Open a TDT Connection
            if ok
                TDT.SetTankName(metadata.TDTtankname);
            end
            setappdata(0,'ghandles',ghandles);
            if ~ok
                warndlg('TDT OpenWorkBench does not appear to be running. Please open it and try again.',...
                    'No TDT connection','modal');
            else
                TDT.SetSysMode(2)
            end
        end
    end
catch exception
    % If we get an error here it probably means there's no TDT ActiveX
    % object, so we make one.
    ghandles.TDTfig=figure;
    TDT=actxcontrol('TDevAcc.X', [0 0 0 0],ghandles.TDTfig); 
    set(ghandles.TDTfig,'Visible','off');     
    ok=TDT.ConnectServer('Local'); %Open a TDT Connection
    if ok
        TDT.SetTankName(metadata.TDTtankname);
    end
    setappdata(0,'ghandles',ghandles);
    
    if ~TDT.SetSysMode(2)
        warndlg('TDT OpenWorkBench does not appear to be running. Please open it and try again.',...
            'No TDT connection','modal');
    end
    
    throw(exception)
end

setappdata(0,'tdt',TDT);



function edit_TDTBlockName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TDTBlockName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_TDTBlockName as text
%        str2double(get(hObject,'String')) returns contents of edit_TDTBlockName as a double


% --- Executes during object creation, after setting all properties.
function edit_TDTBlockName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_TDTBlockName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function edit_TDTTankName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TDTTankName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_TDTTankName as text
%        str2double(get(hObject,'String')) returns contents of edit_TDTTankName as a double

if TDTcheckmode() > 0
    h=msgbox('You can''t change the Tankname while Open Workbench is running. Please change to Idle mode.',...
        'Wrong Mode');
    wait(h);
    return
end

TDT=getappdata(0,'tdt');
metadata=getappdata(0,'metadata');

tank=get(hObject,'String');

if TDT.SetTankName(tank)
    metadata.TDTtankname=tank;
end

setappdata(0,'metadata',metadata);

% --- Executes during object creation, after setting all properties.
function edit_TDTTankName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_TDTTankName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes when selected object is changed in uipanel_TDTMode.
function uipanel_TDTMode_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_TDTMode 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'togglebutton_TDTRecord'
        ok=TDTStartRecording();
        set(handles.checkbox_save_metadata,'Value',0);
    case 'togglebutton_TDTPreview'
        ok=TDTStartPreview();
    case 'togglebutton_TDTIdle'
        ok=TDTStartIdle();
    otherwise
        warndlg('There is something wrong with the mode selection callback','Mode Select Problem!')
        return
end

if ok
    set(eventdata.NewValue,'Value',1);
    set(eventdata.OldValue,'Value',0);
    set(handles.uipanel_TDTMode,'SelectedObject',eventdata.NewValue);
else
    set(eventdata.NewValue,'Value',0);
    set(eventdata.OldValue,'Value',1);
    set(handles.uipanel_TDTMode,'SelectedObject',eventdata.OldValue);
end


% --- Executes on key press with focus on CamFig and none of its controls.
function CamFig_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to CamFig (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% Use this switch statement to handle button presses
switch eventdata.Character
    case '`'
        pushbutton_stim_Callback(hObject, eventdata, handles);
    otherwise
        return
end



function edit_puffdur_Callback(hObject, eventdata, handles)
% hObject    handle to edit_puffdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_puffdur as text
%        str2double(get(hObject,'String')) returns contents of edit_puffdur as a double
resetStimTrials()


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




function edit_puffdelay_Callback(hObject, eventdata, handles)
% hObject    handle to edit_puffdelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_puffdelay as text
%        str2double(get(hObject,'String')) returns contents of edit_puffdelay as a double
resetStimTrials()


% --- Executes during object creation, after setting all properties.
function edit_puffdelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_puffdelay (see GCBO)
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

% Hint: get(hObject,'Value') returns toggle state of togglebutton_tgframerate

vidobj=getappdata(0,'vidobj');
src=getappdata(0,'src');
metadata=getappdata(0,'metadata');

if get(hObject,'Value')
    % Turn on high frame rate mode
    vidobj.ROIposition=metadata.cam.winpos;
%     src.AcquisitionFrameRateAbs=300;
    metadata.cam.fps=500;
    src.ExposureTimeAbs = 1900;
    src.AllGainRaw=24;
else
    % Turn off high frame rate mode
    vidobj.ROIposition=metadata.cam.roi;
%     src.AcquisitionFrameRateAbs=200;
    metadata.cam.fps=200;
    src.ExposureTimeAbs = 4900;
    src.AllGainRaw=12;
end

setappdata(0,'vidobj',vidobj);
setappdata(0,'src',src);
setappdata(0,'metadata',metadata);






function edit_lramptm_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lramptm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_lramptm as text
%        str2double(get(hObject,'String')) returns contents of edit_lramptm as a double
resetStimTrials()

% --- Executes during object creation, after setting all properties.
function edit_lramptm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lramptm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_analysisWindow.
function pushbutton_analysisWindow_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_analysisWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ghandles=getappdata(0,'ghandles');
ghandles.analysisgui=AnalysisWindow;
setappdata(0,'ghandles',ghandles);

% movegui(ghandles.analysisgui,ghandles.pos_anawin)
set(ghandles.analysisgui,'units','pixels')
set(ghandles.analysisgui,'position',[ghandles.pos_anawin ghandles.size_anawin])

% --- Executes on button press in pushbutton_CalbEye.
function pushbutton_CalbEye_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_CalbEye (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get stim params and pass to TDT
refreshParams(hObject);
sendParamsToTDT(hObject)

TDT=getappdata(0,'tdt');
vidobj=getappdata(0,'vidobj');
metadata=getappdata(0,'metadata');

metadata.stim.type='Puff';

% Send TDT trial number of zero 
TDT.SetTargetVal('ustim.CamTrial',0);
TDT.SetTargetVal('ustim.TrialNum',0);

% Set up camera to record
frames_per_trial=ceil(metadata.cam.fps.*(sum(metadata.cam.time))./1000);
vidobj.TriggerRepeat = frames_per_trial-1;
vidobj.StopFcn=@CalbEye;   % @nosavetrial
flushdata(vidobj); % Remove any data from buffer before triggering
start(vidobj)

metadata.ts(2)=etime(clock,datevec(metadata.ts(1)));
TDT.SetTargetVal('ustim.MatTime',metadata.ts(2));

TDT.SetTargetVal('ustim.PuffManual',1);
if get(handles.checkbox_RX6,'Value'),
    TDT.SetTargetVal('ustim.StartCam',1);
    TDT.SetTargetVal('Stim.PuffManual',1); 
end
pause(0.01);
TDT.SetTargetVal('ustim.PuffManual',0);
if get(handles.checkbox_RX6,'Value'),
    TDT.SetTargetVal('Stim.PuffManual',0);
    TDT.SetTargetVal('ustim.StartCam',0);
end

setappdata(0,'metadata',metadata);



% --- Executes on button press in toggle_continuous.
function toggle_continuous_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_continuous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggle_continuous

if get(hObject,'Value'),
    set(hObject,'String','Continuous: ON')
else
    set(hObject,'String','Continuous: OFF')
end


% --- Executes when selected object is changed in uipanel_puff.
function uipanel_puff_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_puff 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
resetStimTrials()


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
% movegui(ghandles.onetrialanagui,ghandles.pos_oneanawin)


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
movegui(trialtablegui,[ghandles.pos_mainwin(1)+ghandles.size_mainwin(1)+20 200])














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


% --- Executes on button press in checkbox_puffside.
function checkbox_puffside_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_puffside (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_puffside


function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


function edit30_Callback(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit30 as text
%        str2double(get(hObject,'String')) returns contents of edit30 as a double


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit31_Callback(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit31 as text
%        str2double(get(hObject,'String')) returns contents of edit31 as a double


% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function edit32_Callback(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit32 as text
%        str2double(get(hObject,'String')) returns contents of edit32 as a double


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit33_Callback(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit33 as text
%        str2double(get(hObject,'String')) returns contents of edit33 as a double


% --- Executes during object creation, after setting all properties.
function edit33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_RX6.
function checkbox_RX6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_RX6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_RX6


% --- Executes on button press in checkbox_save_metadata.
function checkbox_save_metadata_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_save_metadata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_save_metadata



% --- Executes on button press in checkbox_random.
function checkbox_random_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_random (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_random



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


% --- Executes on button press in checkbox_tone.
function checkbox_tone_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_tone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox_tone



function edit_toneamp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_toneamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_toneamp as text
%        str2double(get(hObject,'String')) returns contents of edit_toneamp as a double


% --- Executes during object creation, after setting all properties.
function edit_toneamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_toneamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
