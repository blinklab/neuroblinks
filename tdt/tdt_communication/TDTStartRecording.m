function ok=TDTStartRecording()

TDT=getappdata(0,'tdt');

if TDT.GetSysMode()< 3
    ok=TDT.SetSysMode(3);
    if ok
        while TDT.GetSysMode() ~= 3
            pause(0.01); % Wait for TDT
        end
        pause(0.1); % Wait for TDT
    end
    ResetCamTrials()
else
    ok=0;
end

% start go, 
TDT.SetTargetVal('task_timer.Start',1);
pause(0.01);
TDT.SetTargetVal('task_timer.Start',0);
