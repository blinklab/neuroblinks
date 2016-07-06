function varargout=plotraster(bins,data,varargin)
% plotraster(rasterbins,rasterdata,{color, bar height,bar width})
% Plot raster in current axis using raster data returned by psth (first n-1
% rows of matrix). Pass last row of raster matrix returned by psth as 
% the argument for bins. Optional parameter COLOR should be specified as a
% single character, e.g. 'b', and BAR HEIGHT should be a number between 0
% and 1. There is no error checking so don't pass anything weird.
% Note that this function clears anything that already exists on the axis.

% No error checking here so make sure you only pass a single character for
% color
if nargin > 2
    col=['-' varargin{1}];
else
    col='-b';
end

if nargin > 3
    ht=varargin{2};
else
    ht=0.25;
end

if nargin > 4
    lwidth=varargin{3};
else
    lwidth=0.5;
end

if nargin > 5
    clearaxis=varargin{4};
else
    clearaxis=1;
end

if clearaxis
    cla % first make sure there's nothing on the axis
end
hold on
raster=cell(size(data,1),1);
for k=1:size(data,1)
    idx=find(data(k,:));
    raster{k}=bins(idx);
    h=plot([bins(idx);bins(idx)],[k*ones(1,length(idx))-ht;k*ones(1,length(idx))+ht],col);
    set(h,'LineWidth',lwidth);
end

if nargout > 0
    varargout{1}=raster;
end
