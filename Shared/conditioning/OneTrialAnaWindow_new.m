function varargout = OneTrialAnaWindow_new(varargin)
% ONETRIALANAWINDOW_NEW MATLAB code for OneTrialAnaWindow_new.fig
%      ONETRIALANAWINDOW_NEW, by itself, creates a new ONETRIALANAWINDOW_NEW or raises the existing
%      singleton*.
%
%      H = ONETRIALANAWINDOW_NEW returns the handle to a new ONETRIALANAWINDOW_NEW or the handle to
%      the existing singleton*.
%
%      ONETRIALANAWINDOW_NEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ONETRIALANAWINDOW_NEW.M with the given input arguments.
%
%      ONETRIALANAWINDOW_NEW('Property','Value',...) creates a new ONETRIALANAWINDOW_NEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OneTrialAnaWindow_new_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OneTrialAnaWindow_new_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OneTrialAnaWindow_new

% Last Modified by GUIDE v2.5 14-Nov-2015 15:36:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OneTrialAnaWindow_new_OpeningFcn, ...
                   'gui_OutputFcn',  @OneTrialAnaWindow_new_OutputFcn, ...
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


% --- Executes just before OneTrialAnaWindow_new is made visible.
function OneTrialAnaWindow_new_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OneTrialAnaWindow_new (see VARARGIN)

% Choose default command line output for OneTrialAnaWindow_new
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes OneTrialAnaWindow_new wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OneTrialAnaWindow_new_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_trialnum_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trialnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trialnum as text
%        str2double(get(hObject,'String')) returns contents of edit_trialnum as a double
trials = getappdata(0, 'trials');
input = get(hObject,'String');
try
    gototrial = str2double(input);
    if gototrial <= trials.stimnum && gototrial > 0
        axes(handles.ax_eyetrace)
        cla
        plotOneEyelid(gototrial)
        ylim([-0.5 1.05])
    else
        text(0,0,'Please do not try to plot nonexistant trials.')
    end
catch 
    set(hObject,'String', 'Trial')
    text(0,0,'You must enter a number in the textbox')
end


% --- Executes during object creation, after setting all properties.
function edit_trialnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trialnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton_previoustrial.
function pushbutton_previoustrial_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_previoustrial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curtrial = get(handles.edit_trialnum,'String');
try
    gototrial = str2double(curtrial) - 1;
    if gototrial >= 1
        axes(handles.ax_eyetrace)
        cla
        plotOneEyelid(gototrial)
        ylim([-0.2 1.05])
        set(handles.edit_trialnum,'String',num2str(gototrial))
    else
        text(0,0,'There are no more previous trials.')
    end
catch 
    text(0,0,'Please enter a number in the textbox.')
end


% --- Executes on button press in pushbutton_nexttrial.
function pushbutton_nexttrial_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_nexttrial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trials = getappdata(0, 'trials');
curtrial = get(handles.edit_trialnum,'String');
try
    if strcmp(curtrial,'Trial') && trials.stimnum > 0
        axes(handles.ax_eyetrace)
        cla
        plotOneEyelid(1)
        ylim([-0.2 1.05])
        set(handles.edit_trialnum,'String',num2str(1))
    else
        curtrial = str2double(curtrial);
        gototrial = curtrial + 1;
        if gototrial <= trials.stimnum
            axes(handles.ax_eyetrace)
            cla
            plotOneEyelid(gototrial)
            ylim([-0.2 1.05])
            set(handles.edit_trialnum,'String',num2str(gototrial))
        else
            text(0,0,'There are no more next trials.')
        end
    end
catch 
    % just wanted to catch the error
end
