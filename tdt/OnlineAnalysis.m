% Pseudocode

% Make sure connected to TDT block



% Set up interface, including listboxes/popups, axes, edit fields, buttons, etc
% Popups include:
%	-Unit numbers in file for epoch indexing
% 	-Trigger event names
% 	-Snip names/numbers (multiselection?)
% 	-Trial range (two popups updated on each refresh)

% Axes include:
% 	-Raster
% 	-PSTH
% 	-Spike shapes (overdraw last 100) and corresponding ISIs for Snips
% 	-Behavior (position and velocity)
%	
% Text displays of useful information such as number of trials for currently selected filter set,
% neuron firing statistics such as median FR, median CV2, etc.
% Should have an edit box that allows user to customize what is displayed by entering the name of a function to execute,
% such as 'cv2', where the argument is assumed to be spike times. Also, peak to trough time of spike waveform.

% Put the different types of axes in panels and then programmatically create subplots as needed, e.g.
% a1=subplot(2,1,1,'Parent',handles.uipanel1); 
% plot(a1,rand(1,10),'r'); 

% Edit fields include:
% 	-Min and max axis values for x and y axes (4 total)
% 	-Time range to analyze
% 	-Bin size and pre and post time for PSTH and behavior
% 	-Autoupdate period

% Buttons include:
% 	-"Update now!"
% 	-Check TDT connection (and reconnect if necessary) [display open block name when connected]

% Get list of events for triggers and display their names in popup
% Get list of snips for PSTH and display their names in listbox (for multiselection)
% Wait for user to do something
% Possibilities:

% 1. Press "Update Now!"
% 	-Use currently selected parameters to grab spike data from TDT and display raster and PSTH
% 2. Set nonzero update interval
% 	-Create and start up timer with requested interval to grab and display spike data
% 3. Set zero update interval
% 	-Stop update timer

% Epoch filtering:
% User will specify cascading filters by accumulating them into a cell array (listbox).
% Individual filters can be removed by selecting them and pressing a (-) button.
% TTX.CreateEpocIndexing
% {TTX.QryEpocAtV(EVENTNAME,time,0) to get the epoch value at a particular time}
% TTX.ResetFilters
% TTX.SetFilterWithDesc('EVENTNAME=EVENTVALUE'), e.g. 'Unit=1'
% 	-Note that cascaded filters are ANDed
% TTX.ReadEventsV([],...,'FILTERED') will now return only filtered events
% 	-Can optionally set all options as globals using TTX.SetGlobals {or SetGlobalV()} and use ReadEventsSimple instead.
% TTX.ParseEvV(OFFSET,N) to get all spike waveforms
% TTX.ParseEvInfoV(OFFSET,N,6) to grab all timestamps




