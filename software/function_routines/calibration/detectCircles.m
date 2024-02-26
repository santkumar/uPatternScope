function [centers, radii] = detectCircles(image, radiusRange, sensitivity, desiredGridSize, visualiser)
% Function description: this function detects the circles present in an image
    finished = 0; % a logical variable indicating whether all circles have been found
    gain = 0.05;
    numberOfCircles = desiredGridSize(1)*desiredGridSize(2);
    while ~finished
        % TODO: look up opencv to see if I can set a minimum distance to
        % the centers of circles found, so that accuracy will be improved.
        [centers,radii] = imfindcircles(image, radiusRange, 'ObjectPolarity', 'bright', 'Method', 'TwoStage', 'Sensitivity', sensitivity); % returned centers by imfindcircles() are in (x,y) format
        
        % select only circles close to average size to filter out artifacts
        meanR = mean(radii);
        trueCcIdx = radii<meanR*1.2 | radii>meanR*0.8;
        radii = radii(trueCcIdx);
        
        % compare number of circles detected and modify sensitivity
        % accordingly to redetect
        numDetected = length(radii)
        if numDetected == numberOfCircles
            centers = centers(trueCcIdx, :);
            finished = 1;
        elseif numDetected > numberOfCircles
            sensitivity = min(sensitivity*(1-gain),1);
            fprintf('decreased sensitivity to %f\n', sensitivity)
        elseif numDetected < numberOfCircles
            sensitivity = min(sensitivity*(1+gain),1);
            fprintf('increased sensitivity to %f\n', sensitivity)
        end
        gain = gain*0.9; % taking smaller steps towards ideal value
    end
    fprintf('Final sensitivity is: %f\n', sensitivity)
    
    % visualise result
    if visualiser == 1
        imshow(image)
        viscircles(centers, radii)
    end
end