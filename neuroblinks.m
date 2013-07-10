% Set up environment and launch app based on which version you want to use

% TDT version
% Set up path for this session
[basedir,mfile,ext]=fileparts(mfilename('fullpath'));
oldpath=addpath(genpath(fullfile(basedir,'TDT')));
addpath(genpath(fullfile(basedir,'Shared')));

Launch


% % Arduino version
% % Set up path for this session
% [basedir,mfile,ext]=fileparts(mfilename('fullpath'));
% oldpath=addpath(genpath(fullfile(basedir,'Arduino')));
% addpath(genpath(fullfile(basedir,'Shared')));

% LaunchA