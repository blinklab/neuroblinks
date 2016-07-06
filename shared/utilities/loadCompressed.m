function [data,varargout]=loadCompressed(vidfile,c)
	% [DATA,{METADATA}]=loadCompressed(VIDFILE,{COLOR})
	% Convert compressed AVI to Matlab native 4D uint8 video format and, if available, load corresponding metadata
	% Optionally set COLOR flag to zero or one to specify whether to return all color channels or just grayscale (can save memory).
	% Default is to return all color channels

	[p,n,e]=fileparts(vidfile);

	metafile=fullfile(p,[n '_meta.mat']);

	if exist(metafile)
		load(metafile)
		varargout{1}=metadata;
	end

	vidobj=VideoReader(vidfile);
	data=vidobj.read;

	if nargin>1 && ~c
		data=data(:,:,1,:);
	end