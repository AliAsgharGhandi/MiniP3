% Environment Setup
clearvars;
close all;

% Mackey-Glass Chaotic Time Series Data Generation
numPoints = 900;  % Total number of points
chaoticSeries = zeros(1, numPoints);
dataSet = zeros(numPoints, 7);
chaoticSeries(1, 1:31) = 1.3 + 0.2 * rand(1, 31);

% Generate Data
for point = 31:numPoints - 1
    chaoticSeries(1, point + 1) = 0.2 * (chaoticSeries(1, point - 30) / (1 + chaoticSeries(1, point - 30)^10)) + 0.9 * chaoticSeries(1, point);
    dataSet(point, 2:6) = [chaoticSeries(1, point - 3) chaoticSeries(1, point - 2) chaoticSeries(1, point - 1) chaoticSeries(1, point) chaoticSeries(1, point + 1)];
end
processedData = dataSet(201:800, 2:6);
timeSeq = 1:600;

% Plot Data
fig1 = figure('Color', [1 1 1]);
plot(timeSeq, chaoticSeries(201:800), 'LineWidth', 2);
grid on;

% Fuzzy System Design
for option = 1:2
    if option == 1
        mfNum = 7; 
        centerPoints = linspace(0.5, 1.3, 5);
        delta = 0.2;
    else
        mfNum = 15; 
        centerPoints = linspace(0.3, 1.5, 13);
        delta = 0.1;
    end

    % Define Membership Functions
    mfSet = cell(mfNum, 2);
    for mfIndex = 1:mfNum
        if mfIndex == 1
            mfSet{mfIndex, 1} = [0, 0, 0.3, 0.5];
            mfSet{mfIndex, 2} = 'trapmf';
        elseif mfIndex == mfNum
            mfSet{mfIndex, 1} = [1.3, 1.5, 1.8, 1.8];
            mfSet{mfIndex, 2} = 'trapmf';
        else
            mfSet{mfIndex, 1} = [centerPoints(mfIndex - 1) - delta, centerPoints(mfIndex - 1), centerPoints(mfIndex - 1) + delta];
            mfSet{mfIndex, 2} = 'trimf';
        end
    end

    % Rule Assignment
    [trainSize, ~] = size(processedData);
    ruleMatrix = zeros(trainSize, 6);
    consolidatedRules = zeros(trainSize / 2, 6);
    for dataIndex = 1:trainSize
        processedData(dataIndex, 1) = dataIndex;
        for varIndex = 2:6
            currentValue = processedData(dataIndex, varIndex);
            mfValues = zeros(1, mfNum);
            for mfIndex = 1:mfNum
                if mfIndex == 1 || mfIndex == mfNum
                    mfValues(mfIndex) = trapmf(currentValue, mfSet{mfIndex, 1});
                else
                    mfValues(mfIndex) = trimf(currentValue, mfSet{mfIndex, 1});
                end
            end
            [maxValue, maxIndex] = max(mfValues);
            ruleMatrix(dataIndex, varIndex - 1) = maxIndex;
            ruleMatrix(dataIndex, 6) = prod(mfValues);
            processedData(dataIndex, 7) = prod(mfValues);
        end
    end

    % Pruning Rules
    consolidatedRules(1, :) = ruleMatrix(1, :);
    ruleCounter = 1;
    for dataIndex = 2:trainSize
        ruleMatch = zeros(1, ruleCounter);
        for checkIndex = 1:ruleCounter
            ruleMatch(checkIndex) = isequal(ruleMatrix(dataIndex, 1:4), consolidatedRules(checkIndex, 1:4));
            if ruleMatch(checkIndex) == 1 && ruleMatrix(dataIndex, 6) >= consolidatedRules(checkIndex, 6)
                consolidatedRules(checkIndex, :) = ruleMatrix(dataIndex, :);
            end
        end
        if sum(ruleMatch) == 0
            ruleCounter = ruleCounter + 1;
            consolidatedRules(ruleCounter, :) = ruleMatrix(dataIndex, :);
        end
    end
end

% Displaying Final Rules
disp('******************************')
disp(['Final rules set with ', num2str(mfNum), ' membership functions for each input variable'])
finalRulesSet = consolidatedRules(1:ruleCounter, :);

% Fuzzy Inference System Construction
fisName = 'PredictiveSystem';
fisType = 'mamdani';
fisMethods = {'prod', 'max', 'prod', 'max', 'centroid'};
fisModel = newfis(fisName, fisType, fisMethods{:});

% Add Variables to FIS
for inputVar = 1:4
    fisModel = addInput(fisModel, [0.1 1.7], 'Name', ['x' num2str(inputVar)]);
end
fisModel = addOutput(fisModel, [0.1 1.7], 'Name', 'x5');

% Add Membership Functions to FIS
for inputVar = 1:4
    for mfIndex = 1:mfNum
        fisModel = addMF(fisModel, ['x' num2str(inputVar)], mfSet{mfIndex, 2}, mfSet{mfIndex, 1}, 'Name', ['MF' num2str(mfIndex)]);
    end
end

% Add Rules to FIS
ruleMatrixTrimmed = consolidatedRules(any(consolidatedRules(:, 1:5), 2), :);
fisModel = addrule(fisModel, [ruleMatrixTrimmed, ones(size(ruleMatrixTrimmed, 1), 1)]);

% Prediction using FIS
predictionData = zeros(300, 2);
for index = 301:600
    inputVector = processedData(index, 2:6);
    predictedOutput = evalfis(fisModel, inputVector(1:4));
    predictionData(index - 300, :) = [index - 300, predictedOutput];
end

% Plotting Predictions
figure;
plot(predictionData(:, 1), predictionData(:, 2), 'r-.', 'LineWidth', 2);
hold on;
plot(predictionData(:, 1), processedData(301:600, 6), 'b', 'LineWidth', 2);
legend('Estimated Value', 'Actual Value');

% Plot Membership Functions for Specified Input Variable
figure;
plotmf(fisModel, 'input', 1);
title('Membership Functions for Input Variable 1');
