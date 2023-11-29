im(:,:,1) = im1;
im(:,:,2) = im2;

% opticFlow = opticalFlowFarneback('NumPyramidLevels' , 3,...
%         'PyramidScale' , 0.5000,...
%        'NumIterations' , 3,...
%     'NeighborhoodSize' , 25,...
%           'FilterSize' , 15);

for f = 1:2
    frame = im(:,:,f);
    Res(f).flow = estimateFlow(opticFlow,frame);
    %Res(f).flow = estimateFlow(opticalFlowLK,frame);
end

for f = 1:2
    flow = Res(f).flow;

    % Magnitude
    mag = imgaussfilt(flow.Magnitude,50); % gaussian filter to smooth neighbour pixels
    Mag(:,:,f) = mag;

end

% remove first frame
Mag(:,:,1) = [];

%% Show image of total magnitude
totmag = sum(Mag,3);
% meanmag = mean(Mag,3);

figure; imshow(im1); hold on
plot(flow,'DecimationFactor',[5 5],'ScaleFactor',5);
figure; plot(flow)
set(gca,'xdir','reverse','ydir','reverse')

figure
imagesc(totmag), colormap('hot')
axis image
set(gca,'XTick',[]);set(gca,'XTickLabel',[]);
set(gca,'YTick',[]);set(gca,'YTickLabel',[]);

