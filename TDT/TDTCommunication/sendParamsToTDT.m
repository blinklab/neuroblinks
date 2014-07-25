function sendParamsToTDT(hObject)

% Load objects from root app data
TDT=getappdata(0,'tdt'); 
metadata=getappdata(0,'metadata');

refreshParams(hObject)
handles=guidata(hObject);

% Pass pulse values for Camera to TDT - even if we're not actually recording to disk
T_length=(sum(metadata.cam.time))./1000;
frames_per_trial=ceil(metadata.cam.fps.*T_length);
TDT.SetTargetVal('ustim.FramePulse',1e3/(2*metadata.cam.fps));
TDT.SetTargetVal('ustim.NumFrames',frames_per_trial);

% ---- for electrical stimulation ----
TDT.SetTargetVal('ustim.EPulseFreq',metadata.stim.e.freq);
TDT.SetTargetVal('ustim.EPulseWidth',metadata.stim.e.pulsewidth);
TDT.SetTargetVal('ustim.ETrainDur',metadata.stim.e.traindur);
TDT.SetTargetVal('ustim.EStimAmp',metadata.stim.e.amp);
TDT.SetTargetVal('ustim.EStimDelay',metadata.stim.e.delay);
TDT.SetTargetVal('ustim.EStimDepth',metadata.stim.e.depth);

% ---- for Laser stimulation ----
TDT.SetTargetVal('ustim.LPulseFreq',metadata.stim.l.freq);
TDT.SetTargetVal('ustim.LPulseWidth',metadata.stim.l.pulsewidth);
TDT.SetTargetVal('ustim.LTrainDur',metadata.stim.l.traindur);
TDT.SetTargetVal('ustim.LStimAmp',metadata.stim.l.amp);
TDT.SetTargetVal('ustim.LStimDelay',metadata.stim.l.delay);
TDT.SetTargetVal('ustim.LStimDepth',metadata.stim.l.depth);
TDT.SetTargetVal('ustim.RampTime',metadata.stim.l.ramptm);

if metadata.stim.l.ramptm > 0
    TDT.SetTargetVal('ustim.PulseShape',1);
else
    TDT.SetTargetVal('ustim.PulseShape',0);
end

% Have to subtract 1 b/c TDT is zero-referenced and Matlab is
% one-referenced

% if get(handles.checkbox_RX6,'Value'),
%     TDT.SetTargetVal('Stim.PreStimTime',metadata.cam.time(1)); 
%     TDT.SetTargetVal('Stim.CsDur',metadata.stim.c.csdur);
%     TDT.SetTargetVal('Stim.ISI',metadata.stim.c.isi);
%     TDT.SetTargetVal('Stim.UsDur',metadata.stim.c.usdur);
%     TDT.SetTargetVal('Stim.PuffMDelay',metadata.stim.c.puffdelay);
%     TDT.SetTargetVal('Stim.PuffDurM',metadata.stim.c.puffdur);
%     TDT.SetTargetVal('Stim.PuffSide',metadata.stim.p.side_value);
% end

% --- behavioral stim by RZ5 ---- 
TDT.SetTargetVal('ustim.ITI',metadata.stim.c.ITI);
TDT.SetTargetVal('ustim.CsDur',metadata.stim.c.csdur);
csnum=metadata.stim.c.csnum;  cstonefreq=0;  cstoneamp=0;
if ismember(csnum,[5 6]),  
    cstonefreq=min(metadata.stim.c.tonefreq(csnum-4), 40000);  
    cstoneamp=metadata.stim.c.toneamp(csnum-4);
    csnum=0; 
end
TDT.SetTargetVal('ustim.CSNum',csnum);
TDT.SetTargetVal('ustim.CSToneFreq',cstonefreq);
TDT.SetTargetVal('ustim.CSToneAmp',cstoneamp);
% csnum,cstonefreq,

TDT.SetTargetVal('ustim.ISI',metadata.stim.c.isi);
TDT.SetTargetVal('ustim.UsDur',metadata.stim.c.usdur);
TDT.SetTargetVal('ustim.PreStimTime',metadata.cam.time(1));
% TDT.SetTargetVal('ustim.PuffMDelay',metadata.stim.c.puffdelay);
TDT.SetTargetVal('ustim.PuffDurM',metadata.stim.c.puffdur);
TDT.SetTargetVal('ustim.PuffSide',metadata.stim.p.side_value);

switch lower(metadata.stim.type)
    case {'conditioning','electrocondition','optocondition'}
        TDT.SetTargetVal('ustim.TrialType',0);
    case {'puff'}
        TDT.SetTargetVal('ustim.TrialType',1);
    case {'none','electrical','optical','optoelectric'}
        TDT.SetTargetVal('ustim.TrialType',3);
end

switch lower(metadata.stim.type)
    case {'electrical'}
        TDT.SetTargetVal('ustim.StimDevice',0);
    case {'optical','optocondition'}
        TDT.SetTargetVal('ustim.StimDevice',1);
    case {'optoelectric','electrocondition'}
        TDT.SetTargetVal('ustim.StimDevice',2);
    case {'none','puff','conditioning'}
        TDT.SetTargetVal('ustim.StimDevice',3);
end

if get(handles.togglebutton_ampblank,'Value')   % If amplifier blank is set
    TDT.SetTargetVal('ustim.BlankAmp',1);
    TDT.SetTargetVal('ustim.BlankExtra',str2double(get(handles.edit_blankampextratime,'String')));
else
    TDT.SetTargetVal('ustim.BlankAmp',0);
end












