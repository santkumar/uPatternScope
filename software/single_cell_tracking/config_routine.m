classdef config_routine
    %% Class to access and set all configurations and parameters
    
    properties
        fileNames           % All filepath and folder names
        imNames             % All image names and corresponding file path
        
    end % properties
    
    methods
        
        function thisClass = config_routine  % Constructor
            thisClass.fileNames = filenames;
            thisClass.imNames = config_imageNames;
        end
                                
        function [folder] = getMicroscopyDirectory(thisClass) % Get the directory where all microscopy results are stored
            allFolders = dir(thisClass.fileNames.microscopyAllOutputDirectory);
            folder = fullfile(thisClass.fileNames.microscopyAllOutputDirectory,allFolders(end).name);
        end        
        
    end % methods
    
end % config
