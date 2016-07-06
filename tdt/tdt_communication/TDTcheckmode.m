function mode=TDTcheckmode()

TDT=getappdata(0,'tdt');
% TTX=getappdata(0,'ttx');
% metadata=getappdata(0,'metadata');

mode=TDT.GetSysMode();