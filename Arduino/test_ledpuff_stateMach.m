arduino=serial('COM4','BaudRate',9600);
fopen(arduino)

%% send stuff to Arduino to establish trail parameters
datatoarduino = zeros(1,14);
datatoarduino(3)= 200; %cam pre time (time cam comes on before CS)
datatoarduino(4) = 7; %CS num, 7 is bright green LED. Have arduino set up to turn on a red light on 9/2/2016
datatoarduino(5) = 500; %CS dur
datatoarduino(6) = 0; %US dur, long for testing purposes
datatoarduino(7) = 200; %ISI
datatoarduino(9) = 800; %cam post time (time cam stays on after CS on)
datatoarduino(10) = 3; %US num, 3 is puff. Have arduino set up to turn on a yellow light on 9/2/2016
datatoarduino(11) = 100;
datatoarduino(12) = 100;
datatoarduino(13) = 20;
datatoarduino(14) = 10;
datatoarduino(15) = 100; % laser frequency (Hz)
datatoarduino(16) = 5; % laser on duration (ms)
% 11 is laser delay, 12 is laser duration, 13 is laser amplitude, 14 is CS
% intensity (hardware only set up to do this for tones right now, not sure
% how to incorporate that ito the state machine just yet.

for i=3:length(datatoarduino),
    fwrite(arduino,i,'int8');                  % header
    fwrite(arduino,datatoarduino(i),'int16');  % data
    if mod(i,4)==0,
        pause(0.010);
    end
end

%% trigger arduino to run a trial
fwrite(arduino, 1, 'int8');

fclose(arduino)


% 
% 
% function sendto_arduino()
% metadata=getappdata(0,'metadata');
% datatoarduino=zeros(1,10);
% 
% datatoarduino(3)=metadata.cam.time(1);
% datatoarduino(9)=sum(metadata.cam.time(2:3));
% if strcmpi(metadata.stim.type, 'puff')
%     datatoarduino(6)=metadata.stim.p.puffdur;
%     datatoarduino(10)=3;    % This is the puff channel
% elseif  strcmpi(metadata.stim.type, 'conditioning')
%     datatoarduino(4)=metadata.stim.c.csnum;
%     datatoarduino(5)=metadata.stim.c.csdur;
%     datatoarduino(6)=metadata.stim.c.usdur;
%     datatoarduino(7)=metadata.stim.c.isi;
%     if ismember(metadata.stim.c.csnum,[5 6]),
%         datatoarduino(8)=metadata.stim.c.cstone(metadata.stim.c.csnum-4);
%     end
%     if ismember(metadata.stim.c.usnum,[5 6]),
%         datatoarduino(8)=metadata.stim.c.cstone(metadata.stim.c.usnum-4);
%     end
%     datatoarduino(10)=metadata.stim.c.usnum;
%     datatoarduino(11)=metadata.stim.l.delay;
%     datatoarduino(12)=metadata.stim.l.dur;
%     datatoarduino(13)=metadata.stim.l.amp;
%     datatoarduino(14)=metadata.stim.c.csint;
% end
% 
% % ---- send data to arduino ----
% arduino=getappdata(0,'arduino');
% for i=3:length(datatoarduino),
%     fwrite(arduino,i,'int8');                  % header
%     fwrite(arduino,datatoarduino(i),'int16');  % data
%     if mod(i,4)==0,
%         pause(0.010);
%     end
% end