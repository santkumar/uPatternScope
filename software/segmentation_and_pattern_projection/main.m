clear all;
clc;

%% Initializations
% Initialize DMD
dmd = DMD;
dmd.definePattern;
dmd.setMode(3);
blackImage = zeros(1080,1920);
dmd.display(blackImage); % Start with a black image (projection)

% Initialize calibration routine variables
calibParams = load('calibration\projectionParams.mat');

%% Segment single cells
segFlag = system(['fastER-CL\fastER_qt5_msvc2017.exe -headless hela_10x.fastER bri_image.tif seg_image.tif']);
if segFlag
    error('Check segmentation (fastER) pipeline!')
end

%% Prepapre input mask for projection
segImage = imread('seg_image.tif');
segImage(segImage>0) = 255;

segImage = flip(segImage,2);
segImageColored = zeros([2048 2048]);
segImageColored(:,:) = segImage;
segImageScaled = imresize(segImageColored, 0.5273); % 1080/2048
projPatch = imwarp(segImageScaled, calibParams.tformPoly);
corrProjectionImage = resizePatch(projPatch, [1920, 1080], -calibParams.tformOffset);
corrProjectionImage(corrProjectionImage>255) = 255;
corrProjectionImage(corrProjectionImage<0) = 0;
corrProjectionImage = fix(corrProjectionImage);

%% Project mask image
dmd.display(corrProjectionImage);
