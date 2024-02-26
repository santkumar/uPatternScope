clear all
clc;

addpath('../');

%% Parameter initialization
projectionSize = [1920, 1080];           % [width(x), height(y)]
projectionCenter = projectionSize/2;
projectionColor = [0, 0, 1];            % [r, g, b] each ranges from [0, 1]
circleRadius = 10;
gridSize = [10, 10];                    % (x, y)
numCircles = gridSize(1)*gridSize(2);
% padding = [315, 285, 300, 100];         % (x left, x right, y top, y bottom)
%padding = [825, 650, 445, 200];         % (x left, x right, y top, y bottom)

% padding = [750, 675, 365, 225]; % WORKING

% TEST
% padding = [750, 675, 400, 350];


padding = [720, 470, 330, 100];


%% Initialize DMD
dmd = DMD;
dmd.definePattern;
dmd.setMode(3);
%blackImage = zeros(1080,1920);
%dmd.display(blackImage);

     %% Create calibration image and project it
projectionHandle = projection(projectionSize, projectionColor, circleRadius, gridSize, padding);
projectionHandle = projectionHandle.getProjectionImage();
imwrite(projectionHandle.image, 'calibration_image.tif' )
dmd.display(projectionHandle.image);

%% Load image taken
capturedImage = imread('C:\Users\Localadmin\Documents\image_taken.tif');
capturedImage = flip(capturedImage,2); % mirror image

%figure(1)
%imshow(capture1Image)
%d = imdistline;

radiusRange = [25, 35]; % User should estimate this directly from the captured image.
%delete(d)
%clear d
%close
sensitivity = 0.9;

captureHandle = capture(capturedImage, radiusRange);
% detect circles in captured image and visualise the result
[centersArray, radiiArray] = detectCircles(captureHandle.rawImage, radiusRange, sensitivity, projectionHandle.gridSize, 1); 

captureHandle = captureHandle.setGrids(centersArray, radiiArray, projectionHandle.gridSize);
captureHandle = captureHandle.scaleImage(projectionHandle);

%% Find transformation from capture to projection
movingPoints = reshape(captureHandle.centersGrid, numCircles, 2);
fixedPoints = reshape(projectionHandle.centersGrid, numCircles, 2);
tformPoly = fitgeotrans(movingPoints, fixedPoints, 'Polynomial',2);
%%
% test geo transform found
estProjPos = transformPointsInverse(tformPoly, fixedPoints);
figure(1)
imshow(captureHandle.scaledImage)
hold on
scatter(estProjPos(:,1), estProjPos(:,2))


%%
% find offset between restored projection image to real projection using
% the top left circle
projectionGridCenter = [mean(mean(projectionHandle.centersGrid(:,:,1))), mean(mean(projectionHandle.centersGrid(:,:,2)))];
captureHandle = captureHandle.getBWImage(centersArray, radiiArray);
imageScaled = imresize(captureHandle.BWImage, 0.5273); % 1080/2048
restoredBW = imwarp(captureHandle.BWImage, tformPoly);
%restoredBW = imwarp(imageScaled, tformPoly);
%restoredBW = resizePatch(restoredBW, [2048, 2048], [0,0]);


[restoredCenters, restoredRadii] = detectCircles(restoredBW, [projectionHandle.circleRadius-1, projectionHandle.circleRadius+1] , sensitivity, projectionHandle.gridSize, 0);
restoredGridCenter = mean(restoredCenters);


%tformOffset = round(projectionGridCenter - restoredGridCenter);

%%%%%%%%%%%% TODO!
tformOffset = round(restoredGridCenter-projectionGridCenter);

save('projectionParams.mat', 'tformOffset', 'tformPoly');
%{
% see if restored projection image is similar to the real one
capture1 = capture1.getColoredImage(projection1.color, centersArray1, radiiArray1);
restoredColor = imwarp(capture1.coloredImage, tformPoly);
restoredProjection1 = resizePatch(restoredColor, projection1.imageSize, tformOffset);
finalRestoredCenters = detectCircles(restoredProjection1, [projection1.circleRadius*0.7, projection1.circleRadius*1.3] , sensitivity, projection1.gridSize, 0);
figure(2)
scatter(fixedPoints(:,1), fixedPoints(:,2))
hold on
scatter(finalRestoredCenters(:,1), finalRestoredCenters(:,2))

%% Build transformed projection image
capture2Image = imread('target.tif');
capture2Image = flip(capture2Image,1);
%{
figure(1)
imshow(capture2Image)
d = imdistline;
%}
radiusRange2 = [24, 34]; % User should estimate this directly from the captured image.
%{
delete(d)
clear d
close
%}
sensitivity = 0.9;
capture2 = capture(capture2Image, radiusRange2);

[centersArray2, radiiArray2] = detectCircles(capture2.rawImage, radiusRange2, sensitivity, gridSize, 1);

capture2 = capture2.setGrids(centersArray2, radiiArray2, gridSize);
capture2 = capture2.scaleImage(projection1);
capture2 = capture2.getColoredImage(projection1.color, centersArray2, radiiArray2);
tformedPatch = imwarp(capture2.coloredImage, tformPoly);
tformedProjection = resizePatch(tformedPatch, projectionSize, tformOffset);

imwrite(tformedProjection, 'transformed_projection.tif');

%% Visualize results
capture3Image = imread('taken.tif');
capture3Image = flip(capture3Image,1); % mirrow image
radiusRange3 = [24, 34];
capture3 = capture(capture3Image, radiusRange3);
sensitivity = 0.9;
[centersArray3, radiiArray3] = detectCircles(capture3.rawImage, radiusRange3, sensitivity, gridSize, 1);
figure(2)
scatter(centersArray2(:,1), centersArray2(:,2))
hold on
scatter(centersArray3(:,1), centersArray3(:,2))
%}