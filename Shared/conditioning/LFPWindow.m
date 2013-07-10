function varargout = LFPWindow(varargin)
% LFPWINDOW MATLAB code for LFPWindow.fig
%      LFPWINDOW, by itself, creates a new LFPWINDOW or raises the existing
%      singleton*.
%
%      H = LFPWINDOW returns the handle to a new LFPWINDOW or the handle to
%      the existing singleton*.
%
%      LFPWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LFPWINDOW.M with the given input arguments.
%
%      LFPWINDOW('Property','Value',...) creates a new LFPWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LFPWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LFPWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LFPWindow

% Last Modified by GUIDE v2.5 26-Mar-2013 21:58:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @LFPWindow_OpeningFcn, ...
    'gui_OutputFcn',  @LFPWindow_OutputFcn, ...
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


% --- Executes just before LFPWindow is made visible.
function LFPWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LFPWindow (see VARARGIN)

% Choose default command line output for LFPWindow
handles.output = hObject;
handles.tnum_prev=NaN;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LFPWindow wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LFPWindow_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
t=timerfind('Name','analysisUpdateTimer');
if ~isempty(t)
    stop(t);
end
delete(t)
catch
    disp('Error in closing fig.')
end
% Hint: delete(hObject) closes the figure
delete(hObject);





% % --- Executes on slider movement.
% function slider_trialnum_Callback(hObject, eventdata, handles)
% % hObject    handle to slider_trialnum (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'Value') returns position of slider
% %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% 
% if strcmp(get(handles.edit_trialnum,'String'),'Trial Num')
%     set(handles.edit_trialnum,'String','0');
% end
% t_num=round(str2double(get(handles.edit_trialnum,'String'))+get(hObject,'Value'));
% 
% trials=getappdata(0,'trials');
% tnum_max=length(trials.eye);
% % set(handles.text_trialnum,'String',sprintf('Trial Viewer (1-%d)',tnum_max));
% 
% if t_num>tnum_max
%     t_num=tnum_max;
% elseif t_num<1
%     t_num=1;
% end
% set(handles.edit_trialnum,'String',num2str(t_num)),
% set(hObject,'Value',0),
% 
% if t_num~=handles.tnum_prev | t_num==tnum_max,
%     drawOneEyelid(handles,t_num);   
% end
% handles.tnum_prev=t_num;
% guidata(hObject,handles);


% % --- Executes during object creation, after setting all properties.
% function slider_trialnum_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to slider_trialnum (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: slider controls usually have a light gray background.
% if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor',[.9 .9 .9]);
% end
% set(hObject,'Value',0);


% function edit_trialnum_Callback(hObject, eventdata, handles)
% % hObject    handle to edit_trialnum (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of edit_trialnum as text
% %        str2double(get(hObject,'String')) returns contents of edit_trialnum as a double
% 
% t_num=round(str2double(get(handles.edit_trialnum,'String')));
% trials=getappdata(0,'trials');
% tnum_max=length(trials.eye);
% if t_num>tnum_max || t_num<1
%     if t_num<1
%         t_num=1;  
%     else
%         t_num=tnum_max;
%     end
%     set(handles.edit_trialnum,'String',num2str(t_num)),
% end
% 
% if t_num~=handles.tnum_prev | t_num==tnum_max,
%     drawOneEyelid(handles,t_num);   
% end
% handles.tnum_prev=t_num;
% guidata(hObject,handles);


% % --- Executes during object creation, after setting all properties.
% function edit_trialnum_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to edit_trialnum (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end

function edit_depth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_depth as text
%        str2double(get(hObject,'String')) returns contents of edit_depth as a double
str=get(hObject,'String');
set(handles.text13,'String',str);



% --- Executes during object creation, after setting all properties.
function edit_depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_psde1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_psde1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_psde1 as text
%        str2double(get(hObject,'String')) returns contents of edit_psde1 as a double



% --- Executes during object creation, after setting all properties.
function edit_psde1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_psde1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_psde2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_psde2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_psde2 as text
%        str2double(get(hObject,'String')) returns contents of edit_psde2 as a double


% --- Executes during object creation, after setting all properties.
function edit_psde2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_psde2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ymax as text
%        str2double(get(hObject,'String')) returns contents of edit_ymax as a double



% --- Executes during object creation, after setting all properties.
function edit_ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_trials_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trials as text
%        str2double(get(hObject,'String')) returns contents of edit_trials as a double




% --- Executes during object creation, after setting all properties.
function edit_trials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_trials2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trials2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trials2 as text
%        str2double(get(hObject,'String')) returns contents of edit_trials2 as a double


% --- Executes during object creation, after setting all properties.
function edit_trials2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trials2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton_update.
function pushbutton_update_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trials=getappdata(0,'trials');
tnum_max=length(trials.spk);

tr_set=make_trset(handles);

subplot('position',[0.10 0.72 0.86 0.25], 'Parent', handles.uipanel_LFP)
cla
subplot('position',[0.10 0.15 0.86 0.25], 'Parent', handles.uipanel_LFP)
cla

for i=1:length(tr_set)
lg_time=floor(270/trials.spk(tr_set{i}(1)).ts_interval);
timeset=NaN*ones(length(tr_set{i}),lg_time);  lfpset=NaN*ones(length(tr_set{i}),lg_time); ind_tr=1;
for t_num=tr_set{i}(:)',
    if t_num>tnum_max, continue, end
    ylim3=[-1 1]*str2num(get(handles.edit_ymax,'String'));
    col='k';
    eval(['drawOneLFP' num2str(i) '(handles,trials.spk(t_num).time,trials.spk(t_num).y,ylim3, col)']);
    
    ind1=find(trials.spk(t_num).time>-60);
    if isempty(ind1), continue, end
    if (ind1(1)+lg_time>length(trials.spk(t_num).time)), continue, end
    timeset(ind_tr,:)=trials.spk(t_num).time(ind1(1)+[0:lg_time-1]);
    lfpset(ind_tr,:)=trials.spk(t_num).y(ind1(1)+[0:lg_time-1]);
    ind_tr=ind_tr+1;
end
col='r';
eval(['drawOneLFP' num2str(i) '(handles, nanmean(timeset), nanmean(lfpset), ylim3, col)']);

end











%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% user difined functions %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tr_set=make_trset(handles)
trials=getappdata(0,'trials');
tnum_max=length(trials.spk);

depth_mat=NaN*ones(tnum_max,1);
for tr=1:tnum_max, if isempty(trials.params(tr).depth), continue, end, depth_mat(tr)=trials.params(tr).depth;  end
psde_mat=NaN*ones(tnum_max,1);
for tr=1:tnum_max, if isempty(trials.params(tr).psde), continue, end, psde_mat(tr)=trials.params(tr).psde;  end

tgt_depth=str2num(get(handles.edit_depth,'String'));
tgt_psde={str2num(get(handles.edit_psde1,'String')) str2num(get(handles.edit_psde2,'String'))};

elm_set={str2num(get(handles.edit_trials,'String')) str2num(get(handles.edit_trials2,'String'))};

tr_set=cell(1,2);
for i=1:length(tr_set)
    if isempty(tgt_depth)
        tr_set{i}=setdiff(find(psde_mat == tgt_psde{i}), elm_set{i});
    else
        tr_set{i}=setdiff(find((depth_mat == tgt_depth) & (psde_mat == tgt_psde{i})), elm_set{i});
    end
    if isnan(tr_set{i}), tr_set{i}=[1:tnum_max]; end
    if isempty(tr_set{i}), tr_set{i}=[1:tnum_max]; end
end

function drawOneLFP1(handles,time,spk,ylim3,linecol)

subplot('position',[0.10 0.63 0.86 0.35], 'Parent', handles.uipanel_LFP)

plot([0 0], [-1 1]*2000, 'k:'),  hold on,   
set(gca,'color',[240 240 240]/255);

plot(time,spk,linecol), 

xlim2=[-50 250];
set(gca,'xlim',xlim2,'xtick',[0:50:1000])
set(gca,'ylim',ylim3*1.0, 'ytick',ylim3,'yticklabel',{num2str(ylim3(1)) []}, 'box', 'off','tickdir','out')



function drawOneLFP2(handles,time,spk,ylim3,linecol)

subplot('position',[0.10 0.15 0.86 0.35], 'Parent', handles.uipanel_LFP)

plot([0 0], [-1 1]*2000, 'k:'),  hold on,   
set(gca,'color',[240 240 240]/255);

plot(time,spk,linecol), 

xlim2=[-50 250];
set(gca,'xlim',xlim2,'xtick',[0:50:1000])
set(gca,'ylim',ylim3*1.0, 'ytick',ylim3, 'box', 'off','tickdir','out')
xlabel('Time from stimulus or CS onset (ms)')



% function drawOneEyelid(handles,t_num)
% 
% trials=getappdata(0,'trials');
% tnum_max=length(trials.eye);
% str_tl={[sprintf('Trial Viewer (1-%d)',tnum_max)] [trials.eye(t_num).stimtype]};
% 
% % ------- for eye -----
% subplot('position',[0.05 0.17 0.90 0.50], 'Parent', handles.uipanel_LFP)
% cla
% plot([-1 1]*1000, [0 0],'k:'),  hold on,   plot([-1 1]*1000, [1 1],'k:'), 
% 
% set(gca,'ylim',[-0.15 1.20], 'ytick',[0:0.5:1], 'box', 'off','tickdir','out')
% 
% xlim1=[trials.eye(t_num).time(1) trials.eye(t_num).time(end)];
% plotOneEyelid(t_num);
% 
% text(xlim1*[0.33;0.67], -0.46, str_tl)
% set(gca,'xlim',xlim1,'xtick',[-400:200:1000])
% set(gca,'color',[240 240 240]/255);
% 
% 
% % ------- for spk -----
% 
% % tnum_max=length(trials.spk);
% % ylim_low=400;
% % if t_num>tnum_max, 
% %     ylim2=ylim_low*[1 1];
% % elseif isempty(trials.spk(t_num).ylim)
% %     ylim2=ylim_low*[1 1];
% % else
% %     ylim2=abs(trials.spk(t_num).ylim); 
% % end
% % ylim1=NaN*ones(tnum_max,2);
% % for i=max(1,t_num-10):t_num,   if ~isempty(trials.spk(i).ylim), ylim1(i,:)=trials.spk(i).ylim;  end, end
% % % ylim1(find(abs(ylim1)<ylim_low))=NaN;
% % ylim2=abs(nanmedian(ylim1));  
% % ylim3=ylim_low*[1 1];  ylim3(ylim2>ylim_low)=ylim2(ylim2>ylim_low); ylim3(1)=-ylim3(1);
% ylim3=[-1 1]*str2num(get(handles.edit_ymax,'String'));
% 
% drawOneSpk(handles,t_num,ylim3)
