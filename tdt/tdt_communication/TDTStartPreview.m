function ok=TDTStartPreview()

TDT=getappdata(0,'tdt');

if TDT.GetSysMode() == 3
    button=questdlg('You are currently recording. Are you sure you want to enter preview mode?','Yes','No');
    if ~strcmpi(button,'Yes')
        ok=0;
        return
    end
end

ok=TDT.SetSysMode(2);
if ok
    while TDT.GetSysMode() ~= 2
        pause(0.01); % Wait for TDT
    end
    pause(0.1); % Wait for TDT
end
ResetCamTrials()