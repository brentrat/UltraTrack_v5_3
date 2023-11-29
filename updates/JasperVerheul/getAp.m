%% ------------------------------------------------------------------------
function [apoLine apoROI] = getAp(handles, filteredImage, searcharea)
% -------------------------------------------------------------------------
% This function detects the aponeurosis of interest within a predefined
% search area (see getSettings.m). 
% 
% The open-source Hessian-based Frangi vesselness filtering functions used 
% in this function were developed by Dirk-Jan Kroon. 
% (https://uk.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-
% frangi-vesselness-filter).
% 
% Input:            - handles: predefined handles structure.
%                   - filteredImage: Frangi filtered ultrasound image.
%                   - searcharea: predefined area of interest (see 
%                     getSettings.m) to search for aponeurosis locations.
%
% Output:           - apoLine: location of the detected aponeurosis line.      
% 	                - apoROI: region of interest of the detected 
%                     aponeurosis.
% -------------------------------------------------------------------------

apoSearch = 1;

for apoSearchRep = 1:3
    if apoSearch == 1
        %% Get aponeurosis region of interest
        apoROI.searcharea   = round(searcharea(1) : searcharea(end));
        apoROI.filtered     = filteredImage(apoROI.searcharea,:);
        apoROI.filtered     = bwpropfilt(apoROI.filtered, 'Perimeter', 1);
        
        apoROI.properties   = regionprops(apoROI.filtered, 'Orientation', 'MinorAxisLength', 'MajorAxisLength', 'Centroid');
        apoROI.properties.Centroid(1,2) ...
                            = apoROI.properties.Centroid(1,2) + apoROI.searcharea(1);
        
        apoROI.boundary     = bwboundaries(apoROI.filtered);
        apoROI.boundary     = flip(apoROI.boundary{1}, 2); % flip to get [x y]
        apoROI.boundary     = apoROI.boundary + [0 apoROI.searcharea(1)];
        
        %% Get aponeurosis line
        % define matrix for line to rotate
        initialApoLine = [1:handles.vidWidth; repmat(apoROI.properties.Centroid(2), 1, handles.vidWidth)];
        
        % define centre of rotation matrix
        rotationCentre = repmat([apoROI.properties.Centroid(1); apoROI.properties.Centroid(2)], 1, handles.vidWidth);
        
        % define counter-clockwise rotation matrix using the line orientation
        apoROI.properties.Orientation = -1 * apoROI.properties.Orientation;
        theta = apoROI.properties.Orientation;
        rotationMatrix = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
        
        % rotate line
        rotatedLine = rotationMatrix*(initialApoLine - rotationCentre) + rotationCentre;
        apoLine = [rotatedLine(1,1) rotatedLine(2,1); rotatedLine(1,end) rotatedLine(2,end)];
        
        % crop ROI boundaries to fall within 1 mm from aponeurosis line
        apoBoundaryLimits = [ apoLine(1,1) - (1/handles.ID)     apoLine(1,2) - (1/handles.ID); ...
            apoLine(2,1) + (1/handles.ID)     apoLine(2,2) - (1/handles.ID); ...
            apoLine(2,1) + (1/handles.ID)     apoLine(2,2) + (1/handles.ID); ...
            apoLine(1,1) - (1/handles.ID)     apoLine(1,2) + (1/handles.ID)];
        inApoBoundaryLimits = inpolygon(apoROI.boundary(:,1),apoROI.boundary(:,2), apoBoundaryLimits(:,1), apoBoundaryLimits(:,2));
        
        % Set new boundary and repeat if not within limits
        if sum(inApoBoundaryLimits) == size(apoROI.boundary,1)   ||   apoSearchRep == 3
            apoSearch = 0;
        end
        apoROI.boundary = apoROI.boundary(inApoBoundaryLimits,:);
        searcharea = [max(min(apoROI.boundary(:,2))-(1/handles.ID), 1), max(apoROI.boundary(:,2))+(1/handles.ID)];
    end
end