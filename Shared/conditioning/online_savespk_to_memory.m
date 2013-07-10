function online_savespk_to_memory(obj,event)
%  callback function by timer obj
if ~isappdata(0,'ttx'), return, end

% ---- spike data --------
metadata=getappdata(0,'metadata');
trials=getappdata(0,'trials');

TTX=getappdata(0,'ttx');

if isfield(trials,'spk'), length_trials_spk=length(trials.spk);
else length_trials_spk=0;  end

if length_trials_spk>metadata.eye.trialnum2+3, trials.spk=[]; end

ok=TTX.SelectBlock(metadata.TDTblockname);
if ~ok
    error('Could not select current block.')
end

% ---- get data from TDT ----    
dt=1;
Event='Spks';
Channel=1;
tlim=[100 600];
[trln_ts,trln_values]=TDTgetEventData(TTX,'TrlN',0,0,'ALL');
    
for tnum=length_trials_spk+1:length(trials.eye);
    % --- init ----
    trials.spk(tnum).y=NaN;
    trials.spk(tnum).ylim=[NaN NaN];
    trials.spk(tnum).time=NaN;
    trials.spk(tnum).ts_interval=NaN;
%     trials.params(tnum).depth=max(metadata.stim.e.depth,metadata.stim.l.depth);
%     trials.params(tnum).psde=metadata.stim.p.side_value;
    
    ind1=find(trln_values==tnum);
    if ~isempty(ind1)
        StartTime=trln_ts(ind1(end))+tlim(1)/1000; EndTime=trln_ts(ind1(end))+(tlim(2)+100)/1000;
        [y t ts_interval] = getdataATR (TTX, Event, Channel, StartTime, EndTime);
        tind_1=find(t<(trln_ts(ind1(end))+tlim(2)/1000));
        tind_2=1:dt:tind_1(end);
        y=y(tind_2)*1e6;
        ylim=[min(y) max(y)];
        % time [ms], y [uV]
        if ~sum(abs(ylim))==0
            trials.spk(tnum).y=y;
            trials.spk(tnum).ylim=ylim;
            trials.spk(tnum).time=(t(tind_2)-trln_ts(ind1(end)))*1000-metadata.cam.time(1);
            trials.spk(tnum).ts_interval=ts_interval*1000;
        end
    end
end
% trials.tnum=trials.tnum+1;

% --- save results to memory ----
setappdata(0,'trials',trials);



function [y t ts_interval] = getdataATR (TTX, Event, Channel, StartTime, EndTime)
%Get the data and the timestamps; data will have the data organized as a
%series of colums each representing a block, timestamps will be a row where
%each value represents the time stamp of the first value in each block
%Also, since ReadEventsV tends to round up, add a tenth of a second to beginning 
%of the interval if the start isn't zero

TR = TTX.GetValidTimeRangesV();
if EndTime > TR(2), EndTime = TR(2); end
N = TTX.ReadEventsV(1000000, Event, Channel, 0, StartTime - 0.2, EndTime, 'ALL');
if N == 0
    y = NaN; t = NaN; ts_interval = NaN;
    return
end
y = TTX.ParseEvV(0,N);
timestamps = TTX.ParseEvInfoV(0,N,6);

%Organize the data into a meaningful waveform, where each value has a timestamp
%First construct an array with a time for every sample
ts_interval = 1/TTX.ParseEvInfoV(0,1,9);

t = timestamps(1) + (0:numel(y)-1) .* ts_interval;

%next organize all the data into one row containing all samples
y = reshape(y, 1, numel(y));

%Now we'll trim the excess samples that lie outside the specified range
k = 1;
if StartTime ~= 0
    while (t(k) < StartTime)
        k = k+1;
    end
end

j = length(t);
if EndTime ~= 0
    while (t(j) > EndTime)
        j = j-1;
    end
end

y = y(k:j);
t = t(k:j);



