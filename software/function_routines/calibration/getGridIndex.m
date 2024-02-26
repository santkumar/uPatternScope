function [rowIndex, colIndex] = getGridIndex(center, xSegment, ySegment)
        % This function returns the Index of a circle in a circle grid
          x = center(1);
          y = center(2);
          
          for i = 1:(length(xSegment)-1)
             if xSegment(i)<=x && xSegment(i+1)>x
                colIndex = i;
             end
          end
          
          for j = 1:(length(ySegment)-1)
            if ySegment(j)<=y && ySegment(j+1)>y
                rowIndex = j;
            end
          end

          % check if got the indices
          if ~colIndex
            error('Error. \nCannot match the column index in circle grid for the circle centered at %f.', center);
          end
          
          if ~rowIndex
            error('Error. \nCannot match the row index in circle grid for the circle centered at %f.', center);
          end
          
end