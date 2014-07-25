function instantReplay(data,metadata)
% Note: This version only currently works with single stim modalities

if isempty(data)
    % Die gracefully
    warning('There is no data to replay.')
    return
end

[m,n,p,t]=size(data);


% Make stim timing arrays

switch lower(metadata.stim.type)
    case 'none'
        % do nothing for now
%         stim=zeros(m,n,3,t,'uint8');
    case 'puff'
        stfrm{1}=round(metadata.cam.time(1)./1000.*metadata.cam.fps);
        enfrm{1}=round(metadata.stim.totaltime./1000.*metadata.cam.fps);
%         stim=zeros(m,n,3,t,'uint8');
%         stim=zeros(m,n,3,enfrm-stfrm,'uint8');
%         stim(400:449,450:499,2,stfrm:stfrm+enfrm)=255;
%         stim(400:449,450:499,2,:)=255;
        cchan(1)=2;
    case 'electrical'       
        stfrm{1}=round((metadata.cam.time(1)+metadata.stim.e.delay)./1000.*metadata.cam.fps);
        enfrm{1}=round(metadata.stim.e.traindur./1000.*metadata.cam.fps);
        cchan(1)=1;
%         stim=zeros(m,n,3,t,'uint8');
%         stim=zeros(m,n,3,enfrm-stfrm,'uint8');
%         stim(400:449,500:549,1,stfrm:stfrm+enfrm)=255;
%         stim(400:449,500:549,1,:)=255;

    case {'conditioning','electrocondition'}
        stfrm{1}=round(metadata.cam.time(1)./1000.*metadata.cam.fps); % for CS
        % enfrm{1}=round(metadata.stim.c.csdur./1000.*metadata.cam.fps);
        enfrm{1}=round((metadata.stim.c.isi+metadata.stim.c.usdur)./1000.*metadata.cam.fps);    % Had to change this bc was getting error if CS was longer than recorded trial time
        cchan(1)=3;
        stfrm{2}=round((metadata.cam.time(1)+metadata.stim.c.isi)./1000.*metadata.cam.fps);
        enfrm{2}=round(metadata.stim.c.usdur/1000.*metadata.cam.fps); % for US
        cchan(2)=2;

    case 'optical'      
        stfrm{1}=round((metadata.cam.time(1)+metadata.stim.l.delay)./1000.*metadata.cam.fps);
        enfrm{1}=round(metadata.stim.l.traindur./1000.*metadata.cam.fps);
        cchan(1)=3;
%         stim=zeros(m,n,3,t,'uint8');
%         stim=zeros(m,n,3,enfrm-stfrm,'uint8');
%         stim(400:449,550:599,3,stfrm:stfrm+enfrm)=255;
%         stim(400:449,550:599,3,:)=255;
    case 'optoelectric'     
        error('This version of instantReplay does not support multiple stim modalities for because of memory considerations.')
        stfrme=round((metadata.cam.time(1)+metadata.stim.e.delay)./1000.*metadata.cam.fps);
        enfrme=round(metadata.stim.e.traindur./1000.*metadata.cam.fps);      
        stfrml=round((metadata.cam.time(1)+metadata.stim.l.delay)./1000.*metadata.cam.fps);
        enfrml=round(metadata.stim.e.traindur./1000.*metadata.cam.fps);
        stim=zeros(m,n,3,t,'uint8');
%         stim=zeros(m,n,3,max(enfrme,enfrml)-min(stfrme,stfrml),'uint8');
        stim(400:449,500:549,1,stfrme:stfrme+enfrme)=255;
        stim(400:449,550:599,3,stfrml:stfrml+enfrml)=255;
%         stim(400:449,500:549,1,stfrme:stfrme+enfrme)=255;
%         stim(400:449,550:599,3,stfrml:stfrml+enfrml)=255;
end



for i=1:t 
%     F(i).cdata=repmat(data(:,:,:,i),[1 1 3 1])+stim(:,:,:,i); 
    F(i).cdata=repmat(data(:,:,:,i),[1 1 3 1]); 
    F(i).colormap=[]; 
end

if exist('stfrm','var')
    % Do another loop; here we're trading execution time for memory
    box_size=round(m/20);
    for j=1:length(stfrm),
        for i=stfrm{j}:stfrm{j}+enfrm{j}
            F(i).cdata(round(m*400/480)+[1:box_size],round(n*550/640)+[1:box_size],setdiff([1,2,3],cchan(j)))=0;
            F(i).cdata(round(m*400/480)+[1:box_size],round(n*550/640)+[1:box_size],cchan(j))=255;
        end
    end
end


hm=figure;
set(hm,'Name','Instant Replay - close window when done','Position',[150 150 n m]);
movie(hm,F,1,20);

