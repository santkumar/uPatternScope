classdef projection
% coordinate convention: origin at top left corner. Positive x
% axis goes rightwards, and positive y axis goes downwards. This convention
% also agrees with the image default coordinate in matlab.
   
    properties
        imageSize
        imageCenter
        color
        circleRadius
        gridSize
        padding % [left, right, top, bottom]
        xSpacing
        ySpacing
        centersGrid
        image
    end
    
    methods
        
        % constructor
        function this = projection(imageSize, color, circleRadius, gridSize, padding)
            this.imageSize = imageSize; % [width(x), height(y)]
            this.imageCenter = imageSize/2; % (x,y)
            this.color = color; % circle color
            this.circleRadius = circleRadius;
            this.gridSize = gridSize; % (x, y)
            this.padding = padding; % [left, right, top, bottom]
            this.xSpacing = floor((imageSize(1)-padding(1)-padding(2)-gridSize(1))/(gridSize(1)+1));
            this.ySpacing = floor((imageSize(2)-padding(3)-padding(4)-gridSize(2))/(gridSize(2)+1));
            
            if this.xSpacing<2*circleRadius
                error('Error. \nNot enough spacing in x direction for drawing circles. Try to reduce number of circles in each row.');
            end
            if this.ySpacing<2*circleRadius
                error('Error. \nNot enough spacing in y direction for drawing circles. Try to reduce number of circles in each column.');
            end
            
            % set centersGrid and radiiGrid
             if this.gridSize ~= [0,0]
                cols = this.gridSize(1);
                rows = this.gridSize(2);
                projectionCentersGrid = zeros(rows, cols, 2);
                
                % set coordinates of circle centers, with imageCenter as the top left corner
                for col = 1:cols
                    for row = 1:rows
                        %%%%%%% TODO!
                        projectionCentersGrid(row, col, :) = [this.padding(1)+this.xSpacing*col+col, this.padding(3)+this.ySpacing*row+row];
                    end
                end
                this.centersGrid = projectionCentersGrid;
             end
        end
        
        
        function this = getProjectionImage(this)
            % initialize the RGB projection image to all zeros
            projectionImage = zeros(this.imageSize(2), this.imageSize(1)); % real image matrix
            projectionImagePixel = zeros(this.imageSize(2), this.imageSize(1)); % logical image matrix
            
            % draw circles
            import circle
            for row = 1:this.gridSize(2)
                for col = 1:this.gridSize(1)
                    cX = this.centersGrid(row,col,1);
                    cY = this.centersGrid(row,col,2);
                    R = this.circleRadius;
                    thisCircle = circle([cX, cY], this.circleRadius);
                    thisCPixel = thisCircle.getCirclePixel();
                    projectionImagePixel((cY-R):(cY+R), (cX-R):(cX+R)) = thisCPixel;
                end
            end
            projectionImagePixel = logical(projectionImagePixel);
            projectionImage(projectionImagePixel) = 255;
            
            % adding color to circles
%             for i = 1:3
%                 if this.color(i)>0
%                     colorLayer = projectionImage(:, :, i);
%                     colorLayer(projectionImagePixel) = this.color(i);
%                     projectionImage(:, :, i) = colorLayer;
%                 end
%             end
            %imshow(projectionImage)
            this.image = projectionImage;
        end
        
    end
end