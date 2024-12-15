function ret = FingerROI(img,r,c)
    filteredImg = imgaussfilt(img);%高斯滤波
    [UpRow,index1,DownRow,index2] = EdgeExtraction(filteredImg,r,c);%边缘提取
%     EdgeImg=GetSimpleEdgeImg(img,UpRow,index1,DownRow,index2);%边缘输出测试
%     figure;
%     imshow(EdgeImg);
    ColImg=regionCol(filteredImg,UpRow,index1,DownRow,index2);
    RowImg=regionRow(ColImg,UpRow,index1,DownRow,index2);
    fingerROIImg=RowImg;
    ret = fingerROIImg; 
end
function EdgeImg=GetSimpleEdgeImg(img,UpRow,index1,DownRow,index2)
    [r,c]=size(img);
    EdgeImg=zeros(r,c);
    for i=1:index1
        EdgeImg(UpRow(1,i),UpRow(2,i))=1;
    end
    for i=1:index2
        EdgeImg(DownRow(1,i),DownRow(2,i))=1;
    end
end
function ColImg=regionCol(img,UpRow,index1,DownRow,index2)
    [r,c]=size(img);
    C1=1;
    C2=c;
    if UpRow(2,1)<DownRow(2,1)
        C1=DownRow(2,1);
    else 
        C1=UpRow(2,1);
    end
    if UpRow(2,index1)>DownRow(2,index2)
        C2=DownRow(2,index2);
    else 
        C2=UpRow(2,index1);
    end
    ColImg=imcrop(img,[C1 0 C2-C1 r]);
end
function RowImg=regionRow(img,UpRow,index1,DownRow,index2)
%     mincol=0;
%     for i=1:1:index1
%         if LeftCol(i,2)>mincol
%             mincol=LeftCol(i,2);
%         end
%     end
%     maxcol=inf;
%     for i=1:1:index2
%         if RightCol(i,2)<maxcol
%             maxcol=RightCol(i,2);
%         end
%     end
    minrow=0;
    for i=1:1:index1
        minrow=minrow+UpRow(1,i);
    end
    minrow=minrow/index1;
    maxrow=0;
    for i=1:1:index2
        maxrow=maxrow+DownRow(1,i);
    end
    maxrow=maxrow/index2;
    [~,c]=size(img);
    RowImg=imcrop(img,[1 minrow c maxrow-minrow]);
end
 function [UpRow,index1,DownRow,index2] = EdgeExtraction(img,r,c)%边缘提取
        %输入原始指静脉图片，返回只保留指静脉上下边缘的二值化图像以及指静脉上下边缘的坐标值
        kernelUp = [-1 -1 -1 -1 -1 -1 -1 -1 -1;%5*9
                    -1 -1 -1 -1 -1 -1 -1 -1 -1;
                     0  0  0  0  0  0  0  0  0;
                     1  1  1  1  1  1  1  1  1;
                     1  1  1  1  1  1  1  1  1];
        kernelDown = [1  1  1  1  1  1  1  1  1;
                      1  1  1  1  1  1  1  1  1;
                      0  0  0  0  0  0  0  0  0;
                     -1 -1 -1 -1 -1 -1 -1 -1 -1;
                     -1 -1 -1 -1 -1 -1 -1 -1 -1];
        upImg = img(1:round(r/2),:);
        downImg = img((round(r/2)+1):r,:);
        Up = imfilter(upImg,kernelUp,'symmetric');%对图像进行滤波
        Down = imfilter(downImg,kernelDown,'symmetric');%OK
%          figure;
%          imshow(Up);
%          figure;
%          imshow(Down);
        [thread,~] = OTSU(Up,round(r/2),c);%OTSU
        binaryUp = Binarize(Up,round(r/2),c,thread);
        [thread,~] = OTSU(Down,r-round(r/2),c);%OTSU
        binaryDown = Binarize(Down,r-round(r/2),c,thread);

        SE = strel('line', 7,9);
        openUp = imopen(binaryUp,SE);%开运算
        openDown = imopen(binaryDown,SE);

        edgeImg = [openUp; openDown];
        for i = 1:r
            for j = 1:c
                if edgeImg(i,j) == 1
                    edgeImg(i,j) = 255;
                end
            end
        end
%         figure;
%         imshow(edgeImg);
        UpRow = zeros(2,c);
        DownRow = zeros(2,c);
        index1 = 0;
        for p = round(c/4):round(2*c/3)
            for q = round(r/2):-1:1
                if openUp(q,p)==1
                    UpRow(:,index1+1) = [q p];
                    index1 = index1+1;
                    for in = q-1:-1:1
                        openUp(q,p) = 0;
                    end
                    break;
                end
            end
        end
        index2 = 0;
        for p = round(c/4):round(2*c/3)
            for q = 1:r-round(r/2)
                if openDown(q,p)==1
                    DownRow(:,index2+1) = [q+round(r/2) p];
                    index2 = index2+1;
                    for in = q+1:r-round(r/2)
                        openDown(q,p) = 0;
                    end
                    break;
                end
            end
      end
end

