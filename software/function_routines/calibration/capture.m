classdef capture
    properties
        rawImage
        rawSize % ([x,y]
        rawCenter
        radiusRange
        scaleRatio % projectionDim/captureDim
        scaledImage
        scaledSize
        centersGrid
        radiiGrid
        coloredImage
        BWImage
    end
    
    methods
        function this = capture(imageCaptured, radiusRange)
        % constructor
            this.rawImage = imageCaptured;
            this.rawSize = flip(size(imageCaptured)); % TODO!!!!
            this.rawCenter = this.rawSize/2;
            this.radiusRange = radiusRange;
        end
        
        function this = setGrids(this, centers, radii, gridSize) % centers in (x,y) format.
        % This function sets the centersGrid and radiiGrid, which aligns with the location of centers.
            import circle
            rows = gridSize(2);
            cols = gridSize(1);
            totNum = rows*cols;
            if totNum ~= length(radii)
                error('Error. \nThe number of circles detected in the image does not match given grid size.');
            end
            
            % re-sequence the circles found and build the cent grid
            xMin = min(centers(:,1));
            xMax = max(centers(:,1));
            averageXSpacing = (xMax-xMin) / (gridSize(1)-1);
            xSegment = ((xMin - averageXSpacing/2) : averageXSpacing : (xMax + averageXSpacing/2));
            
            yMin = min(centers(:,2));
            yMax = max(centers(:,2));
            averageYSpacing = (yMax-yMin) / (gridSize(2)-1);
            ySegment = ((yMin - averageYSpacing/2) : averageYSpacing : (yMax + averageYSpacing/2));
            
            captureCentersGrid = zeros(rows, cols, 2);
            captureRadiiGrid = zeros(rows, cols);
            for i = 1:totNum
                [rowIndex, colIndex] = getGridIndex(centers(i, :), xSegment, ySegment);
                captureCentersGrid(rowIndex, colIndex, :) = centers(i, :);
                captureRadiiGrid(rowIndex, colIndex) = radii(i);
            end
            
            this.centersGrid = captureCentersGrid;
            this.radiiGrid = captureRadiiGrid;
        end
        
        function this = scaleImage(this, projection)
        % This function scales the captured image to fit into the smaller dimension of projection image.
        % Note: center grid will be scaled as well!
            this.scaleRatio = min(projection.imageSize)/max(this.rawSize);
            this.scaledImage = imresize(this.rawImage, this.scaleRatio); 
            this.scaledSize = flip(size(this.scaledImage));
            this.centersGrid = this.centersGrid * this.scaleRatio;
        end
        
        function this = getColoredImage(this, color, centersArr, radiiArr)
            import circle
            % initialize the RGB projection image to all zeros
            colorMasked = zeros(this.rawSize(2), this.rawSize(1), 3); % real rgb image matrix
            circlePixels = zeros(this.rawSize(2), this.rawSize(1)); % logical image matrix
            
            % draw circles based on circles found
            for i = 1:length(radiiArr)
                thisCircle = circle(centersArr(i,:), radiiArr(i));
                thisCirclePixel = thisCircle.getCirclePixel();
                yInt = round(thisCircle.center(2));
                xInt = round(thisCircle.center(1));
                radiusInt = round(thisCircle.radius);
                circlePixels((yInt-radiusInt):(yInt+radiusInt), (xInt-radiusInt):(xInt+radiusInt)) = thisCirclePixel;
            end
            circlePixels = logical(circlePixels);
            
            % adding color to circles
            for i = 1:3
               if color(i)>0
                   colorLayer = colorMasked(:, :, i);
                   colorLayer(circlePixels) = color(i);
                   colorMasked(:, :, i) = colorLayer;
                end
            end

            % scale the image
            this.coloredImage = imresize(colorMasked, this.scaleRatio);
        end
        
        function this = getBWImage(this, centersArr, radiiArr)
            import circle
            bwMasked = zeros(this.rawSize(2), this.rawSize(1)); % black and white image matrix
            circlePixels = zeros(this.rawSize(2), this.rawSize(1)); % logical image matrix
       
            for i = 1:length(radiiArr)
                thisCircle = circle(centersArr(i,:), radiiArr(i));
                thisCirclePixel = thisCircle.getCirclePixel();
                yInt = round(thisCircle.center(2));
                xInt = round(thisCircle.center(1));
                radiusInt = round(thisCircle.radius);
                circlePixels((yInt-radiusInt):(yInt+radiusInt), (xInt-radiusInt):(xInt+radiusInt)) = thisCirclePixel;
            end
            circlePixels = logical(circlePixels);
            
            bwMasked(circlePixels) = 255;
            this.BWImage = imresize(bwMasked, this.scaleRatio);
        end
    end
end