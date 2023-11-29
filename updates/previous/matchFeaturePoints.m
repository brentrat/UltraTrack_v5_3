    IM1 = TVDdata.Im(:,:,1);
    IM2 = TVDdata.Im(:,:,2);
    imshow(IM1); hold on
    %% Superficial aponeurosis
    [~,supAp] = ginputYellow(1);
    im = vesselness2D(IM1, 18:20, [1;1], 1, true);
    %threshAd = adaptthresh(im,'Statistic','gaussian');
    %imAp = imbinarize(im,threshAd);
    imAp = imbinarize(im);
    imApS = imcrop(imAp,[1 supAp-2/(50/size(IM1,1)) size(IM1,2)-1 2/(50/size(IM1,1))*2-1]);
    ap_sup = bwpropfilt(imApS,'MajorAxisLength',1); 
    ap_fill_top = false(round(supAp-2/(50/size(IM1,1))-1,0),size(IM1,2));
    ap_fill_bot = false(round(size(IM1,1)-supAp-2/(50/size(IM1,1))-1,0),size(IM1,2));
    ap_sup = [ap_fill_top; ap_sup; ap_fill_bot];
    [ap_sup_coef,~,ap_sup_y] = obj2ap_new(ap_sup,1);
    ptS(:,1) = linspace(1,size(IM1,2),2);                             
    ptS(:,2) = polyval(ap_sup_coef,ptS(:,1));
    plot(ptS(:,1),ptS(:,2),'y:','LineWidth',2)
    %% Deep aponeurosis
    [~,deepAp] = ginputYellow(1);
    %threshAd = adaptthresh(im,'Statistic','gaussian');
    %imAp = imbinarize(im,threshAd);
    imApD = imcrop(imAp,[1 deepAp-5/(50/size(IM1,1)) size(IM1,2)-1 4/(50/size(IM1,1))*2-1]); 
    ap_deep = bwpropfilt(imApD,'MajorAxisLength',1); 
    %% When deep aponeurosis selection fails change last input above to >1 and uncomment below section
%     figure; imshow(ap_deep);
%     hAp = figure; subplot(2,1,1); set(gcf,'Name','Click deep aponeurosis features that are incorrect and then press enter','Numbertitle','off'); 
%     imshow(im0);
%     subplot(2,1,2); imshow(ap_deep); 
%     set(gcf,'WindowState','maximized'); hold on; 
%     title('Click deep aponeurosis features that are incorrect and then press enter')
%     [x,y] = ginputYellow;
%     x = round(x,0);
%     y = round(y,0);
%     ap_delete = regionprops('struct',ap_deep,'BoundingBox','SubarrayIdx');
%     for bb = 1:length(ap_delete)
%        xq = [ap_delete(bb).BoundingBox(1,1) ap_delete(bb).BoundingBox(1,1)+ap_delete(bb).BoundingBox(1,3)];
%        xq = round(xq,0);
%        yq = [ap_delete(bb).BoundingBox(1,2) ap_delete(bb).BoundingBox(1,2)+ap_delete(bb).BoundingBox(1,4)];
%        yq = round(yq,0);
%        for cc = 1:length(x)
%        if x(cc) >= xq(1,1) && x(cc) <= xq(1,2) && y(cc) >= yq(1,1) && y(cc) <= yq(1,2)
%            ap_deep(ap_delete(bb).SubarrayIdx{:,1},ap_delete(bb).SubarrayIdx{:,2}) = false;
%            %https://au.mathworks.com/matlabcentral/answers/486087-remove-specific-objects-from-an-image
%        end 
%        end
%     end   
%     close(hAp);
    %% deep aponeurosis continued
    ap_fill_top = false(round(deepAp-5/(50/size(IM1,1))-1,0),size(IM1,2));
    ap_fill_bot = false(round(size(IM1,1)-deepAp-4/(50/size(IM1,1))-1,0),size(IM1,2));
    ap_deep = [ap_fill_top; ap_deep; ap_fill_bot];
    [ap_deep_coef,~,ap_deep_y] = obj2ap_new(ap_deep,2);
    ptD(:,1) = linspace(1,size(IM1,2)); %,2
    ptD(:,2) = polyval(ap_deep_coef,ptD(:,1));
    plot(ptD(:,1),ptD(:,2),'y:','LineWidth',2)
    %% fascicle choice
    imF = imcrop(IM1,[1+1/(50/size(IM1,1)) max(ap_sup_y)+2/(50/size(IM1,1)) size(IM1,2)-1/(50/size(IM1,1))-1 min(ap_deep_y)-4/(50/size(IM1,1))-max(ap_sup_y)-1]);
    %% fascicle defined by user-selected points
    I1 = imF;
    clear imF
    points1 = detectKAZEFeatures(I1);  
    imF = imcrop(IM2,[1+1/(50/size(IM1,1)) max(ap_sup_y)+2/(50/size(IM1,1)) size(IM1,2)-1/(50/size(IM1,1))-1 min(ap_deep_y)-4/(50/size(IM1,1))-max(ap_sup_y)-1]);
    I2 = imF;
    points2 = detectKAZEFeatures(I2);
    [f1,vpts1] = extractFeatures(I1,points1);
    [f2,vpts2] = extractFeatures(I2,points2);
    indexPairs = matchFeatures(f1,f2) ;
    matchedPoints1 = vpts1(indexPairs(:,1));
    matchedPoints2 = vpts2(indexPairs(:,2));
figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2);
legend('matched points 1','matched points 2');
