clc;
clear variables;
close all;

% Paths
addpath('functions')
pathLoad        = 'data';
nameLoad        = 'Thr';
pathSaveGraphs  = 'graphs';

%% Analysis settings

% parameters of the analysis
inputParams.smoothMethod            = 'loess';          % method of signal smoothing
inputParams.smoothSpan              = 0.1;              % smoothing span
inputParams.peakStart               = 20;               % time when the peak starts
inputParams.windowFirstMaximum      = [0,200];          % where to search for the first maximum
inputParams.longestTimeToPeak       = 250;              % longest time to peak
inputParams.thirdSlopeStart         = 350;              % third slope start time
inputParams.thirdSlopeEnd           = 500;              % third slope end time
inputParams.showGraphs              = 1;                % graphs should be shown (1/0)
inputParams.saveGraphs              = 1;                % graphs should be saved (1/0)
inputParams.pathSaveGraphs          = 'graphs';         % path for saving the graphs
inputParams.nameSaveGraphs          = nameLoad;         % file name for saving the graphs

% how the results are saved
resultsLabel = {'AUC', 'Ca increase', 'Median fluorescence before peak start', 'Time of the peak', ...
    'Peak fluorescence', 'Slope 1', 'Slope 1 duration', 'Slope 2', 'Slope 2 duration', 'Slope 3', 'Slope 3 duration'};

%% Load and process the data

% Load data
load(fullfile(pathLoad,nameLoad), 'data', 'header');

% analyze the data
results = analyzeData_96(inputParams,data,header);

