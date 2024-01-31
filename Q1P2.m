% Initialize and start timer
beginTime = tic;

% Define parameters
minVal = -1;
maxVal = 1;
resolution = 0.001;
step = 0.25;
gridSize = 8;

% Initialize matrices
combinedGrid = zeros(gridSize * gridSize, 1);
offset1 = zeros(gridSize, 1);
offset2 = zeros(gridSize, 1);

% Generate grid
[yGrid, xGrid] = meshgrid(minVal:resolution:maxVal, minVal:resolution:maxVal);

% Initialize summation variables
sumNumerator = 0;
sumDenominator = 0;
counter = 0;

% Nested loops for grid calculation
for idx1 = 1:gridSize
    for idx2 = 1:gridSize
        offset1(idx1) = minVal + step * (idx1 - 1);
        offset2(idx2) = minVal + step * (idx2 - 1);
        
        % Membership function calculation for xGrid
        if idx1 == 1
            membershipFuncX1 = trimf(xGrid(:), [minVal, minVal, minVal + step]);
        elseif idx1 == gridSize
            membershipFuncX1 = trimf(xGrid(:), [maxVal - step, maxVal, maxVal]);
        else
            membershipFuncX1 = trimf(xGrid(:), [minVal + step * (idx1 - 2), minVal + step * (idx1 - 1), minVal + step * idx1]);
        end

        % Membership function calculation for yGrid
        if idx2 == 1
            membershipFuncX2 = trimf(yGrid(:), [minVal, minVal, minVal + step]);
        elseif idx2 == gridSize
            membershipFuncX2 = trimf(yGrid(:), [maxVal - step, maxVal, maxVal]);
        else
            membershipFuncX2 = trimf(yGrid(:), [minVal + step * (idx2 - 2), minVal + step * (idx2 - 1), minVal + step * idx2]);
        end

        combinedGrid(counter + 1) = 1 / (3 + offset1(idx1) + offset2(idx2));
        sumNumerator = sumNumerator + combinedGrid(counter + 1) * membershipFuncX1 * membershipFuncX2;
        sumDenominator = sumDenominator + membershipFuncX1 * membershipFuncX2;
        counter = counter + 1;
    end
end

% Compute the function values
funcValue = reshape(sumNumerator ./ sumDenominator, size(yGrid));

% Calculating g_x
gValue = 1 ./ (3 + yGrid + xGrid);

% Plot function value
fig1 = figure('Color', [1 1 1]);
mesh(yGrid, xGrid, funcValue, 'LineWidth', 2);
xlabel('yGrid', 'Interpreter', 'latex');
ylabel('xGrid', 'Interpreter', 'latex');
zlabel('Function Value', 'Interpreter', 'latex');
legend('Function Value', 'Interpreter', 'latex');
grid on;

% Plot error
fig2 = figure('Color', [1 1 1]);
errorVal = gValue - funcValue;
mesh(yGrid, xGrid, errorVal, 'LineWidth', 2);
xlabel('yGrid', 'Interpreter', 'latex');
ylabel('xGrid', 'Interpreter', 'latex');
zlabel('Error', 'Interpreter', 'latex');
legend('Error', 'Interpreter', 'latex');
grid on;

% End timer
elapsedTime = toc(beginTime);
disp(['Elapsed Time: ', num2str(elapsedTime)]);
