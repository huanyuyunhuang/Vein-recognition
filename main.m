clc
clear
PF=2;
if PF==1
    fileList = dir('������\������\�ƾ�������\*.bmp');
    fileNum = length(fileList);%��ȡ�ļ����ȣ�������
    LBPHist = zeros(472,30);
    templateImgs = zeros(180,180,30);
    for i = 1:fileNum
        img = imread(strcat('������\������\�ƾ�������\',fileList(i).name));
        [r,c] = size(img);
        palmROIImg = PalmROI(img,r,c);
%          figure;
%          imshow(palmROIImg);
        adressString = ['������\������\ROI\ROI_' sprintf('%0.2d', i) '.bmp']; %����num�Ǹ�ͼ�����ڵ�ѭ����ţ���������ɸ��ָ�ʽ
        imwrite(palmROIImg, adressString); %adressString��ʾ�����ַ
        rr = 180;
        cc = 180;
        uniformROI = imresize(palmROIImg,[rr cc]);
        gaborImg = gabor_enhance(uniformROI,rr,cc);%�˲�
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
        fileList = dir('������\������\ָ�������ݣ�ʳָ��\��һ�ֹ�ǿ\121\*.bmp');
    else
        fileList = dir('������\������\ָ�������ݣ�ʳָ��\��һ�ֹ�ǿ\121\*.bmp');
    end
    fileNum = length(fileList);
     LBPHist = zeros(472,6);
    for i = 1:fileNum
        if FS==1
            img = imread(strcat('������\������\ָ�������ݣ�ʳָ��\��һ�ֹ�ǿ\121\',fileList(i).name));
        else 
            img = imread(strcat('������\������\ָ�������ݣ�ʳָ��\�ڶ��ֹ�ǿ\121\',fileList(i).name));
        end
        imgH=rgb2gray(img);
        [r,c] = size(imgH);
        fingerROIImg = FingerROI(imgH,r,c);
%         figure;
%         imshow(fingerROIImg);
        if FS==1
            adressString = ['������\������\ָ�������ݣ�ʳָ��\��һ�ֹ�ǿ\ROI\ROI_' sprintf('%0.2d', i) '.bmp']; %����num�Ǹ�ͼ�����ڵ�ѭ����ţ���������ɸ��ָ�ʽ
            imwrite(fingerROIImg, adressString); %adressString��ʾ�����ַ
        else
            adressString = ['������\������\ָ�������ݣ�ʳָ��\�ڶ��ֹ�ǿ\ROI\ROI_' sprintf('%0.2d', i) '.bmp']; %����num�Ǹ�ͼ�����ڵ�ѭ����ţ���������ɸ��ָ�ʽ
            imwrite(fingerROIImg, adressString); %adressString��ʾ�����ַ
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
     %��������ƥ��̶�
%     for i=1:fileNum-1
%         for j=i+1:fileNum
%                 score = LBPmatch(LBPHist(:,i),LBPHist(:,j),totalBin,1);
%                 LBPScore(k) = score;
%                 k=k+1;
%         end
%     end
    %�����һ��ͼƬ������ͼƬƥ��̶�
    for i=2:fileNum
          score = LBPmatch(LBPHist(:,1),LBPHist(:,i),totalBin,3);
          LBPScore(k) = score;
          k=k+1;
    end
    plot(LBPScore);
end







