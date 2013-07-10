function [ts,values]=TDTgetEventData(TTX,eventchan,varargin)
% Return timestamps and values for an event channel, optionally between two time values specified as input arguments
MAXRET=1e6; % Should give us more than enough room

if length(varargin) > 0
	st=varargin{1};
else
	st=0;
end

if length(varargin) > 1
	en=varargin{2};
else
	en=0;
end

if length(varargin) > 2
	filt=varargin{3};
else
	filt='ALL';
end

nevents= TTX.ReadEventsV(MAXRET,eventchan,0,0,st,en,filt);
if nevents == MAXRET
    warning(sprintf('Number of returned events matches MAXRET. You are probably reading too few %s events.',eventchan))
end
% Get times of epoch events
ts=TTX.ParseEvInfoV(0,nevents,6);
values=TTX.ParseEvInfoV(0,nevents,7);