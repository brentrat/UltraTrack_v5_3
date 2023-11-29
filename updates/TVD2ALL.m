function TVDdata = TVD2ALL(TVDfname)
%*Read TVD file created by Echo Wave II and save grayscale images as MAT,
% MP4, and AVI and timestamps as MAT*
% TVD2MATMP4(TVDfile)

% Created by: Dominic Farris, The University of Queensland, 13/03/2014
% Edited by: Brent Raiteri, Ruhr University Bochum, June 2021
% tested in R2019b
%
% Inputs -TVDfname: string containing full path+filename of TVD
%
% Outputs -TVDdata.Im: 3D matrix representing 2D grayscale images
%         -TVDdata.Time: Vector of time stamps
%         -TVDdata.Height: Image height in pixels
%         -TVDdata.Width: Image width in pixels
%         -TVDdata.Fnum: Number of images
%% Read TVD
% Set path to Echo Wave II automation interface client .Net assembly (dll)
% -the function 'computer' returns the version of matlab (32 or 64 bit)
% and so the code doesn't do what you want if you're running 32-bit
% matlab on a 64-bit platform
% -therefore specify the path if using a 64-bit platform with 32-bit matlab
if ~strcmp(computer('arch'), 'win64')
    asm_path = 'C:\Program Files (x86)\Telemed\Echo Wave II\Config\Plugins\AutoInt1Client.dll';
else
    asm_path = 'C:\Program Files\Telemed\Echo Wave II\Config\Plugins\AutoInt1Client.dll';
end
% Create assembly
asm = NET.addAssembly(asm_path);
% Create command interface object (CmdInt1)
cmd = AutoInt1Client.CmdInt1();
% Connect to running Echo Wave II
ret = cmd.ConnectToRunningProgram();
if (ret ~= 0)
    error('Cannot connect to Echo Wave II. Please make sure the software is "Run as administrator".')
end
% Open TVD file (previously saved using Echo Wave II)
cmd.OpenFile(TVDfname);
% Get number of frames
TVDdata.Fnum = cmd.GetFramesCount();
% Go to last frame
cmd.GoToFrame1n(TVDdata.Fnum-1, true);
TVDdata.maxTime = cmd.GetCurrentFrameTime();
TVDdata.fps = round(1/(TVDdata.maxTime/1000/double(TVDdata.Fnum-1)),1);
%TVDdata.fps = round(1/(TVDdata.maxTime/1000));
% Go to first frame
cmd.GoToFrame1n(1, true);
% Get image width
TVDdata.Width = cmd.GetLoadedFrameWidth();
% Get image height
TVDdata.Height = cmd.GetLoadedFrameHeight();
% This just stops the computer running out of memory - would be good to
% specifically determine the max value as a function (TO DO)              *
% if (TVDdata.Fnum > 3000)
%     TVDdata.Fnum = 3000;
% end
%% Autocrop image
%if nargin < 2
im = uint8(cmd.GetLoadedFrameGray());
m = find(im(:,1) == 56); %find where the image starts vertically - at top of image the gray changes from 66 to 56
n = find(mean((im(end-50:end,:) == 56))<0.4); %use the averaage value of the bottom 50 rows to determine whether this is a high value (i.e. gray) or low (i.e. real image)
rect = [n(find(diff(n)>1)+1) m(1) n(end)-n(find(diff(n)>1)+1)+1 length(m)-1]; %define the new rectangle for autocroping
if size(rect,2) ~= 4
    rect = [n(2) m(1) n(end-1)-n(2)+1 length(m)-2];
end
% left = cmd.GetUltrasoundX1(1);
% top = cmd.GetUltrasoundY1(1);
% right = cmd.GetUltrasoundX2(1);
% bot = cmd.GetUltrasoundY2(1);
% rect = [left top right-left bot-top];
TVDdata.rect = rect;
if mod(rect(3),2)
    TVDdata.Width = rect(3)+1; %save the new width
else
    TVDdata.Width = TVDdata.rect(3);
    TVDdata.rect(3) = rect(3)-1;
end
if mod(rect(4),2)
    TVDdata.Height = rect(4)+1; %save the new width
else
    TVDdata.Height = TVDdata.rect(4);
    TVDdata.rect(4) = rect(4)-1;
end
% else %if the cropping box is specified, use it here.
%     TVDdata.rect = rect;
%     TVDdata.Width = rect(3)+1;
%     TVDdata.Height = rect(4)+1;
% end
%% Change image filtering
TVDdata.cmPerPixX = cmd.GetUltrasoundPhysicalDeltaX(1);
TVDdata.cmPerPixY = cmd.GetUltrasoundPhysicalDeltaY(1);
% Track PB_15_5_1_Super with below options here and on lab PC
% Also track it with no processing on lab PC and compare
% Rej=0, ImEnh=4, speckle reduction=PV 3, B color map=1
cmd.ParamSet(327,-64); %rejection shift from 0 to 32
cmd.ParamSet(328,1); %turn on image enhancement
cmd.ParamSet(329,1); %shift image enhancement from 3 to 4
cmd.ParamSet(330,1); %turn on speckle reduction
cmd.ParamSet(337,8); %shift speckle reduction from 3NeatView to 3PureView
%cmd.ParamSet(338,1); %initialise shift B Color Map 
%cmd.ParamSet(338,1); %shift B Color Map from 1 to 2
%% Save MAT
% Go through ALL frames and save as grayscale UINT8 image
h = waitbar(0,'Loading ultrasound data...');
MP4fname = strrep(TVDfname,'.tvd','.mp4');
%AVIfname = strrep(TVDfname,'tvd','avi');
writerObj = VideoWriter(MP4fname,'MPEG-4');
%writerObj2 = VideoWriter(AVIfname,'Motion JPEG AVI');
%writerObj.Quality = 75;
TVDdata.fpsRound = round(floor(TVDdata.fps),-1);
if TVDdata.fpsRound > TVDdata.fps
    TVDdata.fpsRound = TVDdata.fpsRound-10;
elseif TVDdata.fpsRound == 190
    TVDdata.fpsRound = TVDdata.fpsRound-20;
end
writerObj.FrameRate = TVDdata.fpsRound;
open(writerObj);
Im = zeros(TVDdata.Height, TVDdata.Width, TVDdata.Fnum,'uint8');
for jj = 1:TVDdata.Fnum
    % Go to frame jj
    cmd.GoToFrame1n(jj, true);
    % Get the time stamp
    TVDdata.Time(jj,1) = cmd.GetCurrentFrameTime();
    % See new settings with a screenshot
    if jj == 1
        imwrite(uint8(cmd.GetLoadedFrameGray()),strrep(TVDfname,'.tvd','.png'),'png')
    end
    % Get two-dimensional grayscale matrix of loaded frame
    % and crop Echo Wave II borders
    Im(:,:,jj) = imcrop(uint8(cmd.GetLoadedFrameGray()),TVDdata.rect);
    writeVideo(writerObj, Im(:,:,jj));
    waitbar(double(jj)/double(TVDdata.Fnum),h)
end
TVDdata.Time = TVDdata.Time/1000;
close(h);
close(writerObj);
end