%% After running "main.m" routine, please modify and run "test_tracking.m" routine to check the tracking results 

clear all;
close all;
clc;

% Initializations
if ~exist('config','var')
    config = config_routine;
    microscopyResultsFolder = config.getMicroscopyDirectory();
    trackHandle = tracking;
end
%%
for frameNumber = 90:200

    % Get all image handles
    imHandle = config.imNames.getImPath(frameNumber,microscopyResultsFolder);

    % Single cells segmentation from fluorescence (nuclear marker) image
    segFlag = system(['fastER-CL\fastER_qt5_msvc2017.exe -headless fastER_trained\ecoli_phase.fastER ' imHandle.fluo ' ' imHandle.seg]);
    if segFlag
        error('Check segmentation (fastER) pipeline!')
    end

    % Tracking
    stackedFmStruct = trackHandle.concatenateFrames(90, frameNumber, config, microscopyResultsFolder);
    trackedFmStruct = trackHandle.addTrackIndex(stackedFmStruct);
    numTrajectories = max(trackedFmStruct.trackindex);
    indxFramesAll = 1:length(trackedFmStruct.trackindex);
    indxCurrentFm = indxFramesAll(trackedFmStruct.cellframe==frameNumber);

end
