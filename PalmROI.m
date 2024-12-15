function ret = PalmROI(oldImg,r,c)
    [thread,~] = OTSU(oldImg,r,c);
    binariedImg = Binarize(oldImg,r,c,16);%二值化
%     figure;
%     imshow(binariedImg);
    %获取边缘，maxAreaPoint存储边缘点坐标，totalNum存储边缘长
    [newImg,maxAreaPoint,totalNum] = getMaxRegionPoint(binariedImg);%maxAreaPoint
    rightCol = 0;
    leftCol = 0;
    for n = 1:c
        if ~length(find(newImg(:,n)==255))==0
            rightCol = n;
            break;
        end
    end
    for n = c:-1:1
        if ~length(find(newImg(:,n)==255))==0
            leftCol = n;
            break;
        end
    end
    centerPoint = zeros(1,2);
    centerPoint(2) = (rightCol+leftCol)/2;
    centerPoint(1) = r;
    %squarePoint为ROI边界的两个顶点，fingerPoint为指尖指根点，总计9个
    [squarePoint,fingerPoint,pointElse] = getSquareTwoPoint(maxAreaPoint,totalNum,centerPoint,r);
    figure;
    imshow(oldImg);
    hold on
    line([squarePoint(1,2),squarePoint(2,2)],[squarePoint(1,1),squarePoint(2,1)],'color','r','LineWidth',1);
    drawpoint('Position',[squarePoint(1,2) squarePoint(1,1)]);
    drawpoint('Position',[squarePoint(2,2) squarePoint(2,1)]);
    drawpoint('Position',[fingerPoint(1,2) fingerPoint(1,1)]);
    drawpoint('Position',[fingerPoint(2,2) fingerPoint(2,1)]);
    drawpoint('Position',[fingerPoint(3,2) fingerPoint(3,1)]);
    drawpoint('Position',[fingerPoint(4,2) fingerPoint(4,1)]);
    drawpoint('Position',[fingerPoint(5,2) fingerPoint(5,1)]);
    drawpoint('Position',[fingerPoint(6,2) fingerPoint(6,1)]);
    drawpoint('Position',[fingerPoint(7,2) fingerPoint(7,1)]);
    drawpoint('Position',[fingerPoint(8,2) fingerPoint(8,1)]);
    drawpoint('Position',[fingerPoint(9,2) fingerPoint(9,1)]);
    drawpoint('Position',[pointElse(1,2) pointElse(1,1)]);
    drawpoint('Position',[pointElse(2,2) pointElse(2,1)]);
    ret = getPalmROI(oldImg,r,c,squarePoint);

    function [translatedImg,rr,cc] = Translate(oldImg,r,c,squarePoint1)
        rr = 2*(r-squarePoint1(1))+1;
        cc = 2*(c-squarePoint1(2))+1;
        translatedImg = zeros(rr,cc,'uint8');
        if rr>r     
            startIndexR = 1;
            i = rr-r+1;
        else
            i = 1;
            startIndexR = r-rr+1;
        end
        if cc>c   
            j = cc-c+1;
            startIndexC = 1;
        else
            j = 1;
            startIndexC = c-cc+1;
        end
        translatedImg((i:rr),(j:cc)) = oldImg((startIndexR:r),(startIndexC:c));
%         figure;
%         imshow(oldImg);
%         figure;
%         imshow(translatedImg);
%         drawpoint('Position',[round(cc/2) round(rr/2)]);
    end


    function ret = getPalmROI(oldImg,r,c,squarePoint)%根据角点，截取灰度掌静脉图片的ROI
        [translatedImg,rr,cc] = Translate(oldImg,r,c,squarePoint(1,:));
        rotateAngle = atan2((squarePoint(2,1) - squarePoint(1,1)),(squarePoint(2,2) - squarePoint(1,2))) * 180 / pi;
        rotatedImg = imrotate(translatedImg,rotateAngle,'crop');%旋转矫正，matlab函数
%         figure;
%         imshow(oldImg);
%         figure;
%         imshow(rotatedImg);
        len = disOfTwoPoint(squarePoint(1,:),squarePoint(2,:));
        len = round(len);
        ret = imcrop(rotatedImg,[cc/2,rr/2,len,len]);
    end

    function ret = findMin(dis, totalNum, i, Range)
        %判断输入的Dis[i]点是否为i - Range~i + Range范围内的极小值
        ret = 1;
        for index = i - Range: i + Range
            j = index;
            if j < 1
                j = totalNum+j;
            elseif j > totalNum
                j = j-totalNum;
            end
            if dis(j) < dis(i)
                ret = 0;
                break;
            end
        end
    end

    function ret = findMax(dis, totalNum, i, Range)
        %判断输入的Dis[i]点是否为i - Range~i + Range范围内的极大值
        ret = 1;
        for index = i - Range: i + Range
            j = index;
            if j < 1
                j = totalNum+j;
            elseif j > totalNum
                j = j-totalNum;
            end
            if dis(j) > dis(i)
                ret = 0;
                break;
            end
        end   
    end
    function ret = indexProcess(index,total)
        ret = index;
        if index>total
            ret = index-total;
        elseif index<1
            ret = total+index;
        end
    end

    function dis = disOfTwoPoint(randomPoint,centerPoint)%求取两个点的距离
        dis = sqrt((randomPoint(1)-centerPoint(1)).^2+(randomPoint(2)-centerPoint(2)).^2);
    end

    function [squarePoint,fingerPoint,pointElse] = getSquareTwoPoint(maxAreaPoint,totalNum,centerPoint,r)%根据轮廓点找出手掌的5个指尖点和4个指缝点，从而得到两个手掌关键点用于截取ROI
        startIndex = 0;
        startPointCol = r;
        dis = zeros(1,totalNum);
        for i = 1:totalNum
            arr = maxAreaPoint(i,:);
            if arr(1) == centerPoint(1)
                if arr(2) < startPointCol
                    startPointCol = arr(2);
                    startIndex = i;
                end
            end
        end
        for i = startIndex:(startIndex+totalNum-1)
            dis(mod(i-startIndex,totalNum)+1) = disOfTwoPoint(maxAreaPoint(mod(i,totalNum)+1,:),centerPoint);
        end
        num = 0;
        numIndex = zeros(1,9);
        fingerPoint = zeros(9,2);
        Range = 15;
        for i = 1:totalNum
            if num == 9
                break;
            elseif mod(num,2)==0
                if findMax(dis,totalNum,i,Range)==1
                    fingerPoint(num+1,:) = maxAreaPoint(mod(i+startIndex-1,totalNum)+1,:);
                    numIndex(num+1) = mod(i+startIndex-1,totalNum)+1;
                    num = num+1;
                end
            else
                if findMin(dis,totalNum,i,Range)==1
                    fingerPoint(num+1,:) = maxAreaPoint(mod(i+startIndex-1,totalNum)+1,:);
                    numIndex(num+1) = mod(i+startIndex-1,totalNum)+1;
                    num = num+1;
                end
            end
        end
        pointElse = zeros(2,2);
        squarePoint = zeros(2,2);
        if disOfTwoPoint(fingerPoint(2,:),fingerPoint(4,:)) > disOfTwoPoint(fingerPoint(6,:),fingerPoint(8,:))
            fingerLength = numIndex(4)-numIndex(3);
            index1 = indexProcess(numIndex(3)-fingerLength,totalNum);
            pointElse(1,:) = maxAreaPoint(index1,:);
            squarePoint(1,:) = (fingerPoint(4,:)+pointElse(1,:))./2;
            fingerLength = numIndex(9)-numIndex(8);
            index2 = indexProcess(numIndex(9)+fingerLength,totalNum);
            pointElse(2,:) = maxAreaPoint(index2,:);
            squarePoint(2,:) = (fingerPoint(8,:)+pointElse(2,:))./2;
        else
            fingerLength = numIndex(2)-numIndex(1);
            index1 = indexProcess(numIndex(1)-fingerLength,totalNum);
            pointElse(1,:) = maxAreaPoint(index1,:);
            squarePoint(1,:) = (fingerPoint(2,:)+pointElse(1,:))./2;
            fingerLength = numIndex(7)-numIndex(6);
            index2 = indexProcess(numIndex(7)+fingerLength,totalNum);
            pointElse(2,:) = maxAreaPoint(index2,:);
            squarePoint(2,:) = (fingerPoint(6,:)+pointElse(2,:))./2;
        end
    end


    function [newImg,maxAreaPoint,totalNum]  = getMaxRegionPoint(img)%根据二值化图片找出面积最大对应的轮廓点坐标?
        totalNum = 0;
        newImg = img;
        newImg(:,:) = 0;
        contours = bwboundaries(img,'noholes');%跟踪二进制图像中的区域边界
        len = length(contours);
        L = bwlabel(img);
        areas = zeros(1,len);
        for i = 1:len
            areas(i) = cell2mat(struct2cell(regionprops(L==i,'Area')));
        end
        maxArea = max(areas);
        for i = 1:len
            area = areas(i);
            if area == maxArea
                maxAreaPoint = cell2mat(contours(i));
                totalNum = length(maxAreaPoint);   
                for j = 1:totalNum
                    arr = maxAreaPoint(j,:);
                    newImg(arr(1),arr(2)) = 255;
                end
            end
        end
%          figure;
%          imshow(newImg);
    end

end