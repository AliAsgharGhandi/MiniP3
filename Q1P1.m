% Start measuring execution time
startTime = tic;

% Initialize parameters and ranges
lowerBound = -1;
upperBound = 1;
stepSize = 0.05;
gridPoints = 40;
resolution = 0.001;
range = lowerBound:resolution:upperBound;

% Preallocate arrays
gMatrix = zeros(gridPoints^2, 1);
epsilon1 = zeros(gridPoints, 1);
epsilon2 = zeros(gridPoints, 1);

% Create meshgrid for calculation
[Y, X] = meshgrid(range, range);

% Initialize accumulators
accumulatorNum = 0;
accumulatorDen = 0;
index = 0;

% Iterating over grid points
for ii = 1:gridPoints
    for jj = 1:gridPoints
        epsilon1(ii) = lowerBound + stepSize * (ii - 1);
        epsilon2(jj) = lowerBound + stepSize * (jj - 1);
        
        if ii == 1
            muX1 = trimf(Y(:), [lowerBound, lowerBound, lowerBound + stepSize]);
        elseif ii == gridPoints
            muX1 = trimf(Y(:), [upperBound - stepSize, upperBound, upperBound]);
        else
            muX1 = trimf(Y(:), [lowerBound + stepSize * (ii - 2), lowerBound + stepSize * (ii - 1),
