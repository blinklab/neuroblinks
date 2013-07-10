function online_bhvana(data)
% Eyelid trace is saved to memory (trials and metadata) even in no-save trial.

metadata=getappdata(0,'metadata');
trials=getappdata(0,'trials');
if isfield(trials,'eye'), if length(trials.eye)>metadata.eye.trialnum2+2, trials.eye=[]; end, end

% ------ eyelid trace, which will be saved to 'trials' ---- 
[trace,time]=vid2eyetrace(data,metadata,metadata.cam.thresh);
trace=(trace-metadata.cam.calib_offset)/metadata.cam.calib_scale;

trials.eye(metadata.eye.trialnum2).time=time*1e3;
trials.eye(metadata.eye.trialnum2).trace=trace;
trials.eye(metadata.eye.trialnum2).stimtype=lower(metadata.stim.type);

switch lower(metadata.stim.type)
    case 'none'
        trials.eye(metadata.eye.trialnum2).stimtime.st{1}=Inf;
        trials.eye(metadata.eye.trialnum2).stimtime.en{1}=0;
        trials.eye(metadata.eye.trialnum2).stimtime.cchan(1)=0;
    case 'puff'
        trials.eye(metadata.eye.trialnum2).stimtime.st{1}=0;
        trials.eye(metadata.eye.trialnum2).stimtime.en{1}=metadata.stim.totaltime;
        trials.eye(metadata.eye.trialnum2).stimtime.cchan(1)=2;
    case 'electrical'       
        trials.eye(metadata.eye.trialnum2).stimtime.st{1}=metadata.stim.e.delay;
        trials.eye(metadata.eye.trialnum2).stimtime.en{1}=metadata.stim.e.traindur;
        trials.eye(metadata.eye.trialnum2).stimtime.cchan(1)=1;
    case 'conditioning'
        trials.eye(metadata.eye.trialnum2).stimtime.st{1}=0; % for CS
        trials.eye(metadata.eye.trialnum2).stimtime.en{1}=metadata.stim.c.csdur;
        trials.eye(metadata.eye.trialnum2).stimtime.cchan(1)=3;
        trials.eye(metadata.eye.trialnum2).stimtime.st{2}=metadata.stim.c.isi;
        trials.eye(metadata.eye.trialnum2).stimtime.en{2}=metadata.stim.c.usdur; % for US
        trials.eye(metadata.eye.trialnum2).stimtime.cchan(2)=2;
    case 'optical'      
        trials.eye(metadata.eye.trialnum2).stimtime.st{1}=metadata.stim.l.delay;
        trials.eye(metadata.eye.trialnum2).stimtime.en{1}=metadata.stim.l.traindur;
        trials.eye(metadata.eye.trialnum2).stimtime.cchan(1)=3;
    case 'optoelectric'     
        error('This version of instantReplay does not support multiple stim modalities for because of memory considerations.')
end

% --- this may be useful for offline analysis ----
metadata.eye.ts0=time(1)*1e3;
metadata.eye.ts_interval=mode(diff(time*1e3));
metadata.eye.trace=trace;


% --- save results to memory ----
setappdata(0,'trials',trials);
setappdata(0,'metadata',metadata);




