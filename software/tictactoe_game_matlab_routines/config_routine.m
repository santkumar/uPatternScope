classdef config_routine < handle
    %% Class to access and set all configurations and parameters
    
    properties
        deviceFilterBlockFluo
        deviceFilterBlockProj
        propertyFilterBlock
        deviceShutterFluo
        deviceShutterProj
        propertyShutter
        deviceZDrive
        propertyZDrive
        imageFileLocation
        sampleNum
        blackImage
        circleProjectionImage
        crossProjectionImage
        circlePlayerSkill
        crossPlayerSkill
        mode
        imaging
        threshold
        someoneWon
    end % properties
    
    methods
        
        function thisClass = config_routine(folderName,mode)  % Constructor
            if nargin < 2
                mode = 'real';
                if nargin < 1
                    error('correct syntax: config_routine(folderName,mode)');
                end
            end
            
            if strcmp(mode,'test')
                error('test mode selected!');
            elseif ~strcmp(mode,'real') && ~strcmp(mode,'test')
                error('unrecognized mode');
            end            
            
            thisClass.deviceFilterBlockFluo = 'FilterTurret1';
            thisClass.deviceFilterBlockProj = 'FilterTurret2';
            thisClass.propertyFilterBlock = 'State';
            thisClass.deviceShutterFluo = 'Turret1Shutter';
            thisClass.deviceShutterProj = 'Turret2Shutter';
            thisClass.propertyShutter = 'State';
            thisClass.deviceZDrive = 'ZDrive';
            thisClass.propertyZDrive = 'Position';
            thisClass.imageFileLocation = folderName;
            thisClass.sampleNum = 0;
            thisClass.blackImage = zeros(1080,1920);            
            projImages = load([pwd filesep 'to_project' filesep 'proj_data.mat']);
            thisClass.circleProjectionImage = projImages.correctedCircle;
            thisClass.crossProjectionImage = projImages.correctedCross;
            thisClass.circlePlayerSkill = 3;
            thisClass.crossPlayerSkill = 3;            
            thisClass.mode = mode;

            thisClass.imaging.types = {'brightfield','CFP','GFP'};
            thisClass.imaging.groups = {'Channels','Trigger','Trigger'};
            thisClass.imaging.exposure = {50, 300, 300};
            thisClass.imaging.zOffsets = {[-14 14 0], [0], [0]};

            thisClass.threshold.deadOrAlive = 800;
            thisClass.threshold.playedOrNot = 500;
            thisClass.threshold.circleOrCross = 1500;
            
            thisClass.someoneWon = 0;
        end
                
    end % methods
    
end % config
