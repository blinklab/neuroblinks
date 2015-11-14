function varargout = GenTrialTableWin(varargin)
% GENTRIALTABLEWIN MATLAB code for GenTrialTableWin.fig
%      GENTRIALTABLEWIN, by itself, creates a new GENTRIALTABLEWIN or raises the existing
%      singleton*.
%
%      H = GENTRIALTABLEWIN returns the handle to a new GENTRIALTABLEWIN or the handle to
%      the existing singleton*.
%
%      GENTRIALTABLEWIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GENTRIALTABLEWIN.M with the given input arguments.
%
%      GENTRIALTABLEWIN('Property','Value',...) creates a new GENTRIALTABLEWIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GenTrialTableWin_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GenTrialTableWin_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GenTrialTableWin

% Last Modified by GUIDE v2.5 09-Oct-2015 11:47:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GenTrialTableWin_OpeningFcn, ...
                   'gui_OutputFcn',  @GenTrialTableWin_OutputFcn, ...
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


% --- Executes just before GenTrialTableWin is made visible.
function GenTrialTableWin_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GenTrialTableWin (see VARARGIN)

% Choose default command line output for GenTrialTableWin
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GenTrialTableWin wait for user response (see UIRESUME)
% uiwait(handles.TrialTableWindow);

% --- init table ----
if isappdata(0,'paramtable')
    paramtable=getappdata(0,'paramtable');
    set(handles.uitable_params,'Data',paramtable.data);
end


% --- Outputs from this function are returned to the command line.
function varargout = GenTrialTableWin_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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


% --- Executes on button press in pushbutton_loadParams.
function pushbutton_loadParams_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

paramtable = getappdata(0,'paramtable');

[paramfile,paramfilepath,filteridx] = uigetfile('*.csv');

if paramfile & filteridx == 1 % The filterindex thing is a hack to make sure it's a csv file
    paramtable.data=csvread(fullfile(paramfilepath,paramfile));
    set(handles.uitable_params,'Data',paramtable.data);
    setappdata(0,'paramtable',paramtable);
end


% --- Executes on button press in checkbox_random.
function checkbox_random_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_random (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_random
