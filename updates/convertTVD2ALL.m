%% Select TVD file/s and save to MAT and MP4 file/s 
% Requires uipickfiles TVD2ALL.m
clear; close all

if ~isAdmin
    fprintf(['MATLAB is not running with administrator privileges.\n' ...
        'YOU MUST RUN MATLAB AS ADMIN! \n']);
    return
end

%add automatically all files and subfolders dynamically
filename = [mfilename,'.m'];
fullpath = which(filename);
mainfoldername = erase(fullpath,filename);
addpath(genpath(mainfoldername));
clearvars mainfoldername fullpath filename

%Select files
TVDfiles = uipickfiles('REFilter','.tvd','Prompt','Choose the TVD files to convert');
%[TVDfiles, path] = uigetfile('*.tvd','Select TVD(s) to convert','MultiSelect','on');
if ~iscell(TVDfiles)
    warndlg('Select TVD file/s to convert');
    return
end

h = waitbar(0,['Overall progress: Processing 1/' num2str(length(TVDfiles))],'Color','#48484C');
hp = get(h,'Position');
set(h,'Position',[hp(1),hp(2)+hp(4),hp(3),hp(4)]);
hcc = get(get(h,'Children'),'Children');
for jj = 1:length(TVDfiles)
    waitbar(double(jj-1)/double(length(TVDfiles)),h,...
    ['Overall progress: Processing ' num2str(jj) '/' num2str(length(TVDfiles))])
    % uipickfiles stores filenames as a cell so index to a cell
    TVDdata = TVD2ALL(TVDfiles{jj},'VideoQuality', 85); %TVDresolution
    save(strrep([TVDfiles{jj}],'.tvd','.mat'),'TVDdata')
    clear TVDdata
end
waitbar(1,h,'Conversions completed')
clearvars -except TVDfiles
%shutdown
