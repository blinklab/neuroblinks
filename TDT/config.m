%%%% This is configuration file for each user. %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% basedir='D:\shane\matlab\neuroblinks v 1.1';
basedir='D:\shane\matlab\neuroblinks v 1.3';
tank='optoelectrophys'; % The tank should be registered using TankMon

% ------ Letter for mouse -----
path1=pwd;   ind1=find(path1=='\');   metadata.mouse=path1(ind1(end-1)+1:ind1(end)-1);
% metadata.mouse='Sxxx';  % for Shane
% metadata.mouse='T';     % for shogo


%%% Set up user environment %%%

% -- specify the location of bottomleft corner of MainWindow & AnalysisWindow  --
ghandles.pos_mainwin=[8,450];     ghandles.size_mainwin=[840 720]; 
ghandles.pos_anawin=[470 50];     ghandles.size_anawin=[1030 840]; 
ghandles.pos_oneanawin=[8,48];    ghandles.size_oneanawin=[840,364];   
ghandles.pos_lfpwin=[470 50];    ghandles.size_lfpwin=[600 380];

% ------ Initial value of the conditioning table ----

% Search for per-mouse config file and load it if it exists, otherwise default to the paramtable below

mousedir=regexp(pwd,['[CD]:\\.*\\', metadata.mouse],'once','match');
condfile=fullfile(mousedir,'condparams.csv');

if exist(condfile)
	paramtable.data=csvread(condfile);
else
	paramtable.data=...
    [9,  500,1,200, 20,1,1;...
     1,  500,1,200, 0, 1,0;...
     9,  500,2,400, 20,2,1;...
     1,  500,2,400, 0, 2,0;...
     9,  500,1,200, 20,3,1;...
     1,  500,1,200, 0, 3,0;...
     9,  500,2,400, 20,4,1;...
     1,  500,2,400, 0, 4,0;...
     zeros(2,7)];
 end
 
% paramtable.data=zeros(10,7);
%  paramtable.data=...
%     [50, 500,1,200, 20, 1,1;...
%      50, 500,2,400, 20, 1,0;...
%      zeros(8,7)];

winopen(sprintf('%s\\TDT\\private\\TDTFiles\\simultaneous opto- microstim and recording.wsp',basedir));
winopen('C:\Program Files (x86)\DinoCapture 2.0\DinoCapture.exe');
winopen('C:\Program Files\Sublime Text 2\sublime_text.exe');


pause(1);