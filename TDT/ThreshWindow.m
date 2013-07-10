function varargout = ThreshWindow(varargin)
% THRESHWINDOW MATLAB code for ThreshWindow.fig
%      THRESHWINDOW, by itself, creates a new THRESHWINDOW or raises the existing
%      singleton*.
%
%      H = THRESHWINDOW returns the handle to a new THRESHWINDOW or the handle to
%      the existing singleton*.
%
%      THRESHWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THRESHWINDOW.M with the given input arguments.
%
%      THRESHWINDOW('Property','Value',...) creates a new THRESHWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ThreshWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ThreshWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ThreshWindow

% Last Modified by GUIDE v2.5 19-Nov-2012 12:09:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ThreshWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @ThreshWindow_OutputFcn, ...
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


% --- Executes just before ThreshWindow is made visible.
function ThreshWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ThreshWindow (see VARARGIN)



metadata=getappdata(0,'metadata');

% Choose default command line output for ThreshWindow
handles.output = hObject;

handles.x1=ceil(metadata.cam.winpos(1));
handles.x2=floor(metadata.cam.winpos(1)+metadata.cam.winpos(3));
handles.y1=ceil(metadata.cam.winpos(2));
handles.y2=floor(metadata.cam.winpos(2)+metadata.cam.winpos(4));

set(handles.edit_eyelidThresh,'String',num2str(round(metadata.cam.thresh*256)));
set(handles.slider_eyelidThresh,'Value',round(metadata.cam.thresh*256));


% t=timer('Name','threshdispTimer','Period',0.1,'ExecutionMode','FixedRate','TimerFcn',{@threshupdate,handles},'BusyMode','drop');
% handles.timer=t;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ThreshWindow wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function drawhist(handles)

% Load objects from root app data
vidobj=getappdata(0,'vidobj');
ghandles=getappdata(0,'ghandles');  % Load global handles

wholeframe=getsnapshot(vidobj);

roi=wholeframe(handles.y1:handles.y2,handles.x1:handles.x2);

% handles.histimage=image(zeros(size(wholeframe)),'Parent',handles.axes_hist);
% axes(handles.axes_hist)
set(0,'CurrentFigure',ghandles.threshgui)
set(ghandles.threshgui,'CurrentAxes',handles.axes_hist)
imhist(wholeframe)


function drawbinary(handles)

% Load objects from root app data
vidobj=getappdata(0,'vidobj');
ghandles=getappdata(0,'ghandles');  % Load global handles
metadata=getappdata(0,'metadata');

wholeframe=getsnapshot(vidobj);
roi=wholeframe(handles.y1:handles.y2,handles.x1:handles.x2);
binframe=im2bw(roi,metadata.cam.thresh);
% eyeframe=binframe.*metadata.mask;

% handles.binimage=image(zeros(size(wholeframe)),'Parent',handles.axes_binary);
% handles.binimage=imshow(eyeframe,'Parent',handles.axes_binary);
set(0,'CurrentFigure',ghandles.threshgui)
handles.binimage=imshow(binframe,'Parent',handles.axes_binary);


% --- Outputs from this function are returned to the command line.
function varargout = ThreshWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_eyelidThresh_Callback(hObject, eventdata, handles)
% hObject    handle to slider_eyelidThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

metadata=getappdata(0,'metadata');

% Alternatively can use "thresh = graythresh(image)" to get threshold with
% Otsu's method
thres_slider=round(get(hObject,'Value'))/256;
if thres_slider>0 && thres_slider<1,
    metadata.cam.thresh=round(get(hObject,'Value'))/256;
    set(handles.edit_eyelidThresh,'String',num2str(round(get(hObject,'Value'))))
else
    disp('Wrong number was retruned by slider...')
    set(handles.slider_eyelidThresh,'Value',round(metadata.cam.thresh*256));
end
% Have to stop auto refresh timer before drawing or else we get an error
% when the timer has a callback
% stop(handles.timer)
setappdata(0,'metadata',metadata);

drawhist(handles)
drawbinary(handles)
% autorefresh(handles)
% start(handles.timer)



% --- Executes during object creation, after setting all properties.
function slider_eyelidThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_eyelidThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_eyelidThresh_Callback(hObject, eventdata, handles)
% hObject    handle to edit_eyelidThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_eyelidThresh as text
%        str2double(get(hObject,'String')) returns contents of edit_eyelidThresh as a double

metadata=getappdata(0,'metadata');

% Alternatively can use "thresh = graythresh(image)" to get threshold with
% Otsu's method
metadata.cam.thresh=str2double(get(handles.edit_eyelidThresh,'String'))/256;
set(handles.slider_eyelidThresh,'Value',round(metadata.cam.thresh*256));

% stop(handles.timer)
setappdata(0,'metadata',metadata);

drawhist(handles)
drawbinary(handles)
% autorefresh(handles)
% start(handles.timer)



% --- Executes during object creation, after setting all properties.
function edit_eyelidThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_eyelidThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: delete(hObject) closes the figure
delete(hObject);

function threshupdate(obj,event,handles)

tic
if mod(obj.TasksExecuted,2)==0
    drawhist(handles)
else
    drawbinary(handles)
end
t=toc;

if t>obj.InstantPeriod
    disp(sprintf('Threshold auto refresh timer function took too long: t=%f seconds.',t))
end

% --- Executes on button press in pushbutton_ok.
function pushbutton_ok_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% stop(handles.timer)
% delete(handles.timer)

set(handles.togglebutton_autorefresh,'Value',0)
delete(handles.figure1);

% --- Executes on button press in togglebutton_autorefresh.
function togglebutton_autorefresh_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_autorefresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_autorefresh

% if get(hObject,'Value') == 1
%     start(handles.timer);
% else
%     stop(handles.timer);
% end

autorefresh(handles)
   

function autorefresh(handles)

try
while get(handles.togglebutton_autorefresh,'Value') == 1
    drawhist(handles)
    drawbinary(handles)
    pause(0.05)
end
catch
    disp('Aborted auto refresh.')
    return
end
