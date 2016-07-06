function TDTcheckmodetimer(obj,event)

TTX=getappdata(0,'ttx');
TDT=getappdata(0,'tdt');
metadata=getappdata(0,'metadata');
trials=getappdata(0,'trials');
ghandles=getappdata(0,'ghandles');
handles=guidata(ghandles.maingui);


switch TDTcheckmode
    case 0
        set(handles.togglebutton_TDTIdle,'Value',1);
        block='';
    case 1
        set(handles.togglebutton_TDTIdle,'Value',1);
        block='';
    case 2
        set(handles.togglebutton_TDTPreview,'Value',1);
        block=TTX.GetHotBlock();
    case 3
        set(handles.togglebutton_TDTRecord,'Value',1);
        block=TTX.GetHotBlock();
end

tank=TDT.GetTankName();

set(handles.edit_TDTBlockName,'String',block);
set(handles.edit_TDTTankName,'String',tank);

set(handles.text_status,'String',sprintf('Total trials: %d',metadata.cam.trialnum-1));

metadata.TDTblockname=block;
metadata.TDTtankname=tank;
setappdata(0,'metadata',metadata);