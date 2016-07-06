function nosavetrial()
% We set a callback function and trigger camera anyway so we can get instant replay

vidobj=getappdata(0,'vidobj');
pause(1e-3)
data=getdata(vidobj,vidobj.FramesPerTrigger*(vidobj.TriggerRepeat + 1));
% data=getdata(vidobj,vidobj.TriggerRepeat+1);

online_bhvana(data);
metadata=getappdata(0,'metadata');

% Keep data from last trial in memory even if we don't save it to disk
setappdata(0,'lastdata',data);
setappdata(0,'lastmetadata',metadata);

fprintf('Data from last trial saved to memory for review.\n')

% --- trial counter updated and saved in memory ---
if strcmpi(metadata.stim.type,'conditioning')
    metadata.eye.trialnum1=metadata.eye.trialnum1+1;
end
metadata.eye.trialnum2=metadata.eye.trialnum2+1;
setappdata(0,'metadata',metadata);

% --- online spike saving, executed by timer ---
% tm1 = timer('TimerFcn',@online_savespk_to_memory, 'startdelay', 4);
% start(tm1);



