function varargout = NoteWindow(varargin)
% NOTEWINDOW MATLAB code for NoteWindow.fig
%      NOTEWINDOW, by itself, creates a new NOTEWINDOW or raises the existing
%      singleton*.
%
%      H = NOTEWINDOW returns the handle to a new NOTEWINDOW or the handle to
%      the existing singleton*.
%
%      NOTEWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NOTEWINDOW.M with the given input arguments.
%
%      NOTEWINDOW('Property','Value',...) creates a new NOTEWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NoteWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NoteWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NoteWindow

% Last Modified by GUIDE v2.5 07-Oct-2015 14:54:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NoteWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @NoteWindow_OutputFcn, ...
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


% --- Executes just before NoteWindow is made visible.
function NoteWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NoteWindow (see VARARGIN)

% Choose default command line output for NoteWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% change notedata to reflect that note is being made by person (change
% Event Type in notedata.note)
notedata = getappdata(0, 'notedata');
notedata.note{1,2} = 'User Input';
setappdata(0, 'notedata', notedata)

% UIWAIT makes NoteWindow wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NoteWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in setTimestamp.
function setTimestamp_Callback(hObject, eventdata, handles)
% hObject    handle to setTimestamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% find current time and trial, then save these into the notedata
notedata = getappdata(0, 'notedata');
notedata.note{1,3} = datestr(now, 'hh:mm:ss');
metadata = getappdata(0, 'metadata');
try
    nextTrial = metadata.eye.trialnum1;
catch ME
    nextTrial = 1;
end
notedata.note{1,4} = nextTrial - 1;  % assume the user is interested in the trial that just happened
setappdata(0, 'notedata', notedata)

% update display in GUI
set(handles.NoteTSText, 'String', notedata.note{1,3})
set(handles.NoteTrialText, 'String', notedata.note{1,4})






% --- Executes on button press in appendNote.
function appendNote_Callback(hObject, eventdata, handles)
% hObject    handle to appendNote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% append the note to file
notedata = getappdata(0, 'notedata');
appendcell2csv(notedata.filename,notedata.note);

% set timestamp to current time
setTimestamp_Callback(handles.setTimestamp, eventdata, handles)





% --- Executes on button press in cancelNote.
function cancelNote_Callback(hObject, eventdata, handles)
% hObject    handle to cancelNote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get rid of the information contained in notedata.note (except for
% subject)
notedata = getappdata(0, 'notedata');
notedata.note{1,2} = [];
notedata.note{1,3} = [];
notedata.note{1,4} = [];
notedata.note{1,5} = [];
setappdata(0, 'notedata', notedata)

% close the gui window
close(handles.figure1)




function newNoteText_Callback(hObject, eventdata, handles)
% hObject    handle to newNoteText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set notedata.note to have this comment
comment = get(hObject, 'String');
notedata = getappdata(0, 'notedata');
notedata.note{1,5} = comment;
setappdata(0, 'notedata', notedata)


% Hints: get(hObject,'String') returns contents of newNoteText as text
%        str2double(get(hObject,'String')) returns contents of newNoteText as a double


% --- Executes during object creation, after setting all properties.
function newNoteText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newNoteText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
notedata = getappdata(0, 'notedata');
notedata.handles.newNote = hObject;
setappdata(0, 'notedata', notedata)



function NoteTSText_Callback(hObject, eventdata, handles, currentTime)
% hObject    handle to NoteTSText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update notedata.note to have the user-defined time
notedata = getappdata(0, 'notedata');
notedata.note{1,3} = get(hObject, 'String');
setappdata(0, 'notedata', notedata)



% Hints: get(hObject,'String') returns contents of NoteTSText as text
%        str2double(get(hObject,'String')) returns contents of NoteTSText as a double


% --- Executes during object creation, after setting all properties.
function NoteTSText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoteTSText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% set the TS to the current time
curTime = datestr(now, 'hh:mm:ss');
set(hObject, 'String', curTime)

% store the handles for this part of the gui and set notedata to have the
% right time stored
notedata = getappdata(0, 'notedata');
notedata.handles.NoteTS = hObject;
notedata.note{1,3} = curTime;
setappdata(0, 'notedata', notedata)



function NoteTrialText_Callback(hObject, eventdata, handles)
% hObject    handle to NoteTrialText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

notedata = getappdata(0, 'notedata');
notedata.note{1,4} = get(hObject, 'String');
setappdata(0, 'notedata', notedata)

% Hints: get(hObject,'String') returns contents of NoteTrialText as text
%        str2double(get(hObject,'String')) returns contents of NoteTrialText as a double


% --- Executes during object creation, after setting all properties.
function NoteTrialText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoteTrialText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% set handles in notedata and add correct current trial number
notedata = getappdata(0, 'notedata');
notedata.handles.NoteTrial = hObject;
metadata = getappdata(0, 'metadata');
try
    nextTrial = metadata.eye.trialnum1;
catch ME
    nextTrial = 1;
end
lastTrial = nextTrial - 1;
notedata.note{1,4} = lastTrial;
setappdata(0, 'notedata', notedata)

% update display in GUI
set(hObject, 'String', lastTrial)
