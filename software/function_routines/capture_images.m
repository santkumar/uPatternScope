function [] = capture_images(config, posNum, microscope)

    microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('1'); % Close projection shutter
    microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue('0'); % Change to empty filter
    
    numImagingTypes = length(config.imaging.types);
    camera = microscope.getCameraDevice();
    currentZ = microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).getValue();
    
    for indx=1:numImagingTypes
        
        numZStacks = length(config.imaging.zOffsets{indx});
        zValues = config.imaging.zOffsets{indx} + str2double(currentZ);
        
        for zIndx = 1:numZStacks

            % Set z value    
            microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).setValue(num2str(zValues(zIndx)));
            pause(0.1);
            
            % Take image
            imageEvent = camera.makeImage(config.imaging.groups{indx}, config.imaging.types{indx}, config.imaging.exposure{indx});
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
            imwrite(matlabImage, [config.imageFileLocation filesep num2str(posNum) '_' config.imaging.types{indx} '_z' num2str(zIndx) '_t' num2str(config.sampleNum, '%06d') '.tif']);
            imageEvent = [];
            imageType = [];
            matlabImage = [];
            
        end
    end

    % Bring back to original z
    microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).setValue(currentZ);
    pause(0.1);
    
end