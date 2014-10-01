% Set up environment and launch app based on which version you want to use
function neuroblinks(varargin)

    DEFAULTDEVICE = 'arduino';
    DEFAULTRIG = 1;

    % Get list of configured cameras
    cams = imaqhwinfo('gige');

    ALLOWEDDEVICES = {'arduino','tdt'};
    ALLOWEDRIGS = cell2mat(cams.DeviceIDs); 

    % Set up devaults in case user doesn't specify all options
    device = DEFAULTDEVICE;
    rig = DEFAULTRIG;

    % Input parsing
    if nargin > 0
        for i=1:nargin
            if any(strcmpi(varargin{i},ALLOWEDDEVICES))
                device = varargin{i};
            elseif ismember(varargin{i},ALLOWEDRIGS)
                rig = varargin{i}; 
            end
        end
    end

    % fprintf('Device: %s, Rig: %d\n', device, rig);
    % return
            

    try 
        switch lower(device)
            case 'tdt'
                % TDT version
                % Set up path for this session
                [basedir,mfile,ext]=fileparts(mfilename('fullpath'));
                oldpath=addpath(genpath(fullfile(basedir,'TDT')));
                addpath(genpath(fullfile(basedir,'Shared')));

            case 'arduino'

                % % Arduino version
                % % Set up path for this session
                [basedir,mfile,ext]=fileparts(mfilename('fullpath'));
                oldpath=addpath(genpath(fullfile(basedir,'Arduino')));
                addpath(genpath(fullfile(basedir,'Shared')));

            otherwise
                error(sprintf('Device %s not found', device))

        end
    catch
        error('You did not specify a valid device');
    end
   
    % A different "launch" function should be called depending on whether we're using TDT or Arduino
    % and will be determined by what's in the path generated above
    Launch(rig)