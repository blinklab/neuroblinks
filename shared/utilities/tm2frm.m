function frames=tm2frm(time,varargin)
% Convert time in seconds to number of frames. 
% By default assumes 200 FPS, but can optionally supply frame rate as second argument

if nargin > 1
	FPS=varargin{1};
else
	FPS=200;
end

frames=round(time*FPS);