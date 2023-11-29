%% ------------------------------------------------------------------------
function [fasROI Hough] = detectFas(handles, fasROI, apo1, apo2, ii)
% -------------------------------------------------------------------------
% This function tracks the muscle by running a Hough transform and feature-
% point tracking algorithm on each image in the ultrasound video.
%
% The open-source Hessian-based Frangi vesselness filtering functions used
% in this function were developed by Dirk-Jan Kroon.
% (https://uk.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-
% frangi-vesselness-filter).
%
% Input:            - handles: predefined handles structure.
%                   - Ultrasound: ultrasound video under analysis.
%                   - fasROI: struct containing fascicle region of
%                     interest.
%                   - apo1: struct containing aponeurosis 1 location.
%                   - apo2: struct containing aponeurosis 2 location.
% Output:           - fasROI: struct containing fascicle region of
%                     interest.
%                   - apo1: struct containing aponeurosis 1 position and
%                     tracking results.
%                   - apo2: struct containing aponeurosis 2 position and
%                     tracking results.
%                   - Hough: struct containing Hough transform results.
% -------------------------------------------------------------------------

tic

for im = 1
    % -------------------------------------------------------------------------
    % Hough transform
    % -------------------------------------------------------------------------
    % Filter fascicle ROI with Frangi filter
    %     fasFrangiFilt      = struct('FrangiScaleRange', [1 2], 'FrangiScaleRatio', .2, ...
    %         'FrangiBetaOne', 0.5, 'FrangiBetaTwo', 15, ...
    %         'verbose',false,'BlackWhite',false); % Frangi filter settings for fascicle ROI

    %     fasROI(im).pixels  = FrangiFilter2D(fasROI(im).pixels, fasFrangiFilt);
    % Crop image
%     halfImage = round(size(fasROI(im).pixels,1)/2,0);
% 
%     if ii == 1
% 
%         rowMin = find(fasROI(im).pixels(1:halfImage,1)==0,1,'last');
%         rowMax = find(fasROI(im).pixels(halfImage:end,end)==0,1,'first');
%         rowMax = rowMax+halfImage-1;
%         fasROI(im).pixels = fasROI(im).pixels(rowMin:rowMax,:);
% 
%     else
% 
%         rowMin = find(fasROI(im).pixels(1:halfImage,1)==0,1,'last');
%         %rowMin = rowMin+(halfImage/2);
%         rowMax = find(fasROI(im).pixels(halfImage:end,end)==0,1,'first');
%         rowMax = rowMax+halfImage-1-20;
%         fasROI(im).pixels = fasROI(im).pixels(rowMin:rowMax,:);
% 
%     end
    % Filter fascicle ROI with Jerman filter
    fasROI(im).pixels  = vesselness2D(fasROI(im).pixels, 1, [1;1], 1, true);
    fasROI(im).pixels  = imbinarize(fasROI(im).pixels, 'adaptive', 'ForegroundPolarity', 'bright',  'sensitivity', .2);
        fasROI(im).pixels  = imresize(fasROI(im).pixels, ...
            [3*size(fasROI(im).pixels,1) 1*size(fasROI(im).pixels,2)], ...
            'Bicubic');

    % Get Hough angles in current image ROI
    Hough(im) = getHough(handles, fasROI(im).pixels, apo1(im).ROI, apo2(im).ROI, ii);
%     % Reduce number of lines
%     if ii == 2
% 
%         fasROI(im).pixels = bwpropfilt(fasROI(im).pixels,'MajorAxisLength',1);
% 
%     end
%     % Get Radon angles in current image ROI
%     theta = 0:0.01:179;
%     R = radon(fasROI(im).pixels,theta);
%     % Find the location of the peak of the radon transform image.
%     maxR = max(R(:));
%     [rowOfMax, columnOfMax] = find(R == maxR);
% 
%     if ii == 1
% 
%         Hough(im).angle = 90-theta(columnOfMax);
% 
%     else
% 
%         Hough(im).angle = 90-theta(columnOfMax);
% 
%     end

end