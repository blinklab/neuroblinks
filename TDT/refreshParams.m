function refreshParams(hObject)

% Load objects from root app data
% TDT=getappdata(0,'tdt');
metadata=getappdata(0,'metadata');
handles=guidata(hObject);
trials=getappdata(0,'trials');

trials.savematadata=get(handles.checkbox_save_metadata,'Value');

metadata.stim.e.freq=str2double(get(handles.edit_estimfreq,'String'));
metadata.stim.e.pulsewidth=str2double(get(handles.edit_epulsewidth,'String'));
metadata.stim.e.traindur=str2double(get(handles.edit_etraindur,'String'));
metadata.stim.e.amp=str2double(get(handles.edit_estimamp,'String'));
metadata.stim.e.delay=str2double(get(handles.edit_estimdelay,'String'));
metadata.stim.e.depth=str2double(get(handles.edit_estimdepth,'String'));

metadata.stim.l.freq=str2double(get(handles.edit_lstimfreq,'String'));
metadata.stim.l.pulsewidth=str2double(get(handles.edit_lpulsewidth,'String'));
metadata.stim.l.traindur=str2double(get(handles.edit_ltraindur,'String'));
metadata.stim.l.amp=str2double(get(handles.edit_lstimamp,'String'));
metadata.stim.l.delay=str2double(get(handles.edit_lstimdelay,'String'));
metadata.stim.l.depth=str2double(get(handles.edit_lstimdepth,'String'));
metadata.stim.l.ramptm=str2double(get(handles.edit_lramptm,'String'));

metadata.stim.c.puffdelay=str2double(get(handles.edit_puffdelay,'String'));
metadata.stim.c.puffdur=str2double(get(handles.edit_puffdur,'String'));

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

metadata.stim.c.ITI=str2double(get(handles.edit_ITI,'String'));

puffsidestring={'ipsi' 'contra'};
metadata.stim.p.side_value=get(handles.radiobutton_contra,'Value');
metadata.stim.p.side=puffsidestring{metadata.stim.p.side_value+1};
metadata.stim.p.puffdelay=str2double(get(handles.edit_puffdelay,'String'));
metadata.stim.p.puffdur=str2double(get(handles.edit_puffdur,'String'));

val=get(handles.popupmenu_stimtype,'Value');
str=get(handles.popupmenu_stimtype,'String');
metadata.stim.type=str{val};
if metadata.cam.cal, metadata.stim.type='Puff'; end % for Cal
stimmode=metadata.stim.type;

switch lower(stimmode)
    case 'none'
        metadata.stim.totaltime=0;
    case 'puff'
        metadata.stim.totaltime=metadata.stim.p.puffdelay+metadata.stim.p.puffdur;
    case 'electrical'
        metadata.stim.totaltime=metadata.stim.e.traindur+metadata.stim.e.delay;
    case 'conditioning'
        % metadata.stim.totaltime=metadata.stim.c.isi+metadata.stim.c.usdur;
        metadata.stim.totaltime=metadata.stim.c.csdur+metadata.stim.c.usdur;    % So that same duration is recorded even if using two different ISIs (b/c CS dur is same)
    case {'optical','optocondition'}
        metadata.stim.totaltime=metadata.stim.l.traindur+metadata.stim.l.delay;
    case 'optoelectric'
        metadata.stim.totaltime=max(metadata.stim.e.traindur+metadata.stim.e.delay,...
            metadata.stim.l.traindur+metadata.stim.l.delay);      
    otherwise
        metadata.stim.totaltime=0;
        warning('Unknown stimulation mode set.');
end

metadata.cam.time(1)=str2double(get(handles.edit_pretime,'String'));
metadata.cam.time(2)=metadata.stim.totaltime;
metadata.cam.time(3)=str2double(get(handles.edit_posttime,'String'));

metadata.now=now;
% --- saving params to memory for LFP online ana ---
tnum=metadata.cam.trialnum;
trials.params(tnum).depth=max(metadata.stim.e.depth,metadata.stim.l.depth);
trials.params(tnum).psde=metadata.stim.p.side_value;

setappdata(0,'trials',trials);
setappdata(0,'metadata',metadata);
