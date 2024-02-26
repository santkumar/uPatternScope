classdef tracking
    
    properties
        fArea
        fDisp
        fEccentricity
        eg
        penalty
        drift
        maxJump
    end % properties
    
    methods
        
        % Constructor
        function thisClass = tracking(thisClass)
            thisClass.fArea = 0.5e4;
            thisClass.fDisp = 2;
            thisClass.fEccentricity = 0;
            thisClass.eg = 0.03;
            thisClass.penalty = 2e3;
            thisClass.drift = 1;
            thisClass.maxJump = 4;
        end
        
        % Generate a concatenated file from the Cellx (segmentation) output results
        function [outStruct] = concatenateFrames(thisClass, startFrame, endFrame, config, microscopyResultsFolder)
            
            % Get segmented cells corresponding to start frame            
            fileName = [microscopyResultsFolder, filesep, config.imNames.segImPrefix, ...
                    config.imNames.segImZ, config.imNames.segImT, num2str(startFrame, '%06d'), ...
                    config.imNames.segDataExtension];    
            segDataTable = readtable(fileName);
            segData = table2array(segDataTable(:,3:10));
            numCells = size(segData,1);
            centroidX = segData(:,3);
            centroidY = segData(:,4);
            area = segData(:,5);
            eccentricity = segData(:,6);
            
            % Construct the output Struct
            outStruct = struct('cellframe', startFrame*ones(numCells,1), ...
                'cellindex', [1:numCells]', ...
                'cellcenterx', centroidX, ...
                'cellcentery', centroidY,...
                'celleccentricity', eccentricity,...
                'cellarea', area);
            
            % Loop over all .mat files (containing segmented cells information) from the cellx output
            fmNum = startFrame + 1;
            while fmNum <= endFrame
                
                % Get segmented cells correspomdomg to next frame
                fileName = [microscopyResultsFolder, filesep, config.imNames.segImPrefix, ...
                    config.imNames.segImZ, config.imNames.segImT, num2str(fmNum, '%06d'), config.imNames.segDataExtension];    
                segDataTable = readtable(fileName);
                segData = table2array(segDataTable(:,3:10));
                numCells = size(segData,1);
                centroidX = segData(:,3);
                centroidY = segData(:,4);
                area = segData(:,5);
                eccentricity = segData(:,6);

                s = struct('cellframe', fmNum*ones(numCells,1), ...
                    'cellindex', [1:numCells]', ...
                    'cellcenterx', centroidX, ...
                    'cellcentery', centroidY,...
                    'celleccentricity', eccentricity,...
                    'cellarea', area);
                
                % Concatenate
                myNames = fieldnames(outStruct);
                for i = 1:numel(myNames)
                    outStruct.(myNames{i})=[outStruct.(myNames{i}); s.(myNames{i})];
                end
                
                fmNum = fmNum+1;
                
            end
            
        end
        
        function s = addTrackIndex(thisClass, s)
            
            % Initializations
            firstFrameNum = 90;
            numCellsFirstFm = length(find(s.cellframe==firstFrameNum));     % Number of segmented cells in first frame
            s.trackindex = NaN(length(s.cellframe),1);
            s.cost = NaN(length(s.cellframe),1);
            s.cost1 = NaN(length(s.cellframe),1);
            s.cost2 = NaN(length(s.cellframe),1);
            s.cost3 = NaN(length(s.cellframe),1);
            s.cost4 = NaN(length(s.cellframe),1);
            s.trackindex(1:numCellsFirstFm) = 1:numCellsFirstFm;            % Normal integer index for all the segmented cells of first frame
            s.cost(1:numCellsFirstFm) = 0;
            s.cost1(1:numCellsFirstFm) = 0;
            s.cost2(1:numCellsFirstFm) = 0;
            s.cost3(1:numCellsFirstFm) = 0;
            s.cost4(1:numCellsFirstFm) = 0;
            oldFrame= struct('age', ones(numCellsFirstFm,1), ...
                'trackindex', [1:numCellsFirstFm]', ...
                'dif_x', zeros(numCellsFirstFm,1), ...
                'dif_y', zeros(numCellsFirstFm,1),...
                'cellcenterx', s.cellcenterx(s.cellframe==firstFrameNum), ...
                'cellcentery', s.cellcentery(s.cellframe==firstFrameNum), ...
                'cellarea', s.cellarea(s.cellframe==firstFrameNum), ...
                'celleccentricity', s.celleccentricity(s.cellframe==firstFrameNum));
            
            % Tracking
            numberOfTracks = numCellsFirstFm;
            distinctFrames = unique(s.cellframe);
            distinctFrames(1) = []; % Removing first frame
            numDistinctFrames = length(distinctFrames);
            indx = 1;
            while indx <= numDistinctFrames
                
                fmNum = distinctFrames(indx);
                
                tic;
                newFrame = struct('cellcenterx', s.cellcenterx(s.cellframe==fmNum), ...
                    'cellcentery', s.cellcentery(s.cellframe==fmNum), ...
                    'cellarea', s.cellarea(s.cellframe==fmNum), ...
                    'celleccentricity', s.celleccentricity(s.cellframe==fmNum));
                
                % Get assignment cost matrix A (Rows : old frame, Columns : new frame)
                [A, A1, A2, A3, A4] = thisClass.getAssignmentCostMatrix(newFrame, oldFrame);
                
                % Get assignment from Jonker-Volgenant Algorithm
                assignment = lapjv(A);  % 'assignment' is (number of old cells) long vector
                % assignment(i) = index of the new cell assigned to the old cell 'i'
                toc;
                
                tic;
                numOldCells = length(oldFrame.cellarea);
                numNewCells = length(newFrame.cellarea);
                x = ismember(assignment,1:numNewCells);
                x_x = find(x==1);       % All old cell indices which could find an assignment in new cells.
                
                % B = A;
                cost = NaN(numNewCells,1);
                cost1 = NaN(numNewCells,1);
                cost2 = NaN(numNewCells,1);
                cost3 = NaN(numNewCells,1);
                cost4 = NaN(numNewCells,1);
                for i=1:numOldCells
                    j = assignment(i);
                    cost(j)= A(i,j);
                    %     B(i,j)= inf;
                    cost1(j)= A1(i,j);
                    cost2(j)= A2(i,j);
                    cost3(j)= A3(i,j);
                    cost4(j)= A4(i,j);
                end
                
                % Keep old tracks which could not be assigned (not segmented or cost was too high)
                veryOldUnassigned = oldFrame;
                sNames = fieldnames(oldFrame);
                loop1=1;
                while loop1 <= numel(sNames)
                    loop2 = numel(x_x);
                    while loop2 > 0
                        veryOldUnassigned.(sNames{loop1})(x_x(loop2)) = [];   % Removing those entries which have been assigned (the leftover is what we want here)
                        loop2 = loop2 - 1;
                    end
                    loop1 = loop1 + 1;
                end
                
                % Remove too-old old tracks
                tooOld = (find(veryOldUnassigned.age > thisClass.maxJump));
                loop1 = 1;
                while loop1 <= numel(sNames)
                    loop2 = numel(tooOld);
                    while loop2 > 0
                        veryOldUnassigned.(sNames{loop1})(tooOld(loop2)) = []; % Removing those entries which are too old
                        loop2 = loop2 - 1;
                    end
                    loop1 = loop1 + 1;
                end
                
                % Displacement between tracked cells (from oldFrame to
                % newFrame) stored but not used right now
                y_y = assignment(x_x);   % 'y_y' = new cell indices which have a corresponding assignment in old cells 'x_x'
                diffX = zeros(numNewCells,1);
                diffY = zeros(numNewCells,1);
                diffX(y_y) = (newFrame.cellcenterx(y_y) - oldFrame.cellcenterx(x_x))./oldFrame.age(x_x);
                diffY(y_y) = (newFrame.cellcentery(y_y) - oldFrame.cellcentery(x_x))./oldFrame.age(x_x);
                
                veryOldUnassigned.age = veryOldUnassigned.age + 1;
                
                newTrackIndex = zeros(numNewCells,1);
                newTrackIndex(y_y) = oldFrame.trackindex(x_x);
                
                % Those new frame cells which could not find any assignment in old frame cells
                where = find(newTrackIndex==0);
                add = length(where);
                newTrackIndex(where) = (numberOfTracks + 1):(numberOfTracks + add); % Those new frame cells which didn't find assignment in old frame cells are
                % considered as new cells being added to the pool of cells being tracked
                % represented by additional indices (we are not rejecting them)
                
                % Assign new trackindex
                s.trackindex(s.cellframe==fmNum) = newTrackIndex;
                numberOfTracks = numberOfTracks + add;
                
                % Assign costs
                s.cost(s.cellframe==fmNum) = cost(1:numNewCells);
                s.cost1(s.cellframe==fmNum) = cost1(1:numNewCells);
                s.cost2(s.cellframe==fmNum) = cost2(1:numNewCells);
                s.cost3(s.cellframe==fmNum) = cost3(1:numNewCells);
                s.cost4(s.cellframe==fmNum) = cost4(1:numNewCells);
                
                % Prepare oldFrame for next iteration
                oldFrame.age = [ones(numNewCells,1); veryOldUnassigned.age];
                oldFrame.trackindex = [newTrackIndex; veryOldUnassigned.trackindex];
                oldFrame.dif_x = [diffX; veryOldUnassigned.dif_x];
                oldFrame.dif_y = [diffY; veryOldUnassigned.dif_y];
                oldFrame.cellcenterx = [newFrame.cellcenterx; veryOldUnassigned.cellcenterx];
                oldFrame.cellcentery = [newFrame.cellcentery; veryOldUnassigned.cellcentery];
                oldFrame.cellarea = [newFrame.cellarea; veryOldUnassigned.cellarea];
                oldFrame.celleccentricity = [newFrame.celleccentricity; veryOldUnassigned.celleccentricity];
                indx = indx +1;
                toc;
                
                disp(indx);
                
            end
            
        end
        
        % Calculate the individual costs and generate assignment cost matrix
        % The penalty for age is hard coded.
        function [A, A1, A2, A3, A4] = getAssignmentCostMatrix(thisClass, newFrame, oldFrame)
            
            thisClass.penalty = thisClass.penalty/4;    % average of 4 factors (as 4 costs added)
            dimRow = length(oldFrame.cellarea);         % number of cells in old frame
            dimColumn = length(newFrame.cellarea);      % number of cells in new frame
            
            % Calculation of x - y pixel position with the added drift; in other words
            % we calculate the expected position in the new frame based on the position
            % in the old frame
            distanceX = repmat(oldFrame.cellcenterx + thisClass.drift*oldFrame.age.*oldFrame.dif_x,1,dimColumn) - ...
                repmat(newFrame.cellcenterx.',dimRow,1);
            distanceY = repmat(oldFrame.cellcentery + thisClass.drift*oldFrame.age.*oldFrame.dif_y,1,dimColumn) - ...
                repmat(newFrame.cellcentery.',dimRow,1);
            
            % Area
            relArea = repmat(newFrame.cellarea.',dimRow,1)./repmat(oldFrame.cellarea,1,dimColumn);
            
            % Calcualte the difference in cell eccentricity
            diffeccentricity = repmat(oldFrame.celleccentricity,1,dimColumn) - repmat(newFrame.celleccentricity.',dimRow,1);
            
            % CALCULATION OF DIFFERENT PENALTIES (COST)
            
            % Calculation of the x - y displacement penalty on the predicted position
            A1 = thisClass.fDisp*(distanceX.^2 + distanceY.^2);
            A1 = [A1 repmat(thisClass.penalty,dimRow)];
            
            % Penalty on area
            A2 = thisClass.fArea*((log(relArea)-thisClass.eg).^2);
            %A2(youngCells) = A2(youngCells)/100;
            A2 = [A2 repmat(thisClass.penalty,dimRow)];
            
            % Function as before
            A3 = thisClass.fEccentricity*(diffeccentricity.^2);
            A3 = [A3 repmat(thisClass.penalty,dimRow)];
            
            % Penalty for frame skipping - 200 per skipped frame
            A4 = 200*repmat(oldFrame.age-1,1,dimColumn);
            A4 = [A4 repmat(thisClass.penalty,dimRow)];
            
            A = A1 + A2 + A3 + A4;
            
        end        
        
    end % methods
    
end