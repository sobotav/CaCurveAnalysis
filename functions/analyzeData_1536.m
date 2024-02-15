function [results] = analyzeData_1536(inputParams,data,header)
%analyzeDataset analyzes the given dataset and generates graphs

%% Data processing and visualization

NgraphsPerFigure    = 3;                    % number of graphs per figure
NsignalsTotal       = size(data,2)-1;       % total number of signals
Nfigures            = ceil(NsignalsTotal/NgraphsPerFigure); % number of figures

results = NaN(NsignalsTotal,12);            % initialize results

s = 1;
for i = 1:Nfigures
    
    for k = 1:NgraphsPerFigure
        
        if s <= NsignalsTotal
            
            if inputParams.showGraphs
                f = figure(i);
                subplot(1,NgraphsPerFigure,k)
            end
            
            resultsSignal  = analyzeSignal(data(:,1), data(:,k+1), inputParams);
            
            if inputParams.showGraphs
                title(header{k+1}, 'interpreter', 'none');
            end
            
            % save the results
            results(k,1) = resultsSignal.AUC;                   % area under the curve
            results(k,2) = resultsSignal.CaIncrease;            % calcium increase
            results(k,3) = resultsSignal.medianBeforeCompound;  % median fluorescence before the compound addition
            results(k,4) = resultsSignal.medianBeforeAgonist;   % median fluorescence before the agonist addition
            results(k,5) = resultsSignal.tMax1;                 % time of the first maximum
            results(k,6) = resultsSignal.peakFluorescence;      % peak fluorescence
            results(k,7) = resultsSignal.slope1;                % first slope
            results(k,8) = resultsSignal.slope1Duration;        % duration of the first slope
            results(k,9) = resultsSignal.slope2;                % second slope
            results(k,10) = resultsSignal.slope2Duration;        % duration of the second slope
            results(k,11) = resultsSignal.slope3;               % third slope
            results(k,12) = resultsSignal.slope3Duration;       % duration of the third slope

        end
    end
    
    if inputParams.saveGraphs % saving the figure
        set(f,'Position',[100 100 900 400]);
        set(f,'PaperOrientation','landscape');
        saveas(f,fullfile(inputParams.pathSaveGraphs,inputParams.nameSaveGraphs), 'pdf');
    end
end

%% Functions

function results = analyzeSignal(timeStamp, signal, inputParams)
    % analyze and visualize the signal
    
    signalSmooth            = smooth(signal, inputParams.smoothSpan, inputParams.smoothMethod);                             % smoothening of the data
    [iCompoundAddition,tCompoundAddition]   = findNegativePeak(timeStamp, signal, inputParams.windowCompoundAddition);      % compound addition
    [iAgonistAddition,tAgonistAddition]     = findNegativePeak(timeStamp, signal, inputParams.windowAgonistAddition);       % agonist addition    
    medianBeforeCompound    = calcPercentileFromInterval(timeStamp, signal, [0,tCompoundAddition], 50);                     % median value before the compound
    medianBeforeAgonist     = calcPercentileFromInterval(timeStamp, signal, [tCompoundAddition,tAgonistAddition], 50);      % median value before the agonist
        
    % Calculate the slopes
    [slope3, tSlope3, vSlope3]  = calcSlope(timeStamp, signal, [inputParams.thirdSlopeStart, inputParams.thirdSlopeEnd]);   % Calculate the 3rd slope
    [iMax,tMax] = findLocalExtreme(timeStamp, signalSmooth, [inputParams.peakStart, inputParams.longestTimeToPeak], 'max'); % find local maximum for the first slope 
    
    if tMax > inputParams.longestTimeToPeak % if the time of local maximum is later than the time to peak, do not calculate the second slope
        
        iMax = find(timeStamp > inputParams.longestTimeToPeak, 1);
        tMax = timeStamp(iMax-1);
        [slope1, tSlope1, vSlope1] = calcSlope(timeStamp, signal, [inputParams.peakStart, tMax]);       % calculate the first slope
        
        % the second slope is NaN
        slope2 	= NaN;
        tSlope2	= NaN;
        vSlope2	= NaN;
        
        % there is no local minimum
        tMin    = [];
        iMin    = [];
        
    else % define the local minimum and calculate the second slope
        
        [slope1, tSlope1, vSlope1] = calcSlope(timeStamp, signal, [inputParams.peakStart, tMax]);       % calculate the first slope
        [iMin,tMin] = findLocalExtreme(timeStamp, signalSmooth, [tMax, inputParams.windowFirstMaximum(2)], 'min'); % find local minimum (for the second slope) 
    
        if tMin > inputParams.thirdSlopeStart  % if tMin is too late, replace it with the start of the third slope
            iMin = find(timeStamp > tSlope3Start, 1);
            tMin = timeStamp(iMin);
        end
        
        % calculate second slope
        [slope2, tSlope2, vSlope2] = calcSlope(timeStamp, signal, [tMax, tMin]);         % calculate the second slope
        
    end
    
    % -------------------------
    % AOC analysis
    
    % calculate the start level for the AOC analysis using the 95th
    % percentile of the interval between the compound and the agonist
    % addition
    startLevel  = calcPercentileFromInterval(timeStamp, signal, [tCompoundAddition,tAgonistAddition], 95);
    CaIncrease = signalSmooth(iMax)-startLevel;    % calcium increase
    if CaIncrease > 0
        AUC = calcAUC(timeStamp, signal, 1, startLevel);
    else
        AUC = 0;
    end
    
    % -------------------------
    % save the parameters
    results.AUC                     = AUC;                              % area under the curve
    results.CaIncrease              = CaIncrease;                       % calcium increase
    results.medianBeforeCompound    = medianBeforeCompound;             % median fluorescence before the compound addition
    results.medianBeforeAgonist     = medianBeforeAgonist;              % median fluorescence before the agonist addition
    results.tMax1                   = tMax;                             % time of the first maximum
    results.peakFluorescence        = signalSmooth(iMax);               % fluorescence value of the peak
    results.slope1                  = slope1;                           % first slope
    results.slope1Duration          = tSlope1(end)-tSlope1(1);          % duration of the first slope
    results.slope2                  = slope2;                           % second slope
    results.slope2Duration          = tSlope2(end)-tSlope2(1);          % duration of the second slope
    results.slope3                  = slope3;                           % third slope
    results.slope3Duration          = tSlope3(end)-tSlope3(1);          % duration of the third slope
    
    % -------------------------
    % Visualization
    
    if inputParams.showGraphs
        
        plot(timeStamp, signal, 'k', 'LineWidth', 2)
        hold on
        scatter(tCompoundAddition,signal(iCompoundAddition), 'go', 'filled')                        % time of the compound addition
        scatter(tAgonistAddition,signal(iAgonistAddition), 'mo', 'filled')                          % time of the agonist addition
        plot([0,tCompoundAddition], medianBeforeCompound*[1,1], 'g', 'LineWidth', 2)                % median fluorescence before the compound addition
        plot([tCompoundAddition,tAgonistAddition], medianBeforeAgonist*[1,1], 'm', 'LineWidth', 2)  % median fluorescence before the agonist addition
        plot([tCompoundAddition,tAgonistAddition], startLevel*[1,1], 'c', 'LineWidth', 2)           % start level for the AOC analysis

        scatter(tMax, signal(iMax), 'ro', 'filled')     % time of the first local maximum
        scatter(tMin, signal(iMin), 'yo', 'filled')     % time of the local minimum after the peak
        plot(tSlope1, vSlope1, 'r', 'LineWidth', 2)
        plot(tSlope2, vSlope2, 'b', 'LineWidth', 2)
        plot(tSlope3, vSlope3, 'Color', [0.7, 0.7, 0.7], 'LineWidth', 2)
        plot([tMax,tMax], [startLevel, startLevel+results.CaIncrease], 'g', 'LineWidth', 2)       % calcium increase
        
        xlabel('Time (s)')
        ylabel('Fluorescence')
        
        hold off     
        
    end    
end

function [iMin,tMin] = findNegativePeak(timeStamp, signal, tWindow)
% find a negative peak in the part of the signal defined by the window

    diffSignal = diff(signal);

    % find the indices of the window
    iWindowStart = find(timeStamp>=tWindow(1),1);    
    iWindowEnd   = find(timeStamp>=tWindow(2),1);  
    
    diffSignalSelection = diffSignal(iWindowStart:iWindowEnd);
    [~, iMin] = min(diffSignalSelection);
    
    iMin = iMin + iWindowStart;
    tMin = timeStamp(iMin);
end

function [medianLevel] = calcPercentileFromInterval(timeStamp,signal,tWindow, p)
% calculate median of the given interval

    % find the indices of the window
    iWindowStart = find(timeStamp>=tWindow(1),1);    
    iWindowEnd   = find(timeStamp>=tWindow(2),1);
    
    signalSelection = signal(iWindowStart:iWindowEnd);
    medianLevel = prctile(signalSelection,p);
end

function [iExtreme,tExtreme] = findLocalExtreme(timeStamp, signal, tWindow, type)
% find local minimum or maximum in the smoothened signal

    % find the indices of the window
    iWindowStart = find(timeStamp>=tWindow(1),1);    
    iWindowEnd   = find(timeStamp>=tWindow(2),1);  
    
    signalSelection = signal(iWindowStart:iWindowEnd,1);
    
    if strcmp(type, 'max') 
        [~, iExtreme] = max(signalSelection); % local maximum
    elseif strcmp(type, 'min')
        [~, iExtreme] = min(signalSelection); % local minimum
    end
    
    iExtreme = iExtreme + iWindowStart;
    tExtreme = timeStamp(iExtreme);
end

function [slope, tSlope, vSlope] = calcSlope(timeStamp, signal, tWindow)
% interpolate the given part of the signal with a line and calculate the
% slope

    % set the values by default as NaN, only if both tWindow values are
    % correct, the calculation is performed
    slope   = NaN;
    tSlope  = NaN;
    vSlope  = NaN;

    if numel(tWindow) == 2
        %
        %ADDED: skip the first and the last 10% of the time of the interval
        intervalDuration    = tWindow(2)-tWindow(1);
        timeCorrection      = (100-80)/2*intervalDuration/100;
        tWindow(1) = tWindow(1) + timeCorrection;
        tWindow(2) = tWindow(2) - timeCorrection;

        % find the indices of the window
        iWindowStart = find(timeStamp>=tWindow(1),1);    
        iWindowEnd   = find(timeStamp>=tWindow(2),1);  

        tSlope = timeStamp(iWindowStart:iWindowEnd);
        signalSelection = signal(iWindowStart:iWindowEnd);

        X = [ones(length(tSlope),1), tSlope];
        b = X\signalSelection;

        slope = (b(2));

        vSlope = b(1) + b(2)*tSlope;
    end
    
end

function AUC = calcAUC(timeStamp, signal, iAgonistAddition, startLevel)
% calculates the area under curve (AOC)
    
    % select just the part of the signal after agonist addition
    timeStampSelection = timeStamp(iAgonistAddition:end);
    signalSelection = signal(iAgonistAddition:end);
    
    % correct for offset, crop the signal
    signalSelection = signalSelection - startLevel;
    timeStampSelection = timeStampSelection(signalSelection > 0);
    signalSelection = signalSelection(signalSelection > 0);
        
    % calclate AUC
    if numel(timeStampSelection) > 1
        AUC = trapz(timeStampSelection, signalSelection);
    else
        AUC = 0;
    end
    
end

end

