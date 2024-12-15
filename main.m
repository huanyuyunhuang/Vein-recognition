clc
clear
PF=2;
if PF==1
    fileList = dir('梁锡贤\梁锡贤\掌静脉数据\*.bmp');
    fileNum = length(fileList);%获取文件长度（数量）
    LBPHist = zeros(472,30);
    templateImgs = zeros(180,180,30);
    for i = 1:fileNum
        img = imread(strcat('梁锡贤\梁锡贤\掌静脉数据\',fileList(i).name));
        [r,c] = size(img);
        palmROIImg = PalmROI(img,r,c);
%          figure;
%          imshow(palmROIImg);
        adressString = ['梁锡贤\梁锡贤\ROI\ROI_' sprintf('%0.2d', i) '.bmp']; %这里num是该图像所在的循环编号，可以输出成各种格式
        imwrite(palmROIImg, adressString); %adressString表示输出地址
        rr = 180;
        cc = 180;
        uniformROI = imresize(palmROIImg,[rr cc]);
        gaborImg = gabor_enhance(uniformROI,rr,cc);%滤波
%          figure;
%          imshow(gaborImg);
         radius = 1;
         [totalHist,totalBin] = LBP(gaborImg,rr,cc,radius);
         LBPHist(:,i) = totalHist;
    end

%     LBPScore = zeros(1,210);
    LBPScore = zeros(1,20);
    k=1;
%     for i=1:fileNum-1
%         for j=i+1:fileNum
%                 score = LBPmatch(LBPHist(:,i),LBPHist(:,j),totalBin,3);
%                 LBPScore(k) = score;
%                 k=k+1;
%         end
%     end
    for i=2:fileNum
        score = LBPmatch(LBPHist(:,1),LBPHist(:,i),totalBin,3);
        LBPScore(k) = score;
        k=k+1;
    end
    plot(LBPScore);
    
elseif PF==2
    FS=2;
    if FS==1
        fileList = dir('梁锡贤\梁锡贤\指静脉数据（食指）\第一种光强\121\*.bmp');
    else
        fileList = dir('梁锡贤\梁锡贤\指静脉数据（食指）\第一种光强\121\*.bmp');
    end
    fileNum = length(fileList);
     LBPHist = zeros(472,6);
    for i = 1:fileNum
        if FS==1
            img = imread(strcat('梁锡贤\梁锡贤\指静脉数据（食指）\第一种光强\121\',fileList(i).name));
        else 
            img = imread(strcat('梁锡贤\梁锡贤\指静脉数据（食指）\第二种光强\121\',fileList(i).name));
        end
        imgH=rgb2gray(img);
        [r,c] = size(imgH);
        fingerROIImg = FingerROI(imgH,r,c);
%         figure;
%         imshow(fingerROIImg);
        if FS==1
            adressString = ['梁锡贤\梁锡贤\指静脉数据（食指）\第一种光强\ROI\ROI_' sprintf('%0.2d', i) '.bmp']; %这里num是该图像所在的循环编号，可以输出成各种格式
            imwrite(fingerROIImg, adressString); %adressString表示输出地址
        else
            adressString = ['梁锡贤\梁锡贤\指静脉数据（食指）\第二种光强\ROI\ROI_' sprintf('%0.2d', i) '.bmp']; %这里num是该图像所在的循环编号，可以输出成各种格式
            imwrite(fingerROIImg, adressString); %adressString表示输出地址
        end
        [rr,cc]=size(fingerROIImg);
        uniformROI = imresize(fingerROIImg,[rr cc]);
        gaborImg = gabor_enhance(uniformROI,rr,cc);
%            figure;
%            imshow(gaborImg);
         radius = 1;
         [totalHist,totalBin] = LBP(gaborImg,rr,cc,radius); 
         LBPHist(:,i) = totalHist;
    end
%      LBPScore = zeros(1,45);
    LBPScore = zeros(1,9);
     k=1;
     %计算两两匹配程度
%     for i=1:fileNum-1
%         for j=i+1:fileNum
%                 score = LBPmatch(LBPHist(:,i),LBPHist(:,j),totalBin,1);
%                 LBPScore(k) = score;
%                 k=k+1;
%         end
%     end
    %计算第一张图片与其它图片匹配程度
    for i=2:fileNum
          score = LBPmatch(LBPHist(:,1),LBPHist(:,i),totalBin,3);
          LBPScore(k) = score;
          k=k+1;
    end
    plot(LBPScore);
end







