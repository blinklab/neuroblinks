function varargout = ParamsWindow(varargin)
% PARAMSWINDOW MATLAB code for ParamsWindow.fig
%      PARAMSWINDOW, by itself, creates a new PARAMSWINDOW or raises the existing
%      singleton*.
%
%      H = PARAMSWINDOW returns the handle to a new PARAMSWINDOW or the handle to
%      the existing singleton*.
%
%      PARAMSWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARAMSWINDOW.M with the given input arguments.
%
%      PARAMSWINDOW('Property','Value',...) creates a new PARAMSWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ParamsWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ParamsWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ParamsWindow

% Last Modified by GUIDE v2.5 19-Nov-2012 12:10:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ParamsWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @ParamsWindow_OutputFcn, ...
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


% --- Executes just before ParamsWindow is made visible.
function ParamsWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ParamsWindow (see VARARGIN)

% Choose default command line output for ParamsWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ParamsWindow wait for user response (see UIRESUME)
% uiwait(handles.ParamFig);


% --- Outputs from this function are returned to the command line.
function varargout = ParamsWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_mouseName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mouseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mouseName as text
%        str2double(get(hObject,'String')) returns contents of edit_mouseName as a double

metadata=getappdata(0,'metadata');

metadata.mouse=get(hObject,'String');

setappdata(0,'metadata',metadata);


% --- Executes during object creation, after setting all properties.
function edit_mouseName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mouseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

metadata=getappdata(0,'metadata');
set(hObject,'String',metadata.mouse);


function edit_trialNum_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trialNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trialNum as text
%        str2double(get(hObject,'String')) returns contents of edit_trialNum as a double

metadata=getappdata(0,'metadata');
metadata.cam.trialnum=str2double(get(hObject,'String'));

setappdata(0,'metadata',metadata);

% --- Executes during object creation, after setting all properties.
function edit_trialNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trialNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

metadata=getappdata(0,'metadata');
set(hObject,'String',num2str(metadata.cam.trialnum));

% --- Executes on button press in pushbutton_ok.
function pushbutton_ok_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.ParamFig);
