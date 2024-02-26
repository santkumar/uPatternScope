function [outMap] = check_mapping_and_shuffle(config, boardToImagePositionMap, squareNum)

% Check mapping and shuffle if needed
if squareNum==config.sampleNum
    boardToImagePositionMap = boardToImagePositionMap;
elseif squareNum>config.sampleNum   
    boardToImagePositionMap([config.sampleNum squareNum]) = boardToImagePositionMap([squareNum config.sampleNum]);
else 
    temp = find(boardToImagePositionMap==squareNum);
    if temp==config.sampleNum
        boardToImagePositionMap = boardToImagePositionMap;
    else
        boardToImagePositionMap([config.sampleNum temp]) = boardToImagePositionMap([temp config.sampleNum]);
    end
end

outMap = boardToImagePositionMap;

end
