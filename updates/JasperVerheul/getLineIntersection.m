%% ------------------------------------------------------------------------
 function intersectionPoint = getLineIntersection(Line1, Line2);
% -------------------------------------------------------------------------
% This function calculates intersection point between the two straight 
% lines.
% 
% Input:            - Line1: coordinates of line 1.
%                   - Line2: coordinates of line 2.
% 
% Output:           - intersectionPoint: coordinates of the intersection
%                     point between Line1 and Line2
% -------------------------------------------------------------------------

intX = [Line1(:,1) Line2(:,1)];
intY = [Line1(:,2) Line2(:,2)];

d1                  = (intX(1)-intX(2))*(intY(3)-intY(4))-(intY(1)-intY(2))*(intX(3)-intX(4));
intersectionPoint   = [((intX(1)*intY(2)-intY(1)*intX(2))*(intX(3)-intX(4))-(intX(1)-intX(2))*(intX(3)*intY(4)-intY(3)*intX(4)))/d1 ...
    ,((intX(1)*intY(2)-intY(1)*intX(2))*(intY(3)-intY(4))-(intY(1)-intY(2))*(intX(3)*intY(4)-intY(3)*intX(4)))/d1];


