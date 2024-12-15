clc
clear
PF=2;
if PF==1
    myROI=imread('paml\ROI\ROI_01.bmp');
    fileList = dir('paml\otherdata\*.bmp');
    fileNum = length(fileList);%��ȡ�ļ����ȣ�������
    LBPHist = zeros(472,30);
    templateImgs = zeros(180,180,30);
    for i = 1:fileNum
        img = imread(strcat('paml\otherdata\',fileList(i).name));
        [r,c] = size(img);
        palmROIImg = PalmROI(img,r,c);
%          figure;
%          imshow(palmROIImg);
        adressString = ['paml\otherROI\ROI_' sprintf('%0.2d', i) '.bmp']; %����num�Ǹ�ͼ�����ڵ�ѭ����ţ���������ɸ��ָ�ʽ
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
    myuniformROI=imresize(myROI,[180,180]);
    mygaborImg = gabor_enhance(myuniformROI,180,180);%�˲�
    [mytotalHist,mytotalBin] = LBP(mygaborImg,180,180,1);
    LBPScore = zeros(1,20);
    k=1;
    for i=1:fileNum
        score = LBPmatch(mytotalHist,LBPHist(:,i),totalBin,1);
        LBPScore(k) = score;
        k=k+1;
    end
    plot(LBPScore);
    
elseif PF==2
    myROI=imread('finger\firstlight\ROI\ROI_01.bmp');
    FS=1;
    if FS==1
        fileList = dir('finger\firstlight\otherdata\*.bmp');
    else
        fileList = dir('finger\secondlight\otherdata\*.bmp');
    end
    fileNum = length(fileList);
     LBPHist = zeros(472,6);
    for i = 1:fileNum
        if FS==1
            img = imread(strcat('finger\firstlight\otherdata\',fileList(i).name));
        else 
            img = imread(strcat('finger\secondlight\otherdata\',fileList(i).name));
        end
        imgH=rgb2gray(img);
        [r,c] = size(imgH);
        fingerROIImg = FingerROI(imgH,r,c);
%         figure;
%         imshow(fingerROIImg);
        if FS==1
            adressString = ['finger\firstlight\otherROI\ROI_' sprintf('%0.2d', i) '.bmp']; %����num�Ǹ�ͼ�����ڵ�ѭ����ţ���������ɸ��ָ�ʽ
            imwrite(fingerROIImg, adressString); %adressString��ʾ�����ַ
        else
            adressString = ['finger\secondlight\otherROI\ROI_' sprintf('%0.2d', i) '.bmp']; %����num�Ǹ�ͼ�����ڵ�ѭ����ţ���������ɸ��ָ�ʽ
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
    [rrr,ccc]=size(myROI);
    myuniformROI=imresize(myROI,[rrr,ccc]);
    mygaborImg = gabor_enhance(myuniformROI,rrr,ccc);%�˲�
    [mytotalHist,mytotalBin] = LBP(mygaborImg,rrr,ccc,1);
    LBPScore = zeros(1,10);
     k=1;
    %�����Լ���ͼƬ�����˶Ա�
    for i=1:fileNum
          score = LBPmatch(mytotalHist,LBPHist(:,i),totalBin,1);
          LBPScore(k) = score;
          k=k+1;
    end
    plot(LBPScore);
end







