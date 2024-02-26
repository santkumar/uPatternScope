classdef circle
    properties
        center % [x,y]
        radius
    end
    methods
        function this = circle(center, radius)
            if nargin > 0
                if length(center) ~= 2
                    error('Error. \nPlease specify the circle center in [x,y] format!');
                end
                this.center = center;
                this.radius = radius;
            end
        end
        
        
        function circlePixel = getCirclePixel(this)
        % This function returns a logical matrix representing the image for a single circle as specified by the circle radius.
        % circlePixel size is (2*this.radius+1) x (2*this.radius+1).
            [x,y] = meshgrid(-round(this.radius):round(this.radius));
            circlePixel = sqrt(x.^2+y.^2)<=this.radius;
        end
        
    end
end