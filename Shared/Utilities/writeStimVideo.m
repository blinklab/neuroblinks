function writeStimVideo(data,metadata,fname,varargin)
    % WRITESTIMVIDEO(DATA,METADATA,FNAME,{FRAMERATE})
    % Write stim video to avi file FNAME including stim marker boxes. Optionally specify framerate, otherwise the video will be written using
    % the same frame rate as it was captured at.

if isempty(data)
    % Die gracefully
    warning('There is no data to write.')
    return
end

if ~isempty(varargin)
    fr=varargin{1};
else
    fr=metadata.cam.fps;
end


[m,n,p,t]=size(data);

% Make stim timing arrays

box_size=round(m/20);
box_x=round(m*420/480)+[1:box_size];
box_y=round(n*580/640)+[1:box_size];

switch lower(metadata.stim.type)
    case 'none'
        % do nothing for now
        stim=zeros(m,n,3,t,'uint8');
    case 'puff'
        stfrm=round(metadata.cam.time(1)./1000.*metadata.cam.fps);
        enfrm=round(metadata.stim.totaltime./1000.*metadata.cam.fps);
        stim=zeros(m,n,3,t,'uint8');
        stim(box_x,box_y,2,stfrm:stfrm+enfrm)=255;
    case 'electrical'       
        stfrm=round((metadata.cam.time(1)+metadata.stim.e.delay)./1000.*metadata.cam.fps);
        enfrm=round(metadata.stim.e.traindur./1000.*metadata.cam.fps);
        stim=zeros(m,n,3,t,'uint8');
        stim(box_x,box_y,1,stfrm:stfrm+enfrm)=255;       
    case {'conditioning','electrocondition'}
        stfrmc=round(metadata.cam.time(1)./1000.*metadata.cam.fps); % for CS
        enfrmc=round(metadata.stim.c.csdur./1000.*metadata.cam.fps);
        stfrmu=round((metadata.cam.time(1)+metadata.stim.c.isi)./1000.*metadata.cam.fps);
        enfrmu=round(metadata.stim.c.usdur/1000.*metadata.cam.fps); % for US
        stim=zeros(m,n,3,t,'uint8');
        stim(box_x,box_y,3,stfrmc:stfrmc+enfrmc)=255;
        stim(box_x,box_y,2,stfrmu:stfrmu+enfrmu)=255;
        stim(box_x,box_y,3,stfrmu:stfrmu+enfrmu)=0;
    case 'optical'      
        stfrm=round((metadata.cam.time(1)+metadata.stim.l.delay)./1000.*metadata.cam.fps);
        enfrm=round(metadata.stim.l.traindur./1000.*metadata.cam.fps);
        stim=zeros(m,n,3,t,'uint8');
        stim(box_x,box_y,3,stfrm:stfrm+enfrm)=255;
    case 'optoelectric'      
        stfrme=round((metadata.cam.time(1)+metadata.stim.e.delay)./1000.*metadata.cam.fps);
        enfrme=round(metadata.stim.e.traindur./1000.*metadata.cam.fps);      
        stfrml=round((metadata.cam.time(1)+metadata.stim.l.delay)./1000.*metadata.cam.fps);
        enfrml=round(metadata.stim.e.traindur./1000.*metadata.cam.fps);
        stim=zeros(m,n,3,t,'uint8');
        stim(box_x,box_y,1,stfrme:stfrme+enfrme)=255;
        stim(box_x,box_y,3,stfrml:stfrml+enfrml)=255;
end


for i=1:t 
    F(i).cdata=repmat(data(:,:,:,i),[1 1 3 1])+stim(:,:,:,i); 
    F(i).colormap=[]; 
end

% writeObj=VideoWriter(fname); % default is AVI
writeObj=VideoWriter(fname,'MPEG-4');
set(writeObj,'FrameRate',fr);
open(writeObj);

writeVideo(writeObj,F);
close(writeObj);

% hm=figure;
% set(hm,'Name','Instant Replay - close window when done','Position',[150 150 n m]);
% movie(hm,F,1,20);