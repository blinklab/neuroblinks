function ok=TDTStartIdle()

TDT=getappdata(0,'tdt');

if TDT.GetSysMode() == 3
    button=questdlg('You are currently recording. Are you sure you want to enter idle mode?','Yes','No');
    if ~strcmpi(button,'Yes')
        ok=0;
        return
    end        
end

ok=TDT.SetSysMode(0); 
ResetCamTrials()