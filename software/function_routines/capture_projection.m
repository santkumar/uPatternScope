function [] = capture_projection(config, posNum, microscope)

imaging.types = {'brightfield','projector'};
imaging.groups = {'Channels','Channels'};
imaging.exposure = {50, 100};
numImagingTypes = 2;
camera = microscope.getCameraDevice();

for indx=1:numImagingTypes
    
    % Take image
    imageEvent = camera.makeImage(imaging.groups{indx}, imaging.types{indx}, imaging.exposure{indx});
    imageType = ['uint', mat2str(8 * imageEvent.getBytesPerPixel())];
    matlabImage = reshape(typecast(imageEvent.getImageData(), imageType), imageEvent.getWidth(), imageEvent.getHeight())';
    
    % Flip dimensions if necessary
    if imageEvent.isTransposeY()
        matlabImage = flipud(matlabImage);
    end
    if imageEvent.isTransposeX()
        matlabImage = fliplr(matlabImage);
    end
    if imageEvent.isSwitchXY()
        matlabImage = matlabImage';
    end
    
    % Save captured image
    imwrite(matlabImage, [config.imageFileLocation filesep 'p_' num2str(posNum) '_' imaging.types{indx} '_t' num2str(config.sampleNum, '%06d') '.tif']);
    imageEvent = [];
    imageType = [];
    matlabImage = [];
    
end

% Continue projection
microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue('1');
microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('1');

end