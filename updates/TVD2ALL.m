function TVDdata = TVD2ALL(TVDfname, varargin)
%*Read TVD file created by Echo Wave II and save grayscale images as
% MP4 and TVD info as MAT*
% TVD2ALL(TVDfile)

% Created by: Dominic Farris, The University of Queensland, 13/03/2014
% Edited by: Brent Raiteri, Ruhr University Bochum, June 2021
% tested in R2019b
% Edited by: Paolo Tecchio, Ruhr University Bochum, April 2024 
    % adjusted the dll check for all EW versions (x86, 
    % corrected fps estimation
    % improved image cropping 
    % no more issue with limited memory, 
%
% Inputs -TVDfname: string containing full path+filename of TVD
%
% Outputs - MP4 file of the TVD data (cropped images, and lower memory)
%        -- A mat file with the same name of the MP4 file, it is a struct
%        with:
%         -TVDdata.Time: Vector of time stamps 
%         -TVDdata.Height: Image height in pixels
%         -TVDdata.Width: Image width in pixels
%         -TVDdata.fps: normal fps
%         -TVDdata.Fnum: Number of frames        
%         -TVDdata.fpsround: rounded fps
%% Check inputs

%parse inputs
p         = inputParser;        
addOptional(p,'VideoQuality',75,@(x) ~mod(x, 1) && (x>=0) && (x<=100)); %defualt 75% 

p.parse(varargin{:});
vQuality = p.Results.VideoQuality;

%% Read TVD
% Set path to Echo Wave II automation interface client .Net assembly (dll)
% -the function 'computer' returns the version of matlab (32 or 64 bit)
% and so the code doesn't do what you want if you're running 32-bit
% matlab on a 64-bit platform
% -therefore specify the path if using a 64-bit platform with 32-bit matlab
if ~strcmp(computer('arch'), 'win64')
    asm_path = 'C:\Program Files (x86)\TELEMED\\Echo Wave II Application\EchoWave II\Config\Plugins\AutoInt1Client.dll'; % 32-bit
    if ~exist(asm_path(1:end-18),'dir') % Pre 4.1.2
        asm_path = 'C:\Program Files (x86)\Telemed\Echo Wave II\Config\Plugins\AutoInt1Client.dll';
    end
else
    asm_path = 'C:\Program Files\Telemed\Echo Wave II Application\EchoWave II\Config\Plugins\AutoInt1Client.dll'; % 64-bit
    if ~exist(asm_path(1:end-18),'dir') % Pre 4.1.2
        asm_path = 'C:\Program Files\Telemed\Echo Wave II\Config\Plugins\AutoInt1Client.dll';
    end
end
% Create assembly
asm = NET.addAssembly(asm_path);
% Create command interface object (CmdInt1)
cmd = AutoInt1Client.CmdInt1();
% Connect to running Echo Wave II 
ret = cmd.ConnectToRunningProgram();

if (ret ~= 0)
    try 
        curr_path = cd;
        cd(fileparts(asm_path)); %need to move because RegAsm does not allow space like "Program Files"
        % Register AutoInt1.dll using RegAsm.exe 
        %don't use regsvr32 because it doesn't register the COM-exposed NET
        %assembly which is necessary for this library.
        %RegAsm.exe makes registry entries to make .NET components look like COM components
        regasmCommand = "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\RegAsm.exe AutoInt1.dll";
        
        % Execute the command
        [status, cmdOut] = system(regasmCommand);
        
        % Display the command output
        fprintf(cmdOut);
        pause(0.5); %wait as never say never with windows
        cd(curr_path); %bring it back to the previous path
        %try connecting again to EWII
        ret = cmd.ConnectToRunningProgram();
        if ret ~= 0 && status==0
            fprintf('\nDLL installed correctly, please check that EchoWave is running with Admin privileges.');
            return
        end
    catch
        disp('There are issues with the Dll. Please check the paths and/or (re)-install EchoWave II 32bits!');
    end           


end
% Open TVD file (previously saved using Echo Wave II)
cmd.OpenFile(TVDfname);
% Get number of frames
TVDdata.Fnum = double(cmd.GetFramesCount());
% Go to last frame
cmd.GoToFrame1n(inf, true);
maxTime = cmd.GetCurrentFrameTime() / 1000; %/1000 because in ms, first frame time is 0.
%(TVDdata.Fnum -1) because last frame has the same time like the second last. 
% This is because EchoWave save timestamps based on the subsequent frame
% which doesn't exist for the last one.
TVDdata.fps = round(1/(maxTime / (TVDdata.Fnum -1) ),3); 

% Go to first frame
cmd.GoToFrame1n(1, true);

%% Autocrop image
im = int32(cmd.GetLoadedFrameRGB());
imB = double(diff(im,[],3));
imB = (squeeze(imB(:,:,1)));

% %m = find(im(:,1) == 56); %find where the image starts vertically - at top of image the gray changes from 66 to 56
% 
% m(1) = cmd.GetUltrasoundY1(1)+0.5;
% m(2) =  cmd.GetUltrasoundY2(1);
top = cmd.GetUltrasoundY1(1)+0.5;
bot = cmd.GetUltrasoundY2(1)-1;
%
imB = imB(top:bot,:); %cut top to bottom
imB = imB == 0; %MAKE IT LOGICAL
%Get the bounds
[B,~] = bwboundaries(imB, 'noholes');

% Find the boundary with the maximum number of elements
maxLength = 0;
maxIndex = 0;
for k = 1:length(B)
    boundary = B{k};
    if length(boundary) > maxLength
        maxLength = length(boundary);
        maxIndex = k;
    end
end

% Plot the boundary with the maximum number of elements
boundary = B{maxIndex};
%plot(boundary(:, 2), boundary(:, 1), 'r', 'LineWidth', 2);
%create the rect
% Find the minimum and maximum x and y coordinates of the boundary
minX = min(boundary(:, 2));
maxX = max(boundary(:, 2));

% Calculate the width of the rectangle
width = maxX - minX;

% Create a rectangle object for cropping
rect = double([minX, top, width, abs(top-bot)]);
TVDdata.rect = rect;


%% OLD method
% n = find(mean((im(end-50:end,:) == 56))<0.4); %use the averaage value of the bottom 50 rows to determine whether this is a high value (i.e. gray) or low (i.e. real image)
% rect = [n(find(diff(n)>1)+1) m(1) n(end)-n(find(diff(n)>1)+1)+1 m(2)]; %define the new rectangle for autocroping
% if size(rect,2) ~= 4
%     rect = [n(2) m(1) n(end-1)-n(2)+1 length(m)-2]; 
% end
% left = cmd.GetUltrasoundX1(1);
% top = cmd.GetUltrasoundY1(1);
% right = cmd.GetUltrasoundX2(1);
% bot = cmd.GetUltrasoundY2(1);
% rect = [left top right-left bot-top];

%% Check size as H.264 required even pixels sizes

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
% im = uint8(cmd.GetLoadedFrameGray());
% im = imcrop(im,rect);
% else %if the cropping box is specified, use it here.
%     TVDdata.rect = rect;
%     TVDdata.Width = rect(3)+1;
%     TVDdata.Height = rect(4)+1;
% end
%% Get the scale
TVDdata.cmPerPixX = cmd.GetUltrasoundPhysicalDeltaX(1);
TVDdata.cmPerPixY = cmd.GetUltrasoundPhysicalDeltaY(1);
%% Change image filtering
% cmd.ParamSet(327,32); %rejection shift from 0 to 32
% cmd.ParamSet(328,1); %turn on image enhancement 
%  cmd.ParamSet(329,1); %shift image enhancement from 3 to 4
%  cmd.ParamSet(330,1); %turn on speckle reduction
%  cmd.ParamSet(337,8); % ,8 to shift speckle reduction from 3NeatView to 3PureView
%   cmd.ParamSet(328,0); %turn on image enhancement 
%   cmd.ParamSet(329,1); %shift image enhancement from 3 to 4

%% Save MAT
% Go through ALL frames and save as grayscale UINT8 image
h = waitbar(0,'Loading ultrasound data...');
MP4fname = strrep(TVDfname,'.tvd','.mp4');
writerObj = VideoWriter(MP4fname,'MPEG-4');
writerObj.Quality = vQuality;

%TVDdata.fpsRound = round(TVDdata.fps/5)*5;
writerObj.FrameRate = TVDdata.fps;
%create video object
open(writerObj);
%pre allocate im again as uint8
im = zeros(TVDdata.Height, TVDdata.Width,'uint8');

for jj = 1:TVDdata.Fnum
    % Go to frame jj
    cmd.GoToFrame1n(jj, true);
    % Get the time stamp
    TVDdata.Time(jj,1) = cmd.GetCurrentFrameTime();
    % Get two-dimensional grayscale matrix of loaded frame 
    % and crop Echo Wave II borders
    im = imcrop(uint8(cmd.GetLoadedFrameGray()),TVDdata.rect);   
    writeVideo(writerObj, im);    
    waitbar(double(jj)/double(TVDdata.Fnum),h)
end


TVDdata.Time = TVDdata.Time/1000;%convert ms to s
%EW save the timestamp based on the following frame, however the last frame
%does save the same time as the previous one. In this way we correct the
%last timestamp according to the frequency.
TVDdata.Time(end) = TVDdata.Time(end-1) + 1/TVDdata.fps;

close(h);
close(writerObj);

end
