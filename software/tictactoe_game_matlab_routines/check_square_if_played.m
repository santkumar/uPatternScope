function [out] = check_square_if_played(config,posNum)

    out = 0;
    
    I = imread([config.imageFileLocation filesep num2str(posNum) '_CFP_z1_t' num2str(config.sampleNum, '%06d') '.tif']);
    I(I>config.threshold.deadOrAlive) = 65535;
    I(I<=config.threshold.deadOrAlive) = 0;
    
    if mean(I(:)>config.threshold.playedOrNot)
       cropI = I(600:1450,600:1450);
       if mean(cropI(:)>config.threshold.circleOrCross)
           out = 1; % Circle
       else
           out = 2; % Cross
       end
    else
        out = 0; % Not played on this position
    end

    
end