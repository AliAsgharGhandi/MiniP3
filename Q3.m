% Initial Setup
clearvars; 
close all;

% Parameters Definition
ParamM = 4;
TrainNum = 200;
TotalNum = 700;
Lambda = 0.1;

% Preallocation
xBar = zeros(TrainNum, ParamM);
gBar = zeros(TrainNum, ParamM);
SigmaVal = zeros(TrainNum, ParamM);
yVal = zeros(TotalNum, 1);
uVal = zeros(TotalNum, 1);
xVal = zeros(TotalNum, 1);
yHat = zeros(TotalNum, 1);
fHat = zeros(TotalNum, 1);
zVal = zeros(TotalNum, 1);
gUVal = zeros(TotalNum, 1);

% Initial Conditions
uVal(1) = -1 + 2 * rand;
yVal(1) = 0;
gUVal(1) = 0.6 * sin(pi * uVal(1)) + 0.3 * sin(3 * pi * uVal(1)) + 0.1 * sin(5 * pi * uVal(1));
fHat(1) = gUVal(1);

% Fuzzy System Design - Step 1
uMin = -1;
uMax = 1;
stepH = (uMax - uMin) / (ParamM - 1);
for i = 1:ParamM
    xBar(1, i) = uMin + stepH * (i - 1);
    uVal(1, i) = xBar(1, i);
    gBar(1, i) = 0.6 * sin(pi * uVal(1, i)) + 0.3 * sin(3 * pi * uVal(1, i)) + 0.1 * sin(5 * pi * uVal(1, i));
end

SigmaVal(1, :) = (max(uVal(1, :)) - min(uVal(1, :))) / ParamM;

% Preserving initial values
xBarInitial = xBar(1, :);
SigmaInitial = SigmaVal(1, :);
gBarInitial = gBar(1, :);

% Fuzzy System Design - Step 2 and 3
for iter = 2:TrainNum
    sumA = 0;
    sumB = 0;
    xVal(iter) = -1 + 2 * rand;
    uVal(iter) = xVal(iter);

    gUVal(iter) = 0.6 * sin(pi * uVal(iter)) + 0.3 * sin(3 * pi * uVal(iter)) + 0.1 * sin(5 * pi * uVal(iter));
    for j = 1:ParamM
        zVal(j) = exp(-((xVal(iter) - xBar(iter, j)) / SigmaVal(iter, j))^2);
        sumA = sumA + zVal(j);
        sumB = sumB + gBar(iter, j) * zVal(j);
    end

    fHat(iter) = sumB / sumA;
    yVal(iter + 1) = 0.3 * yVal(iter) + 0.6 * yVal(iter - 1) + gUVal(iter);
    yHat(iter + 1) = 0.3 * yVal(iter) + 0.6 * yVal(iter - 1) + fHat(iter);

    for j = 1:ParamM
        gBar(iter + 1, j) = gBar(iter, j) - Lambda * (fHat(iter) - gUVal(iter)) * zVal(j) / sumA;
        xBar(iter + 1, j) = xBar(iter, j) - Lambda * ((fHat(iter) - gUVal(iter)) / sumA) * (gBar(iter, j) - fHat(iter)) * zVal(j) * 2 * (xVal(iter) - xBar(iter, j)) / (SigmaVal(iter, j)^2);
        SigmaVal(iter + 1, j) = SigmaVal(iter, j) - Lambda * ((fHat(iter) - gUVal(iter)) / sumA) * (gBar(iter, j) - fHat(iter)) * zVal(j) * 2 * (xVal(iter) - xBar(iter, j)) / (SigmaVal(iter, j)^3);
    end
end

% Final Values
xBarFinal = xBar(TrainNum, :);
SigmaFinal = SigmaVal(TrainNum, :);
gBarFinal = gBar(TrainNum, :);

% Processing Remaining Data
for iter = TrainNum:TotalNum
    sumA = 0;
    sumB = 0;
    xVal(iter) = sin(2 * iter * pi / 200);
    uVal(iter) = xVal(iter);

    gUVal(iter) = 0.6 * sin(pi * uVal(iter)) + 0.3 * sin(3 * pi * uVal(iter)) + 0.1 * sin(5 * pi * uVal(iter));
    for j = 1:ParamM
        zVal(j) = exp(-((xVal(iter) - xBarFinal(j)) / SigmaFinal(j))^2);
        sumA = sumA + zVal(j);
        sumB = sumB + gBarFinal(j) * zVal(j);
    end
    fHat(iter) = sumB / sumA;
    yVal(iter + 1) = 0.3 * yVal(iter) + 0.6 * yVal(iter - 1) + gUVal(iter);
    yHat(iter + 1) = 0.3 * yVal(iter) + 0.6 * yVal(iter - 1) + fHat(iter);
end

% Plotting Results
figure('Color', [1 1 1]);
plot(1:701, yVal, 'b', 1:701, yHat, 'r:', 'LineWidth', 2);
legend('Output of the Plant', 'Output of the Identification Model');
axis([0 701 -5 5]);
grid on;

% Initial and Final Membership Functions
plotRange = -2:0.001:2;

% Initial MFs
figure('Color', [1 1 1]);
for j = 1:ParamM
    mu_x = exp(-((plotRange - xBarInitial(j)) / SigmaInitial(j)).^2);
    plot(plotRange, mu_x, 'LineWidth', 2);
    hold on;
end
xlabel('u');
ylabel('Initial MFs');
axis([-1 1 0 1]);

% Final MFs
figure('Color', [1 1 1]);
for j = 1:ParamM
    mu_x = exp(-((plotRange - xBarFinal(j)) / SigmaFinal(j)).^2);
    plot(plotRange, mu_x, 'LineWidth', 2);
    hold on;
end
xlabel('u');
ylabel('Final MFs');
axis([-1 1 0 1]);
