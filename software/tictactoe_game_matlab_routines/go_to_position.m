function [] = go_to_position(config, indx, xyzPositions, microscope)

    x = xyzPositions(indx,1);
    y = xyzPositions(indx,2);    
    z = xyzPositions(indx,3);    

    microscope.getStageDevice().setPosition(x,y);
    pause(10);
    microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).setValue(num2str(z));    
    pause(0.1);
    
end