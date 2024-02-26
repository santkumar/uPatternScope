
frameNumber = 90;

segImage = imread('<< PATH TO THE CORRESPONDING FRAME NUMBER IMAGE >>');

cellPosition = [trackedFmStruct.cellcenterx(trackedFmStruct.cellframe==frameNumber) ...
    trackedFmStruct.cellcentery(trackedFmStruct.cellframe==frameNumber)];

cellTrackIndex = trackedFmStruct.trackindex(trackedFmStruct.cellframe==frameNumber);

temp = insertText(segImage,cellPosition,cellTrackIndex,'AnchorPoint','Center','FontSize',12,'BoxColor',...
    'w','BoxOpacity',0,'TextColor',[220 0 0]);

imwrite(temp,['<< PATH TO A DIRECTORY TO STORE INDEXED IMAGES >>' num2str(frameNumber, '%04d') '.tif']);

imshow(temp,[]);