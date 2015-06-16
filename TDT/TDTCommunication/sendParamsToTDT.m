function sendParamsToTDT(hObject)

% Load objects from root app data
TDT=getappdata(0,'tdt'); 
metadata=getappdata(0,'metadata');

refreshParams(hObject)
handles=guidata(hObject);

% Pass pulse values for Camera to TDT - even if we're not actually recording to disk
T_length=(sum(metadata.cam.time))./1000;
frames_per_trial=ceil(metadata.cam.fps.*T_length);
TDT.SetTargetVal('task-timer.FramePulse',1e3/(2*metadata.cam.fps));
TDT.SetTargetVal('task-timer.NumFrames',frames_per_trial);


% --- For timing of conditioning trials using RZ5 ---- 
TDT.SetTargetVal('task-timer.ITI',metadata.stim.c.ITI);
TDT.SetTargetVal('task-timer.CsDur',metadata.stim.c.csdur);
csnum=metadata.stim.c.csnum;  cstonefreq=0;  cstoneamp=0;
if ismember(csnum,[5 6]),  
    cstonefreq=min(metadata.stim.c.tonefreq(csnum-4), 40000);  
    cstoneamp=metadata.stim.c.toneamp(csnum-4);
    csnum=0; 
end
TDT.SetTargetVal('task-timer.CSNum',csnum);
TDT.SetTargetVal('task-timer.CSToneFreq',cstonefreq);
TDT.SetTargetVal('task-timer.CSToneAmp',cstoneamp);

TDT.SetTargetVal('task-timer.ISI',metadata.stim.c.isi);
TDT.SetTargetVal('task-timer.UsDur',metadata.stim.c.usdur);
TDT.SetTargetVal('task-timer.PreStimTime',metadata.cam.time(1));

