function refreshParams(hObject)

% Load objects from root app data
% TDT=getappdata(0,'tdt');
metadata=getappdata(0,'metadata');
handles=guidata(hObject);
trials=getappdata(0,'trials');

trials.savematadata=get(handles.checkbox_save_metadata,'Value');


% --- conditioning -----
trialvars=readTrialTable(metadata.eye.trialnum1);
metadata.stim.c.csdur=trialvars(1);
metadata.stim.c.csnum=trialvars(2);
metadata.stim.c.isi=trialvars(3);
metadata.stim.c.usdur=trialvars(4);
metadata.stim.c.tonefreq=str2num(get(handles.edit_tone,'String'))*1000;
if length(metadata.stim.c.tonefreq)<2, metadata.stim.c.tonefreq(2)=0; end
metadata.stim.c.toneamp=str2num(get(handles.edit_toneamp,'String'));
if length(metadata.stim.c.toneamp)<2, metadata.stim.c.toneamp(2)=0; end

% Set ITI using base time plus optional random range
base_ITI = str2double(get(handles.edit_ITI,'String'));
rand_ITI = str2double(get(handles.edit_ITI_rand,'String'));
metadata.stim.c.ITI = base_ITI + rand(1,1) * rand_ITI;


% For calibration trials, set CS and ISI to zero and use puff duration specified in edit box.
if metadata.cam.cal
    metadata.stim.c.csdur=200;
    metadata.stim.c.csnum=0;
    metadata.stim.c.isi=200;
    metadata.stim.c.usdur=str2double(get(handles.edit_puffdur,'String'));
end 


metadata.stim.totaltime=metadata.stim.c.csdur+metadata.stim.c.usdur;    % So that same duration is recorded even if using two different ISIs (b/c CS dur is same)
   
metadata.cam.time(1)=str2double(get(handles.edit_pretime,'String'));
metadata.cam.time(2)=metadata.stim.totaltime;
metadata.cam.time(3)=str2double(get(handles.edit_posttime,'String'))-metadata.stim.totaltime;

metadata.now=now;

setappdata(0,'trials',trials);
setappdata(0,'metadata',metadata);
