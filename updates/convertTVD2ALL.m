%% Select TVD file/s and save to MAT and MP4 file/s 
% Requires uipickfiles TVD2ALL.m
clear; close all
TVDfiles = uipickfiles('REFilter','.tvd','Prompt','Choose the TVD files to convert');
if TVDfiles{1} == 0
    error('Select TVD file/s to convert');
end
h = waitbar(0,['Overall progress: Processing 1/' num2str(length(TVDfiles))]);
hp = get(h,'Position');
set(h,'Position',[hp(1),hp(2)+hp(4),hp(3),hp(4)]);
hcc = get(get(h,'Children'),'Children');
for jj = 1:length(TVDfiles)
    waitbar(double(jj-1)/double(length(TVDfiles)),h,...
        ['Overall progress: Processing ' num2str(jj) '/' num2str(length(TVDfiles))])
    % uipickfiles stores filenames as a cell so index to a cell
    TVDdata = TVD2ALL(TVDfiles{jj}); %TVDresolution
    %save(['C:\Users\brent\Desktop\ISEK\Resubmission\Paddy\res',num2str(jj),'.mat'],'TVDdata')
    save(strrep(TVDfiles{jj},'.tvd','.mat'),'TVDdata')
    clear TVDdata
end
waitbar(1,h,'Conversions completed')
clearvars -except TVDfiles
%shutdown