# Automated analysis of calcium-6 fluorescence curves
This repository contains MATLAB scripts with implementation of the method for automated analysis of calcium-6 fluorescence curves. The method performance is demonstrated on four sets of calcium-6 fluorescence curves. This software is licensed under the GNU GPL v3. In case of any questions please contact vladimir.sobota@ihu-liryc.fr.

## Data analysis
The fluorescence curves were obtained from 96 and 1536-well plate assays with human calcium-6-loaded platelets. In the 96-well plate the tested compound was pre-incubated so the fluorescence curve shows only the response to the agonist (collagen-related peptide, CRP, or thrombin). In the 1536-well plate the tested compound was added first, followed by the agonist addition, so the fluorescent curves are slightly different for each type of the well plate. The data are therefore analyzed by two different functions: `analyzeData_96.m` for the 96-well plate and `analyzeData_1536.m` for the 1536-well plate.

The input parameters of the analysis are set up at the beginning of the script. The following parameters are used for the curves from 96-well plates:

```
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
```

For the 1536-well plate, two more parameters are added, to indicate the time windows for the compound and agonist addition effects:

```
inputParams.windowCompoundAddition  = [0,100];          % time window for the compound addition effect
inputParams.windowAgonistAddition   = [200,300];        % time window for the agonist addition effect
```

The results are saved in the `results` matrix for each fluorescence curve. The order of the saved parameters is described in the variable `resultsLabel`:
```
AUC
Ca increase
Median fluorescence before peak start
Time of the peak
Peak fluorescence
Slope 1
Slope 1 duration
Slope 2
Slope 2 duration
Slope 3
Slope 3 duration
```

Please note that for the 1536-well plate the output parameter `Median fluorescence before peak start` is replaced by the parameters `Median fluorescence before the compound addition` and `Median fluorescence before the agonist addition`.

### Visualization
Some of the parameters are visualized in the figures below as follows:

![Sample graph](/graphs/graph_analysis.png?raw=true)

## Available data sets

### Collagen-related platelets (CRP), 96-well plate
These are examples of fluorescence curves from calcium-6 loaded platelets stimulated with CRP (10 ug/mL) in 96-well plate measured with FlexStation. The fluorescence curves are analyzed and visualized by running the script `dataAnalysis_CRP.m`. If the script is executed well, the following graph should appear:
![Sample graph](/graphs/CRP.png?raw=true)

### Thrombin, 96-well plate
These are examples of fluorescence curves from calcium-6 loaded platelets stimulated with thrombin (4 nM) in 96-well plate measured with FlexStation. The fluorescence curves are analyzed and visualized by running the script `dataAnalysis_Thr.m`. If the script is executed well, the following graph should appear:
![Sample graph](/graphs/Thr.png?raw=true)

### Collagen-related platelets (CRP), 1536-well plate
These are examples of fluorescence curves from calcium-6 loaded platelets stimulated with CRP (10 ug/mL) in 1536-well plate with FLIPR. The fluorescence curves are analyzed and visualized by running the script `dataAnalysis_CRP_n02.m`. If the script is executed well, the following graph should appear:
![Sample graph](/graphs/n02_CRP.png?raw=true)

### Thrombin, 1536-well plate
These are examples of fluorescence curves from calcium-6 loaded platelets stimulated with thrombin (4 nM) in 96 well plate with FLIPR. The fluorescence curves are analyzed and visualized by running the script `dataAnalysis_Thr_n02.m`. If the script is executed well, the following graph should appear:
![Sample graph](/graphs/n02_Thr.png?raw=true)

