function varargout = AnalysisWindow(varargin)
% ANALYSISWINDOW MATLAB code for AnalysisWindow.fig
%      ANALYSISWINDOW, by itself, creates a new ANALYSISWINDOW or raises the existing
%      singleton*.
%
%      H = ANALYSISWINDOW returns the handle to a new ANALYSISWINDOW or the handle to
%      the existing singleton*.
%
%      ANALYSISWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYSISWINDOW.M with the given input arguments.
%
%      ANALYSISWINDOW('Property','Value',...) creates a new ANALYSISWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnalysisWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnalysisWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnalysisWindow

% Last Modified by GUIDE v2.5 31-Jan-2013 19:47:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @AnalysisWindow_OpeningFcn, ...
    'gui_OutputFcn',  @AnalysisWindow_OutputFcn, ...
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


% --- Executes just before AnalysisWindow is made visible.
function AnalysisWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AnalysisWindow (see VARARGIN)

ghandles=getappdata(0,'ghandles');
ghandles.flttrgnum=0;
setappdata(0,'ghandles',ghandles);

handles.time1=clock;
% Choose default command line output for AnalysisWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



% UIWAIT makes AnalysisWindow wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AnalysisWindow_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_TDTConnect.
function pushbutton_TDTConnect_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_TDTConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% -- init flttrgnum ---
ghandles=getappdata(0,'ghandles');
ghandles.flttrgnum=0;
setappdata(0,'ghandles',ghandles);

TTX=getappdata(0,'ttx');

block=TTX.GetHotBlock;

if isempty(block)
    error('You are not currently recording to a block')
end

ok=TTX.SelectBlock(block);

if ~ok
    error('Could not select current block.')
end

set(handles.pushbutton_TDTConnect,'String',block)

% Populate UI lists
eventlist=TDTgetEventChans(TTX);
set(handles.popupmenu_events,'String',eventlist(:));
set(handles.popupmenu_filterevents,'String',eventlist(:));

[ts,allvalues]=TDTgetEventData(TTX,'Unit');
values=unique(allvalues);
set(handles.popupmenu_units,'String',values);
% set(handles.popupmenu_units,'Value',1);

updateFilterEvents(TTX,handles)

[ts,waves,sortcodes]=TDTgetSpikeData(TTX,'Snip');
set(handles.listbox_snips,'String',unique(sortcodes));

% Generate filter data type
filterSet=containers.Map();
setappdata(0,'filterSet',filterSet);

handles.time1=clock;
guidata(hObject, handles);



% --- Executes on button press in pushbutton_update.
function pushbutton_update_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

metadata=getappdata(0,'metadata');
block=get(handles.pushbutton_TDTConnect,'String');
if ~strcmpi(metadata.TDTblockname,block)
    pushbutton_TDTConnect_Callback(hObject, eventdata, handles);
    pause(0.5);
end

t0 = clock;

etime1=etime(t0, handles.time1);
handles.time1=t0;
guidata(hObject, handles);

if etime1<0.5,  return,  end

drawEyelid(handles);
units=get(handles.popupmenu_units,'String');
selectedunit=units(get(handles.popupmenu_units,'Value'));
if strcmpi(selectedunit,'N'),
    sortcodes=get(handles.listbox_snips,'String');
    if strcmpi(sortcodes(get(handles.listbox_snips,'Value')),'0'),
        return,
    end
end
plotNeuronData(handles)


function edit_updateinterval_Callback(hObject, eventdata, handles)
% hObject    handle to edit_updateinterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_updateinterval as text
%        str2double(get(hObject,'String')) returns contents of edit_updateinterval as a double

% First get the value of the editbox
updateInterval=str2num(get(hObject,'String'));

if updateInterval<=0
    % Stop timer
    t=timerfind('Name','analysisUpdateTimer');
    stop(t);
    delete(t)
else
    t=timerfind('Name','analysisUpdateTimer');
    if ~isempty(t)
        stop(t);
    end
    delete(t)
    analysisUpdateTimer=timer('Name','analysisUpdateTimer','Period',updateInterval,'ExecutionMode','FixedRate',...
        'TimerFcn',{@analysisUpdateTimer,handles},'BusyMode','queue','StartDelay',0);
    start(analysisUpdateTimer);
end


% --- Executes during object creation, after setting all properties.
function edit_updateinterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_updateinterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_events.
function popupmenu_events_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_events contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_events


% --- Executes during object creation, after setting all properties.
function popupmenu_events_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_snips.
function listbox_snips_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_snips (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_snips contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_snips
ghandles=getappdata(0,'ghandles');
ghandles.flttrgnum=0;
setappdata(0,'ghandles',ghandles);



% --- Executes during object creation, after setting all properties.
function listbox_snips_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_snips (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_filterevents.
function popupmenu_filterevents_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_filterevents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_filterevents contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_filterevents

TTX=getappdata(0,'ttx');
updateFilterEvents(TTX,handles)


% --- Executes during object creation, after setting all properties.
function popupmenu_filterevents_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_filterevents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_eventvalues.
function listbox_eventvalues_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_eventvalues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_eventvalues contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_eventvalues
ghandles=getappdata(0,'ghandles');
ghandles.flttrgnum=0;
setappdata(0,'ghandles',ghandles);


% --- Executes during object creation, after setting all properties.
function listbox_eventvalues_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_eventvalues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_addFilterItem.
function pushbutton_addFilterItem_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_addFilterItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

events=get(handles.popupmenu_filterevents,'String');
eventnum=get(handles.popupmenu_filterevents,'Value');
event=events(eventnum);

values=str2num(get(handles.listbox_eventvalues,'String'));
valuenum=get(handles.listbox_eventvalues,'Value');
filtervalues=values(valuenum);

for i=1:length(filtervalues)
    addFilterItem(event{:},filtervalues(i));
end

printFilterSet(handles);


% --- Executes on button press in pushbutton_removeFilterItem.
function pushbutton_removeFilterItem_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_removeFilterItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

events=get(handles.popupmenu_filterevents,'String');
eventnum=get(handles.popupmenu_filterevents,'Value');
event=events(eventnum);

values=str2num(get(handles.listbox_eventvalues,'String'));
valuenum=get(handles.listbox_eventvalues,'Value');
filtervalues=values(valuenum);

for i=1:length(filtervalues)
    removeFilterItem(event{:},filtervalues(i));
end

printFilterSet(handles);


% --- Executes on button press in pushbutton_clearFilterItems.
function pushbutton_clearFilterItems_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_clearFilterItems (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clearFilterSet();
printFilterSet(handles);



function analysisUpdateTimer(obj,event,handles)

disp(sprintf('Instant period of update timer=%3.2f',get(obj,'InstantPeriod')));
plotNeuronData(handles);


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


% --- Executes on selection change in popupmenu_units.
function popupmenu_units_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_units


% --- Executes during object creation, after setting all properties.
function popupmenu_units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_stime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stime as text
%        str2double(get(hObject,'String')) returns contents of edit_stime as a double


% --- Executes during object creation, after setting all properties.
function edit_stime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_etime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_etime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_etime as text
%        str2double(get(hObject,'String')) returns contents of edit_etime as a double


% --- Executes during object creation, after setting all properties.
function edit_etime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_etime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% user difined functions %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function updateFilterEvents(TTX,handles)

% Which event name is selected?
eventlist=get(handles.popupmenu_filterevents,'String');
listnum=get(handles.popupmenu_filterevents,'Value');
eventname=eventlist{listnum};

% List the possible values for that event
[ts,allvalues]=TDTgetEventData(TTX,eventname);
values=unique(allvalues);

oldval=get(handles.listbox_eventvalues,'Value');
if oldval(end) > length(values)
    set(handles.listbox_eventvalues,'Value',1);
end

set(handles.listbox_eventvalues,'String',num2str(values(:)));

function printFilterSet(handles)

filterSet=getappdata(0,'filterSet');

events=keys(filterSet);

s='Current filter is: ';

for i=1:length(events)
    values=filterSet(events{i});
    se=[];
    for j=1:length(values)
        se=[se num2str(values(j)) ', '];
    end
    s=[s events{i} '=' se];
end

set(handles.text_statusBar,'String',s);

ghandles=getappdata(0,'ghandles');
ghandles.flttrgnum=0;
setappdata(0,'ghandles',ghandles);


function addFilterItem(event,value)

filterSet=getappdata(0,'filterSet');

if isKey(filterSet,event)
    values=filterSet(event);
    filterSet(event)=unique([values value]);
else
    filterSet(event)=value;
end

setappdata(0,'filterSet',filterSet)

function removeFilterItem(event,value)

filterSet=getappdata(0,'filterSet');

if isKey(filterSet,event)
    values=filterSet(event);
    values(values==value)=[];
    filterSet(event)=values;
    if isempty(values)
        remove(filterSet,event);
    end
end

setappdata(0,'filterSet',filterSet)

function clearFilterSet()
filterSet=getappdata(0,'filterSet');
filterSet=containers.Map(); % Just create a new hash table and overwrite the previous one

setappdata(0,'filterSet',filterSet)


function plotNeuronData(handles)
% Plot all neural data to the location specified by panelhandle. It is up to this function to determine what is plotted, layout, etc.

% {raster,psth,spkshapes1,isi1,spkshapes2,isi2,summary text}
subpanels={
    [1:4,7:10],...
    [13:16,19:22],...
    5,...
    11,...
    6,...
    12,...
    [17,18,23,24]
    };

TTX=getappdata(0,'ttx');
ghandles=getappdata(0,'ghandles');
% Figure out what we're plotting and grab data

% --- sort code ---
sortcodes=get(handles.listbox_snips,'String');
sortcodevalues=get(handles.listbox_snips,'Value');
selectedsortcodes=str2double(sortcodes(sortcodevalues));

% --- Call filtered_trigger ----
flttrg=filtered_trigger(handles);
ts_flttrg=flttrg.ts_trigs(flttrg.idx_flt);
if isempty(ts_flttrg), return, elseif isnan(ts_flttrg), return, end
if ghandles.flttrgnum==length(ts_flttrg), 
    disp('No data which has not yet been drawn.'), return,  end
% to reflesh ghandles.flttrgnum, press any (e.g. TDT connect) button.
ghandles.flttrgnum=length(ts_flttrg);
setappdata(0,'ghandles',ghandles)
pause(0.01)
% ----- 

TTX.CreateEpocIndexing; % Do we have to run this each time?
TTX.ResetFilters;

units=get(handles.popupmenu_units,'String');
val=get(handles.popupmenu_units,'Value');
selectedunit=units(val);
% if length(units) < 2
%     units={units};  % Make it a cell array like a list would be
% end

sttime=str2double(get(handles.edit_stime,'String'));
endtime=str2double(get(handles.edit_etime,'String'));

TTX.SetFilterWithDesc(sprintf('Unit=%s',selectedunit)); % e.g. 'Unit=1'

pause(0.01)
% Get spike data based on selected unit number
% [spiketimes,spikeshapes,sortcodes]=TDTgetSpikeData(TTX,'Snip',0,0,'ALL');
[spiketimes,spikeshapes,sortcodes]=TDTgetSpikeData(TTX,'Snip',sttime,endtime,'FILTERED');

sortedspiketimes=spiketimes(ismember(sortcodes,selectedsortcodes));

binsz=0.005;
pretm=0.2;
posttm=0.6;

[histdata,rasterdata,countdata]=fpsth(sortedspiketimes, ts_flttrg, binsz, pretm, posttm, 'rect', 0.01);
hst=histdata(1,:)/binsz;
bins=histdata(2,:);
raster=rasterdata(1:size(rasterdata,1)-1,:);
rasterbins=rasterdata(size(rasterdata,1),:);

set(0,'CurrentFigure',ghandles.analysisgui)
subplot(4,6,subpanels{1},'Parent',handles.uipanel_neuron)
plotraster(rasterbins,raster,'k',0.2,0.1)
set(gca,'TickDir','out','XTick',-pretm:0.1:posttm)
axis([-pretm posttm 0 size(raster,1)+1])
ylabel('Sweeps')
axis off
drawnow

set(0,'CurrentFigure',ghandles.analysisgui)
subplot(4,6,subpanels{2},'Parent',handles.uipanel_neuron)
plot(bins,hst,'k')
a=axis;
axis([-pretm posttm 0 a(4)])
set(gca,'TickDir','out','XTick',-pretm:0.2:posttm,'XTickLabel',(-pretm:0.2:posttm)*1e3)
xlabel('Time from trigger (ms)')
ylabel('Firing rate (spk/s)')
drawnow

% Sorted unit i
spk_col={'k' 'r'};  isi_lim=[0.026 0.101];

for i=1:2,
    idx{i}=find(sortcodes==i);
    
    if ~isempty(idx{i})
        spknum=min(length(idx{i}), 20)-1;
        isipts=min(length(idx{i}),1e3)-1;
        
        % Spike shapes
        set(0,'CurrentFigure',ghandles.analysisgui)
        subplot(4,6,subpanels{2*i+1},'Parent',handles.uipanel_neuron)
        [m,n]=size(spikeshapes);
        spks=spikeshapes(1:m,idx{i}(end-spknum:end));
        plot(spks,spk_col{i})
        axis([1, m, min(spks(:)), max(spks(:))])
        axis off
        drawnow
        
        
        % ISIs
        set(0,'CurrentFigure',ghandles.analysisgui)
        subplot(4,6,subpanels{2*i+2},'Parent',handles.uipanel_neuron)
        [isi,ibins]=hist(diff(spiketimes(idx{i}(end-isipts:end))),0:0.001:isi_lim(i));
        bar(ibins(1:end-1),isi(1:end-1),spk_col{i})
        a=axis;
        axis([ibins(1), ibins(end) 0 a(4)])
        % set(gca,'YTick',[])
        axis off
        drawnow
    end
end

set(0,'CurrentFigure',ghandles.analysisgui)
drawnow


function flttrg=filtered_trigger(handles)
% Get timestamp of trigger (event) and filtered index (# in the trials with trigger).
TTX=getappdata(0,'ttx');
filterSet=getappdata(0,'filterSet');
%------ Everything here should be added to a function -------%
sttime=str2double(get(handles.edit_stime,'String'));
endtime=str2double(get(handles.edit_etime,'String'));

% Get all event data relevant to the trigger and currently set filter.
trigevents=get(handles.popupmenu_events,'String');
trigval=get(handles.popupmenu_events,'Value');
trigevent=trigevents{trigval};

if strcmpi(trigevent,'N'),  flttrg.ts_trigs=[]; flttrg.idx_flt=[]; return, end

[trigs, trigvalues]=TDTgetEventData(TTX, trigevent, sttime, endtime, 'ALL');

index=1:length(trigs);  % This is our starting index before applying any event filtering

filterevents=keys(filterSet);
for i=1:length(filterevents)
    [ts,values]=TDTgetEventData(TTX,filterevents{i},sttime,endtime,'ALL');
    idx=1:length(ts);
    filtvalues=filterSet(filterevents{i});
    index=intersect(index,idx(ismember(values,filtvalues))); % During each loop the index of valid triggers is decreased based on the event filters.
end
flttrg.ts_trigs=trigs;
flttrg.idx_flt=index;


function drawEyelid(handles)
trials=getappdata(0,'trials');
ghandles=getappdata(0,'ghandles');
% --- load TrlN ----
TTX=getappdata(0,'ttx');
[trln_ts,trln_values]=TDTgetEventData(TTX,'TrlN',0,0,'ALL');

% --- Call filtered_trigger ----
flttrg=filtered_trigger(handles);
ts_flttrg=flttrg.ts_trigs(flttrg.idx_flt);
if isempty(ts_flttrg), return, elseif isnan(ts_flttrg), return, end
if ghandles.flttrgnum==length(ts_flttrg),  disp('No data which has not yet been drawn.'), return, end

% --- calc corresponding trialnum (TrlN) ----
trigevents=get(handles.popupmenu_events,'String');
trigevent=trigevents{get(handles.popupmenu_events,'Value')};

if ~strcmpi(trigevent,'N')
    [ind1, dist1] = nearestpoint(ts_flttrg, trln_ts);
    if ~isnan(ind1)
        flttnum=trln_values(ind1);
        flttnum=flttnum(flttnum>0);  % remove CalTrial
    else
        flttnum=1:length(trials.eye);
    end
else
    flttnum=1:length(trials.eye);
end


% ------- init fig -----
subplot('position',[0.05 0.16 0.30 0.82], 'Parent', handles.uipanel_behavior)
cla
plot([-1 1]*1000, [0 0],'k:'),  hold on,   plot([-1 1]*1000, [1 1],'k:'), 
set(gca,'ylim',[-0.15 1.20], 'ytick',[0:0.5:1], 'box', 'off','tickdir','out')

for t_num=flttnum,
    plotOneEyelid(t_num);
end
set(gca,'xlim',[trials.eye(t_num).time(1) trials.eye(t_num).time(end)],'xtick',[-400:200:1000])
set(gca,'color',[240 240 240]/255)
xlabel('Time from trial oset (ms)')




