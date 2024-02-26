classdef config_imageNames
    
    properties
        
        segImPrefix
        segImT
        segImZ
        segImExtension
        
        segDataExtension
        
        fluoImPrefix
        fluoImExtension
        fluoImT
        fluoImZ
                
        phaseImPrefix
        phaseImExtension
        
    end % properties
    
    methods
        
        function thisClass = config_imageNames(thisClass)
            thisClass.segImPrefix = 'seg';
            thisClass.segImT = '_time';
            thisClass.segImZ = '_position000000';
            thisClass.segImExtension = '.tif';
            
            thisClass.segDataExtension = '.csv'
            
            thisClass.fluoImPrefix = 'Ph';
            thisClass.fluoImExtension = '.tif';
            thisClass.fluoImT = '_time';
            thisClass.fluoImZ = '_position000000';            
            
            thisClass.phaseImPrefix = '20_phase3_z1_t';
            thisClass.phaseImExtension = '.tif';
        end
        
        function [imPath] = getImPath(thisClass, fmNum, dirImM)
            imPath.seg = [dirImM, filesep, thisClass.segImPrefix, thisClass.segImZ, thisClass.segImT, num2str(fmNum, '%06d'), thisClass.segImExtension];
            imPath.segDataFileName = [dirImM, filesep, thisClass.segImPrefix, thisClass.segImZ, thisClass.segImT, num2str(fmNum, '%06d'), thisClass.segDataExtension];    
            imPath.fluo = [dirImM, filesep, thisClass.fluoImPrefix, thisClass.fluoImZ, thisClass.fluoImT, num2str(fmNum, '%06d'), thisClass.fluoImExtension];
            imPath.phase = [dirImM, filesep, thisClass.phaseImPrefix, num2str(fmNum, '%06d'), thisClass.phaseImExtension];
        end
        
        function [allFiles] = getZStackImages(thisClass, dirIm, filesTemplate)
            imFilesStruct = dir(filesTemplate);
            numFiles = length(imFilesStruct);
            allFiles = cell(numFiles,1);
            for i=1:numFiles
                allFiles{i} = fullfile(dirIm,imFilesStruct(i).name);
            end
        end
        
        function [imMatrix] = cell2MatImages(thisClass, allImages)
            imMatrix = zeros(2048, 2048, length(allImages));
            for i=1:length(allImages)
                imMatrix(:,:,i) = imread(allImages{i});
            end
        end
        
        
    end % methods
    
end % classdef