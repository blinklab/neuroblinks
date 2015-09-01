function endOfTrial(obj,event)
% This function is run when the camera is done collecting frames, then it calls the appropriate 
% function depending on whether or not data should be saved

ghandles=getappdata(0,'ghandles'); 
vidobj = getappdata(0,'vidobj');
src = getappdata(0,'src');

handles = guidata(ghandles.maingui);

% Set camera to freerun mode so we can preview
if isprop(src,'FrameStartTriggerSource')
    src.FrameStartTriggerSource = 'Freerun';
else
    src.TriggerSource = 'Freerun';
end

if get(handles.checkbox_record,'Value') == 1  
    incrementStimTrial()
    savetrial();
else
    nosavetrial();  
end


function incrementStimTrial()
trials=getappdata(0,'trials');
trials.stimnum=trials.stimnum+1;
setappdata(0,'trials',trials);