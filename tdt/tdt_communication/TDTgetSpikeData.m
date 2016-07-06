function [ts,waves,sortcodes]=TDTgetSpikeData(TTX,spikechan,varargin)
% Return timestamps, spikewave data, and sortcodes for a spike channel, optionally between two time values specified as input arguments
MAXRET=2e6; % Should give us enough data for more than 5 hrs of a 100 Hz neuron recording.

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

nevents= TTX.ReadEventsV(MAXRET,spikechan,0,0,st,en,filt);
if nevents == MAXRET
    warning(sprintf('Number of returned events matches MAXRET. You are probably reading too few %s events.',eventchan))
end
% Get times of epoch events
ts=TTX.ParseEvInfoV(0,nevents,6);
waves=TTX.ParseEvV(0,nevents);
sortcodes=TTX.ParseEvInfoV(0,nevents,5);