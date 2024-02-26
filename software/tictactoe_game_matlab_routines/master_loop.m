%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Master loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Circle = Player 1
% Cross = Player 2

timeStamp = strrep(datestr(datetime), ':', '_');
folderName = strcat('C:\Users\Localadmin\Desktop\tictactoe\from_microscope\',timeStamp); % Microscopy image folder

%% Initialization

% MAKE MICROSCOPY FOLDER
mkdir(folderName);

% CONFIGURATION PARAMETERS
config = config_routine(folderName,'real');

% INITIALIZE DMD
dmd = DMD;
dmd.definePattern;
dmd.setMode(3);
dmd.display(config.blackImage); % Start with a black image (projection)

% XYZ LOCATIONS OF 9 ARENA SQUARES
xyzPositions = [-51106.30, 5190.50, 3937.98;
    -48470.40, 7805.80, 3944.10;
    -14357.00, 6278.20, 3982.64;
    -14701.60, 11929.20, 3974.62;
    -17797.60, 9759.10, 3978.50;
    23528.10, 8315.00, 3953.04;
    20674.60, 7203.00, 3958.96;
    19556.10, 11032.60, 3958.96;
    -34887.20, -26924.10, 3918.62];
numPositions = size(xyzPositions,1); % 9

% INITIAL MICROSCOPE-CONFIGURATION
microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('0');    % Projection layer shutter closed

% INITIALIZE GAME (A = CIRCLE, B = CROSS)
A = tictactoe(1,config.circlePlayerSkill);
B = tictactoe(2,config.crossPlayerSkill);
boardToImagePositionMap = [1:9];
emptyPositions = [1:9];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% KEEP PROJECTING FOR 5 HOURS
for k=1:5
%    microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).setValue(num2str(xyzPositions(config.sampleNum,3)));    
%    pause(0.1);
%    project_image(config, whichPlayer, microscope, dmd);
    pause(3600);
end
config.sampleNum = 10; % Set for the loop (starting from step 1)
%%

% Step 0: Take images (config.sampleNum is initialized with 0)
project_black_image(config, microscope, dmd);
for posIndx = 1:numPositions
    go_to_position(config, posIndx, xyzPositions, microscope);
    capture_images(config, posIndx, microscope);
    pause(0.5);
end
config.sampleNum = 1; % Set for the loop (starting from step 1)

% First move (always a circle = 1)
[squareNum, whichPlayer] = A.makeYourMove(0);
[boardToImagePositionMap] = check_mapping_and_shuffle(config, boardToImagePositionMap, squareNum);

% Go to the played position and start projection
go_to_position(config, config.sampleNum, xyzPositions, microscope);
project_image(config, whichPlayer, microscope, dmd);

% Capture projection and brightfield image
capture_projection(config, config.sampleNum, microscope);

% KEEP PROJECTING FOR 5 HOURS: TODO
for k=1:5
    microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).setValue(num2str(xyzPositions(config.sampleNum,3)));    
    pause(0.1);
    project_image(config, whichPlayer, microscope, dmd);
    pause(3600);
end

% After 5 hours: Take images
project_black_image(config, microscope, dmd);
for posIndx = 1:numPositions
    go_to_position(config, posIndx, xyzPositions, microscope);
    capture_images(config, posIndx, microscope);
    pause(0.5);
end

% Find out where it was played
playerMoveA = 0;
playerMoveB = 0;
for i=emptyPositions
    if check_square_if_played(config,i) > 0
        playerMoveA = boardToImagePositionMap(i);
        justPlayedPosition = i;
        break;
    end
end
prevMove = playerMoveA;
emptyPositions(find(emptyPositions==justPlayedPosition)) = [];

% Save stuff
[whoWon,WinningSquares] = A.checkForWin;
config.someoneWon = whoWon;
save(fullfile(config.imageFileLocation, strcat('variables_', num2str(config.sampleNum, '%04d' ), '.mat')), ...
    'boardToImagePositionMap', 'A', 'B', 'whoWon', 'WinningSquares', 'playerMoveA', 'playerMoveB', 'squareNum', ...
    'config', 'whichPlayer', 'WinningSquares', 'emptyPositions');

%% MAIN LOOP
config.sampleNum = config.sampleNum + 1;

while config.sampleNum<10 && config.someoneWon==0 % Stopping criteria
    
    if rem(config.sampleNum,2)==0 % B plays (Cross)

        [squareNum, whichPlayer] = B.makeYourMove(prevMove);
        [boardToImagePositionMap] = check_mapping_and_shuffle(config, boardToImagePositionMap, squareNum);
        
        % Go to the played position and start projection
        go_to_position(config, config.sampleNum, xyzPositions, microscope);
        project_image(config, whichPlayer, microscope, dmd);
        
        % Capture projection and brightfield image
        capture_projection(config, config.sampleNum, microscope);
        
        % KEEP PROJECTING FOR 5 HOURS: TODO
        for k=1:5
            microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).setValue(num2str(xyzPositions(config.sampleNum,3)));    
            pause(0.1);
            project_image(config, whichPlayer, microscope, dmd);
            pause(3600);
        end

        % After 5 hours: Take images
        project_black_image(config, microscope, dmd);
        for posIndx = 1:numPositions
            go_to_position(config, posIndx, xyzPositions, microscope);
            capture_images(config, posIndx, microscope);
            pause(0.5);
        end
        
        % Find out where it was played
        playerMoveA = 0;
        playerMoveB = 0;
        for i=emptyPositions
            if check_square_if_played(config,i) > 0
                playerMoveB = boardToImagePositionMap(i);
                justPlayedPosition = i;
                break;
            end
        end
        prevMove = playerMoveB;
        emptyPositions(find(emptyPositions==justPlayedPosition)) = [];
                
        % Save stuff
        [whoWon,WinningSquares] = B.checkForWin;
        config.someoneWon = whoWon;
        save(fullfile(config.imageFileLocation, strcat('variables_', num2str(config.sampleNum, '%04d' ), '.mat')), ...
            'boardToImagePositionMap', 'A', 'B', 'whoWon', 'WinningSquares', 'playerMoveA', 'playerMoveB', 'squareNum', ...
            'config', 'whichPlayer', 'WinningSquares', 'emptyPositions');        
        
    else % A plays (Circle)
        
        [squareNum, whichPlayer] = A.makeYourMove(prevMove);
        [boardToImagePositionMap] = check_mapping_and_shuffle(config, boardToImagePositionMap, squareNum);
        
        % Go to the played position and start projection
        go_to_position(config, config.sampleNum, xyzPositions, microscope);
        project_image(config, whichPlayer, microscope, dmd);
        
        % Capture projection and brightfield image
        capture_projection(config, config.sampleNum, microscope);
        
        % KEEP PROJECTING FOR 5 HOURS: TODO
        for k=1:5
            microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).setValue(num2str(xyzPositions(config.sampleNum,3)));    
            pause(0.1);
            project_image(config, whichPlayer, microscope, dmd);
            pause(3600);
        end
        
        % After 5 hours: Take images
        project_black_image(config, microscope, dmd);
        for posIndx = 1:numPositions
            go_to_position(config, posIndx, xyzPositions, microscope);
            capture_images(config, posIndx, microscope);
            pause(0.5);
        end
        
        % Find out where it was played
        playerMoveA = 0;
        playerMoveB = 0;
        for i=emptyPositions
            if check_square_if_played(config,i) > 0
                playerMoveA = boardToImagePositionMap(i);
                justPlayedPosition = i;
                break;
            end
        end
        prevMove = playerMoveA;
        emptyPositions(find(emptyPositions==justPlayedPosition)) = [];
               
        % Save stuff
        [whoWon,WinningSquares] = A.checkForWin;
        config.someoneWon = whoWon;
        save(fullfile(config.imageFileLocation, strcat('variables_', num2str(config.sampleNum, '%04d' ), '.mat')), ...
            'boardToImagePositionMap', 'A', 'B', 'whoWon', 'WinningSquares', 'playerMoveA', 'playerMoveB', 'squareNum', ...
            'config', 'whichPlayer', 'WinningSquares', 'emptyPositions');
        
    end
    
    config.sampleNum = config.sampleNum + 1;

end

%% For the final image
% KEEP PROJECTING BLACK IMAGE FOR 5 HOURS
for k=1:5
    microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).setValue(num2str(xyzPositions(config.sampleNum,3)));    
    pause(0.1);
    project_black_image(config, microscope, dmd);
    pause(3600);
end

% CAPTURE FINAL IMAGES OF THE GAME BOARD
project_black_image(config, microscope, dmd);
for posIndx = 1:numPositions
    go_to_position(config, posIndx, xyzPositions, microscope);
    capture_images(config, posIndx, microscope);
    pause(0.5);
end

        