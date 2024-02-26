function [] = project_image(config, player, microscope, dmd)

    microscope.getDevice(config.deviceShutterFluo).getProperty(config.propertyShutter).setValue('0');
    microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue('1');
    if player==1        
        dmd.display(config.circleProjectionImage);
    elseif player==2
        dmd.display(config.crossProjectionImage);
    end
    microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('1');

end