%% ------------------------------------------------------------------------
function [apo1 apo2 Hough FPT] = getFas(handles, apo1, apo2, Hough, ii)
% -------------------------------------------------------------------------
% This function post-processes the tracking results from 'trackMuscle.m'.
%
% Input:            - handles: predefined handles structure.
%                   - apo1: struct containing aponeurosis 2 position and
%                     tracking results.
%                   - apo2: struct containing aponeurosis 2 position and
%                     tracking results.
%                   - Hough: struct containing Hough transform tracking
%                     results.
%
% Output:           - apo1: struct containing aponeurosis 1 position and
%                     tracking results, including post-processing results.
%                   - apo2: struct containing aponeurosis 2 position and
%                     tracking results, including post-processing results.
%                   - Hough: struct containing Hough transform tracking
%                     results, including post-processing results.
%                   - FPT: struct containing feature-point tracking
%                     results.
%                   - Hybrid: struct containing hybrid tracking results.
% -------------------------------------------------------------------------

% Smooth aponeurosis lines
apo1(2) = apo1(1);
apo2(2) = apo2(1);
for im = 1:2
    apo1XY(im,:) = [apo1(im).line(1,:) apo1(im).line(2,:)];
    apo2XY(im,:) = [apo2(im).line(1,:) apo2(im).line(2,:)];
end

apo1XY = movmean(apo1XY, 10);
apo2XY = movmean(apo2XY, 10);

for im = 1:2
    apo1(im).line = [apo1XY(im,1:2); apo1XY(im,3:4)];
    apo2(im).line = [apo2XY(im,1:2); apo2XY(im,3:4)];
end

% Calculate aponeurosis angles
for im = 1:2
    apo1(im).angle = atand( (apo1(im).line(2,2)-apo1(im).line(1,2)) / (apo1(im).line(2,1)-apo1(im).line(1,1)) );
    apo1(im).angle = atand( tand(apo1(im).angle) * ((1/handles.ID) / (1/handles.ID)) ); % angle corrected for pix-mm ratio
    apo2(im).angle = atand( (apo2(im).line(2,2)-apo2(im).line(1,2)) / (apo2(im).line(2,1)-apo2(im).line(1,1)) );
    apo2(im).angle = atand( tand(apo2(im).angle) * ((1/handles.ID) / (1/handles.ID)) ); % angle corrected for pix-mm ratio
end

apo1Ang = num2cell( movmean([apo1.angle], 10)' );
[apo1.angle] = apo1Ang{:};
apo2Ang = num2cell( movmean([apo2.angle], 10)' );
[apo2.angle] = apo2Ang{:};

% -------------------------------------------------------------------------
% Hough transform
% -------------------------------------------------------------------------
% Delete hough angles that are smaller/greater than [median +/- interquartile range] for all angles in video
houghAngs1 = [];
Hough(2) = Hough(1);
for im = 1:2 % get all Hough angles for video
    houghAngs1 = vertcat(houghAngs1, [repelem(im,length([Hough(im).lines.angle]))', [Hough(im).lines.angle]', [Hough(im).lines.length]']);
end

for im = 1:2 % delete values
    Hough(im).lines([Hough(im).lines.angle]' < (median(houghAngs1(:,2)) - 1.5*iqr(houghAngs1(:,2)))) = [];
    Hough(im).lines([Hough(im).lines.angle]' > (median(houghAngs1(:,2)) + 1.5*iqr(houghAngs1(:,2)))) = [];
end

houghAngs = [];
for im = 1:2 % get all Hough angle for video after deleting
    houghAngs = vertcat(houghAngs, [repelem(im,length([Hough(im).lines.angle]))', [Hough(im).lines.angle]', [Hough(im).lines.length]']);
end

fitHT = fit(houghAngs(:,1), houghAngs(:,2),'smoothingspline','Weights', houghAngs(:,3));
fitHT = num2cell( movmean( feval(fitHT,[1:length(Hough)]), 10) ); % moving mean of time-dependent fit Hough angles
[Hough.angle] = fitHT{:};

% -------------------------------------------------------------------------
% Hybrid tracking
% -------------------------------------------------------------------------
for im = 1
    % Apply geometric affine transformation to apo1 intersection points
    if ii == 1
        FPT(im).line = [apo2(im).line(2,1)-(apo2(im).line(2,2)-mean([apo1(im).line(:,2);apo2(im).line(:,2)])) / tand(Hough(im).angle), mean([apo1(im).line(:,2);apo2(im).line(:,2)]); ...
            apo2(im).line(2,1), apo2(im).line(2,2)];
    else
        FPT(im).line = [apo1(im).line(2,1)-(apo1(im).line(2,2)-mean([apo2(im).line(:,2);apo1(im).line(:,2)])) / tand(Hough(im).angle), mean([apo2(im).line(:,2);apo1(im).line(:,2)]); ...
            apo1(im).line(2,1), apo1(im).line(2,2)];
    end
    FPT(im).apo1int       = getLineIntersection(apo1(im).line, FPT(im).line);
    FPT(im).apo2int       = getLineIntersection(apo2(im).line, FPT(im).line);

    apo1(im).lineFT       = apo1(im).line;
    apo2(im).lineFT       = apo2(im).line;

    % Calculate feature-point tracking (FPT) fascicle dimensions
    FPT(im).height      = (FPT(im).apo2int(2)-FPT(im).apo1int(2)) / (1/handles.ID);
    FPT(im).width       = (FPT(im).apo2int(1)-FPT(im).apo1int(1)) / (1/handles.ID);
    FPT(im).length      = sqrt( FPT(im).height^2 + FPT(im).width^2 ) ;
    FPT(im).angle       = atand( FPT(im).height / FPT(im).width );
end

% Adjust fascicle pennation angles for aponeurosis 2 angle
adjHough = num2cell( [Hough.angle] - [apo2.angle] )';
[Hough.angle_aac] = adjHough{:};

adjFas = num2cell( [FPT.angle] - [apo2.angle] )';
[FPT.angle_aac] = adjFas{:};
