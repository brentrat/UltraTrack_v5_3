function [ap_coef,apx,apy] = obj2ap_new(obj,location,varargin)
%*Fit aponeurosis object determined from bwpropfilt*
%obj2ap(obj,location[1=sup,2=deep],optional[type of poly])

% Author:
% BJ Raiteri, May 2021, if you find errors pls email brent.raiteri@rub.de
% tested in R2019b
columns = size(obj,2);
if location == 1
    %% superficial aponeurosis
    counter = 0;
    for col = 1:columns
        thisColumn = obj(:, col);
	    t = find(thisColumn, 1, 'last');
        if ~isempty(t)
            counter = counter+1;
            apy(counter) = t;
            apx(counter) = col;
        end
    end   
    if nargin > 2
        ap_coef = polyfit(apx, apy, varargin{1});
    else
        ap_coef = polyfit(apx, apy, 1); 
    end
    apx = [1 columns];
    apy = polyval(ap_coef, apx); 
elseif location == 2
    %% deep aponeurosis
    counter = 0;
    for col = 1:columns
	    thisColumn = obj(:, col);
        t = find(thisColumn, 1, 'first'); %first if you want to find the first white pixel
	    if ~isempty(t)
            counter = counter+1;
            apy(counter) = t;
            apx(counter) = col;
        end
    end
    if nargin > 2
        for col = 1:columns
	    thisColumn = obj(:, col);
	    t1 = find(thisColumn, 1, 'first'); %first if you want to find the first white pixel
        t2 = find(thisColumn, 1, 'last'); %last if you want to find the last white pixel
        t = round(mean([t1;t2]),0);
	    if ~isempty(t)
            counter = counter+1;
            apy(counter) = t;
            apx(counter) = col;
        end
        end
        idx = isnan(apy);
        ap_coef = polyfit(apx(~idx),apy(~idx),varargin{1});
        %ap_coef = polyfit(apx, apy, varargin{1});
    else
        ap_coef = polyfit(apx, apy,1);
    end
    apx = [1 columns];
    apy = polyval(ap_coef, apx);
else
    error('Wrong inputs defined: obj2ap_new(obj,[1=sup,2=deep])')
end