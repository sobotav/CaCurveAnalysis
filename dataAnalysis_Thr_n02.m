clc;
clear variables;
close all;

% Paths
addpath('functions')
pathLoad        = 'data';
nameLoad        = 'n02_Thr';
pathSaveGraphs  = 'graphs';

%% Analysis settings

% parameters of the analysis
inputParams.smoothMethod            = 'loess';          % method of signal smoothing
inputParams.smoothSpan              = 0.1;              % smoothing span
inputParams.peakStart               = 255;              % time when the peak starts
inputParams.windowCompoundAddition  = [0,100];          % time window for the compound addition effect
inputParams.windowAgonistAddition   = [200,300];        % time window for the agonist addition effect
inputParams.windowFirstMaximum      = [0,450];          % where to search for the first maximum
inputParams.longestTimeToPeak       = 350;              % longest time to peak
inputParams.thirdSlopeStart         = 500;              % third slope start time
inputParams.thirdSlopeEnd           = 700;              % third slope end time
inputParams.showGraphs              = 1;                % graphs should be shown (1/0)
inputParams.saveGraphs              = 1;                % graphs should be saved (1/0)
inputParams.pathSaveGraphs          = 'graphs';         % path for saving the graphs
inputParams.nameSaveGraphs          = nameLoad;         % file name for saving the graphs

% how the results are saved
resultsLabel = {'AUC', 'Ca increase', 'Median fluorescence before the compound addition', 'Median fluorescence before the agonist addition', ...
    'Time of the peak', 'Peak fluorescence', 'Slope 1', 'Slope 1 duration', 'Slope 2', 'Slope 2 duration', 'Slope 3', 'Slope 3 duration'};

%% Load and process the data

% Load data
load(fullfile(pathLoad,nameLoad), 'data', 'header');

% analyze the data
results = analyzeData_1536(inputParams,data,header);

