% Set up environment and launch app based on which version you want to use
function neuroblinks(varargin)

    % Load local configuration for these rigs
    % Should be somewhere in path but not "neuroblinks" directory or subdirectory
    neuroblinks_config

    % Set up defaults in case user doesn't specify all options
    device = DEFAULTDEVICE;
    rig = DEFAULTRIG;

    % Input parsing
    if nargin > 0
        for i=1:nargin
            if any(strcmpi(varargin{i},ALLOWEDDEVICES))
                device = varargin{i};
            elseif ismember(varargin{i},1:length(ALLOWEDCAMS))
                rig = varargin{i};
            end
        end
    end

    % fprintf('Device: %s, Rig: %d\n', device, rig);
    % return

    % Matlab is inconsistent in how it numbers cameras so we need to explicitely search for the right one
    disp('Finding camera...')

    % Get list of configured cameras
    foundcams = imaqhwinfo('gige');
    founddeviceids = cell2mat(foundcams.DeviceIDs);

    if isempty(founddeviceids)
        error('No cameras found')
    end

    if ~isempty(ALLOWEDCAMS)
        % This code doesn't work on some versions of Matlab so it's not working for you, you can
        % set ALLOWEDCAMS to an empty cell array in "neuroblinks_config"
        % and it will default to camera 1 (but then you can only have one
        % gige camera connected to your computer.
        cam = 0;
        for i=1:length(founddeviceids)
            vidobj = videoinput('gige', founddeviceids(i), 'Mono8');
            src = getselectedsource(vidobj);
            if strcmp(src.DeviceID,ALLOWEDCAMS{rig})
                cam = i;
            end
            delete(vidobj)
        end
        
        if ~cam
            error(sprintf('The camera you specified (%d) could not be found',rig));
        end
        
    else
        cam = 1;
    end

    try
        switch lower(device)
            case 'tdt'
                % TDT version
                % Set up path for this session
                [basedir,mfile,ext]=fileparts(mfilename('fullpath'));
                oldpath=addpath(genpath(fullfile(basedir,'tdt')));
                addpath(genpath(fullfile(basedir,'shared')));

            case 'arduino'

                % % Arduino version
                % % Set up path for this session
                [basedir,mfile,ext]=fileparts(mfilename('fullpath'));
                oldpath=addpath(genpath(fullfile(basedir,'arduino')));
                addpath(genpath(fullfile(basedir,'shared')));

            otherwise
                error(sprintf('Device %s not found', device))

        end
    catch
        error('You did not specify a valid device');
    end

    % A different "launch" function should be called depending on whether we're using TDT or Arduino
    % and will be determined by what's in the path generated above
    Launch(rig,cam)
