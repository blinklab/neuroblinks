function CalbEye(obj,event)
%  callback function by video(timer) obj
disp('Delivering puff and saving cal data.')

vidobj=getappdata(0,'vidobj');
metadata=getappdata(0,'metadata');

data=getdata(vidobj,vidobj.FramesPerTrigger*(vidobj.TriggerRepeat + 1));

% --- save data to root app ---
% Keep data from last trial in memory even if we don't save it to disk
setappdata(0,'lastdata',data);
setappdata(0,'lastmetadata',metadata);
setappdata(0,'calb_data',data);
setappdata(0,'calb_metadata',metadata);
fprintf('Data from last trial saved to memory for review.\n')

% metadata.stim.type='None';

% --- setting threshold ---
ghandles=getappdata(0,'ghandles');
ghandles.threshgui2=ThreshWindowWithPuff;
setappdata(0,'ghandles',ghandles);

% Have to do the following 2 lines because we can't call drawhist and
% drawbinary directly from the ThreshWindow opening function since the
% ghandles struct doesn't exist yet. 
threshguihandles=guidata(ghandles.threshgui2);
ThreshWindowWithPuff('drawbinary',threshguihandles);


