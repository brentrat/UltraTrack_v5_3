%% ------------------------------------------------------------------------
function houghLines = getHough(handles, fasROI, apo1ROI, apo2ROI, ii)
% -------------------------------------------------------------------------
% This function perfoms the Hough transform algorithm to detect Hough lines
% within the fascicle region of interest.
%
% Input:            - handles: predefined handles structure.
% 	                - fasROI: struct containing the location and pixels of
%                     the fascicle region of interest.
% 	                - apo1ROI: region of interest of the detected
%                     aponeurosis 1.
% 	                - apo2ROI: region of interest of the detected
%                     aponeurosis 2.
%
% Output:           - houghLines: struct containing the detected Hough
%                     lines within the fascicle region of interest.
% -------------------------------------------------------------------------

% Perform Hough transformation to determine Hough lines
[H,theta,rho] = hough(fasROI, 'Theta',-90:0.1:89);
P = houghpeaks(H, 50, 'Threshold', .5*max(H(:)));
houghLines.lines = houghlines(fasROI, theta, rho, P, 'FillGap',5, 'MinLength',.5 * (1/handles.ID)); % default FillGap=20 MinLength=40

% Delete Hough lines with 45 degree angle (due to bias towards diagonal)
houghLines.lines([houghLines.lines.theta]' == 45) = [];
houghLines.lines([houghLines.lines.theta]' == -45) = [];

% Correct Hough line angles to video frame
% (The Hough angle of the lines is theta+90°, measured clockwise with respect to the positive x-axis)
for lineIdx = 1:length(houghLines.lines)
    if houghLines.lines(lineIdx).theta > 0
        houghLines.lines(lineIdx).theta = houghLines.lines(lineIdx).theta - 90;
    elseif houghLines.lines(lineIdx).theta < 0
        houghLines.lines(lineIdx).theta = houghLines.lines(lineIdx).theta + 90;
    end
end

% Delete Hough line angles smaller/larger than set degrees
if ii == 1 
    houghLines.lines([houghLines.lines.theta]' < 8) = [];
    houghLines.lines([houghLines.lines.theta]' > 90) = [];
elseif ii == 2
     houghLines.lines([houghLines.lines.theta]' > 0) = [];
     houghLines.lines([houghLines.lines.theta]' < -90) = [];   
end

% Delete Hough line angles at superficial/central aponeurosis angles
houghLines.lines([houghLines.lines.theta]' == apo1ROI.properties.Orientation) = [];
houghLines.lines([houghLines.lines.theta]' == apo2ROI.properties.Orientation) = [];

if ~isempty(houghLines.lines)
    % Get Hough line angles and correct for:
    %   1) stretching of fascicle ROI
    %   2) pixel to mm ratio
    angles = [houghLines.lines.theta]';
    angles = atand( tand(angles) / 3 * 1);
    angles = atand( tand(angles) * ((1/handles.ID) / (1/handles.ID)) );
    angles = num2cell(angles);
    [houghLines.lines.angle] = angles{:};

    % Calculate Hough line lengths and occurences
    lengths = num2cell(sqrt( sum( (vertcat(houghLines.lines.point2) - vertcat(houghLines.lines.point1)) .^2, 2) ));
    occurences = num2cell( sum([houghLines.lines.theta]'==[houghLines.lines.theta])' );
    [houghLines.lines.length] = lengths{:};
    [houghLines.lines.occurences] = occurences{:};

else
    [houghLines.lines.length] = [];
    [houghLines.lines.occurences] = [];
    [houghLines.lines.angle] = [];

end