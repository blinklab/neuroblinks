function [y,t]=vid2eyetrace(data,metadata,varargin)
% [y,t]=vid2eyetrace(data,metadata,{thresh,winsize,calib}) - Convert video frames storeed in DATA to
% eyelid trace based on mask and threshold in METADATA.
%
% Optionally supply THRESH as third argument to override value in metadata and WINDOW SIZE 
% (in pixels) for median filter of frame before converting to binary image. If you want the data
% to be returned normalized by full eyelid closure, supply CALIB struct with fields of
% SCALE and OFFSET as fifth argument.

sr=metadata.cam.fps;
sint=1./sr;
thresh=metadata.cam.thresh;
st=-metadata.cam.time(1)/1e3;

if nargin > 2 && ~isempty(varargin{1})
    thresh=varargin{1};
end

if nargin > 3 && ~isempty(varargin{2})
	w=varargin{2};
else
	w=1;
end

if nargin > 4 && ~isempty(varargin{3})
	calib=varargin{3};
else
	calib.scale=1;
	calib.offset=0;
end

[a,b,c,d]=size(data);
t=st:sint:d*sint+st-sint;
y=zeros(size(t));

if w==1,  % ------- faster algorism --------
    binimage = (data>=thresh*256);
    binimage = (binimage & repmat(metadata.cam.mask,[1 1 c d]));
    tr=shiftdim(sum(sum(binimage,2),1),2); 
    y=(tr-calib.offset)./calib.scale;
    
else
    for i=1:d
        wholeframe=data(:,:,1,i);
        binimage=im2bw(medfilt2(wholeframe,[w w]),thresh);
        eyeimage=binimage.*metadata.cam.mask;
        tr=sum(sum(eyeimage)); 
        % tr=sqrt(sum(sum(eyeimage))); % Use SQRT b/c area is proportional to square of eyelid diameter.
        y(i)=(tr-calib.offset)./calib.scale;
    end
end
