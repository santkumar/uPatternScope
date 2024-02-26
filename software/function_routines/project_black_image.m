function [] = project_black_image(config, microscope, dmd)

    dmd.display(config.blackImage);
    microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('0');

end