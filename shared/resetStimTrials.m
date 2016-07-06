function resetStimTrials()

trials=getappdata(0,'trials');

trials.stimnum=0;

setappdata(0,'trials',trials);
