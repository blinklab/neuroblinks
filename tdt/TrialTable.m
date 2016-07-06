function varargout = TrialTable(varargin)
% TRIALTABLE MATLAB code for TrialTable.fig
%      TRIALTABLE, by itself, creates a new TRIALTABLE or raises the existing
%      singleton*.
%
%      H = TRIALTABLE returns the handle to a new TRIALTABLE or the handle to
%      the existing singleton*.
%
%      TRIALTABLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRIALTABLE.M with the given input arguments.
%
%      TRIALTABLE('Property','Value',...) creates a new TRIALTABLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TrialTable_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TrialTable_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TrialTable

% Last Modified by GUIDE v2.5 23-May-2013 12:05:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TrialTable_OpeningFcn, ...
                   'gui_OutputFcn',  @TrialTable_OutputFcn, ...
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


% --- Executes just before TrialTable is made visible.
function TrialTable_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TrialTable (see VARARGIN)

% Choose default command line output for TrialTable
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TrialTable wait for user response (see UIRESUME)
% uiwait(handles.TrialTableGUI);

ghandles=getappdata(0,'ghandles');

% Holding down CTRL while clicking button prevents re-initialization
modifier=get(ghandles.maingui,'CurrentModifier');
% disp(modifier)

paramtable=getappdata(0,'paramtable');
if strcmp(modifier,'control') & isappdata(0,'trialtable')
	trialtable=getappdata(0,'trialtable');
else
	trialtable=makeTrialTable(paramtable.data,paramtable.randomize);
end

set(handles.uitable_trials,'Data',trialtable);
setappdata(0,'trialtable',trialtable);



% --- Outputs from this function are returned to the command line.
function varargout = TrialTable_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
