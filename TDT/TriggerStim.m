function TriggerStim(hObject, handles)
% this components come from pushbutton_stim_Callback of MainWindow.m

% Get stim params and pass to TDT
refreshParams(hObject);
sendParamsToTDT(hObject)

TDT=getappdata(0,'tdt');
vidobj=getappdata(0,'vidobj');
metadata=getappdata(0,'metadata');

metadata.TDTtankname=TDT.GetTankName();
stimmode=metadata.stim.type;
pre=metadata.cam.time(1);

if TDT.GetSysMode == 0             
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'),
    disp('%%%% TDT is Idle mode. Trigger was canceled. %%%%')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    return
end

% Set up camera to record
frames_per_trial=ceil(metadata.cam.fps.*(sum(metadata.cam.time))./1000);
vidobj.TriggerRepeat = frames_per_trial-1;

TDT.SetTargetVal('task_timer.TrialNum',metadata.eye.trialnum2);
        
if get(handles.checkbox_record,'Value') == 1   
    % Send TDT current trial number to make mark
    TDT.SetTargetVal('task_timer.CamTrial',metadata.cam.trialnum); % this will be saved in TDT storage.
    
    if get(handles.toggle_continuous,'Value') == 1,  % when continuous mode
        if TDT.GetSysMode < 3
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'),
            disp('%%%% TDT is not recording mode. Frame times will not be saved. %%%%'),
            disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        end
    else
        % Make sure user knows if TDT isn't recording b/c frame times won't be recorded
        if TDT.GetSysMode < 3
            button=questdlg('You are not recording a TDT block so camera frame times will not be saved. Do you want to record a TDT block?',...
                'No active TDT block','Continue anyway','Cancel','Continue anyway');       
            switch button
                case 'Continue anyway'
                    % Do nothing and it will continue by itself
                case 'Cancel'
                    return,    % Exit stim callback
            end
        end
    end
    vidobj.StopFcn=@endOfTrial;
    incrementStimTrial()
else
    TDT.SetTargetVal('task_timer.CamTrial',0);   % Send TDT trial number of zero 
    vidobj.StopFcn=@endOfTrial;  
end

% % Set camera to Line mode so we can trigger with TTL
% if isprop(src,'FrameStartTriggerSource')
%     src.FrameStartTriggerSource = 'Line1';
% else
%     src.TriggerSource = 'Line1';
% end

flushdata(vidobj); % Remove any data from buffer before triggering
start(vidobj)

metadata.ts(2)=etime(clock,datevec(metadata.ts(1)));
TDT.SetTargetVal('task_timer.MatTime',metadata.ts(2));

%%%%%%%% trigger first to start camera (and second to start trial, within TDT) %%%%%%%%
TDT.SetTargetVal('task_timer.StartCam',1);
pause(pre./1e3);
TDT.SetTargetVal('task_timer.StartCam',0);


% if strcmpi(stimmode,'none')
%     % If doing no stim or puff
%     % Emulate button press in OpenEx
%     TDT.SetTargetVal('task_timer.StartCam',1);
%     pause(pre./1e3);
%     TDT.SetTargetVal('task_timer.StartCam',0);
% end

% if strcmpi(stimmode,'puff')
%     TDT.SetTargetVal('task_timer.PuffManual',1);
% %     if get(handles.checkbox_RX6,'Value'),
% %         TDT.SetTargetVal('Stim.PuffManual',1);
% %         TDT.SetTargetVal('task_timer.StartCam',1);
% %     end
%     pause(0.01);
%     TDT.SetTargetVal('task_timer.PuffManual',0);
% %     if get(handles.checkbox_RX6,'Value'),
% %         TDT.SetTargetVal('Stim.PuffManual',0);
% %         TDT.SetTargetVal('task_timer.StartCam',0);
% %     end
% end

% if strcmpi(stimmode,'conditioning')
%     TDT.SetTargetVal('task_timer.TrigCond',1);
% %     if get(handles.checkbox_RX6,'Value'),
% %         TDT.SetTargetVal('Stim.TrigCond',1);
% %         TDT.SetTargetVal('task_timer.StartCam',1);
% %     end
%     pause(0.01);
%     TDT.SetTargetVal('task_timer.TrigCond',0);
% %     if get(handles.checkbox_RX6,'Value'),
% %         TDT.SetTargetVal('Stim.TrigCond',0);
% %         TDT.SetTargetVal('task_timer.StartCam',0);
% %     end
% end

% if strcmpi(stimmode,'optocondition')
%     TDT.SetTargetVal('task_timer.StartPulse',1);
%     TDT.SetTargetVal('task_timer.PuffManual',1);
% %     if get(handles.checkbox_puff,'Value')==1
% %         if get(handles.checkbox_RX6,'Value'),
% %             TDT.SetTargetVal('Stim.PuffManual',1);
% %         end
% %     end
%     pause(0.01);
% %     if get(handles.checkbox_RX6,'Value'),
% %         TDT.SetTargetVal('Stim.PuffManual',0);   
% %     end
%     TDT.SetTargetVal('task_timer.PuffManual',0);  
%     TDT.SetTargetVal('task_timer.StartPulse',0);
% end

% if strcmpi(stimmode,'electrical') || strcmpi(stimmode,'optical') ||strcmpi(stimmode,'optoelectric')
%     % Emulate button press in OpenEx
%     TDT.SetTargetVal('task_timer.StartPulse',1);
%     pause(0.01);
%     TDT.SetTargetVal('task_timer.StartPulse',0);
% end

% --- required to initialize the eye monitor and count trial # ---- 
TDT.SetTargetVal('task_timer.InitTrial',1);
pause(0.01);
TDT.SetTargetVal('task_timer.InitTrial',0);

setappdata(0,'metadata',metadata);

% % --- puff side swhitching ----
% if strcmpi(stimmode,'puff')
%     if get(handles.checkbox_puffside,'Value')
%         if get(handles.radiobutton_ipsi,'Value')
%             set(handles.radiobutton_contra,'Value',1)
%         else
%             set(handles.radiobutton_ipsi,'Value',1)
%         end
%     end
% end

% ---- display current trial data in conditioning ----
if strcmpi(metadata.stim.type,'conditioning')
    
    trialvars=readTrialTable(metadata.eye.trialnum1+1);
    csdur=trialvars(1);
    csnum=trialvars(2);
    isi=trialvars(3);
    usdur=trialvars(4);
    cstone=str2num(get(handles.edit_tone,'String'));
    if length(cstone)<2, cstone(2)=0; end
    
    str2=[];
    if ismember(csnum,[5 6]), 
        str2=[' (' num2str(cstone(csnum-4)) ' Hz)'];
    end
        
    str1=sprintf('Next:  No %d,  CS ch %d%s,  ISI %d,  US %d',metadata.eye.trialnum1+1, csnum, str2, isi, usdur);
    set(handles.text_disp_cond,'String',str1)
end




function incrementStimTrial()
trials=getappdata(0,'trials');
trials.stimnum=trials.stimnum+1;
setappdata(0,'trials',trials);

