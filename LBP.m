function [totalHist,totalBin] = LBP(img,rr,cc,radius)%LBP特征提取
    LBP_Img = zeros(rr-2*radius,cc-2*radius);
    LBP_Table = uniformTable(radius*8);%生成给定采样点数目下的uniform表
    for p = radius+1:rr-radius
        for q = radius+1:cc-radius
            LBP_data = LBPcode(img,p,q,radius);%计算(p，q)点的LBP值
            LBP_Img(p-radius,q-radius) = LBP_Table(LBP_data+1);%LBPImg对应点的值为LBPdata对应类标号
        end
    end
    R_blocks = 2;%行分块
    C_blocks = 4;%列分块
    sumBlocks = R_blocks*C_blocks;%总分块数目
    LeftUp_Corner = zeros(sumBlocks,2);%每一分块左上角点坐标
    rowsLen = floor((rr-2*radius)/R_blocks);%分块高
    colsLen = floor((cc-2*radius)/C_blocks);%分块宽
    index = 1;
    for p = 1:R_blocks%得到每个分块的左上角点坐标
        for q = 1:C_blocks
            LeftUp_Corner(index,:) = [(p-1)*rowsLen+1 (q-1)*colsLen+1];
            index = index+1;
        end
    end
    subImgs = zeros(sumBlocks,rowsLen,colsLen);%sumBlocks幅大小相同的图
    bin = radius*8*(radius*8-1)+3;%直方图bin数量/类别数radius=1时bin=59
    totalBin = bin*sumBlocks;%整幅图像的直方图bin数量,59*8
    totalHist = zeros(totalBin,1);%整幅图像的直方图数值
    tempImg = zeros(rowsLen,colsLen);
    for m = 1:sumBlocks
        subImgs(m,:,:) = SUBImg(LBP_Img,LeftUp_Corner(m,1),rowsLen,LeftUp_Corner(m,2),colsLen);%获取每个图像分块
        tempImg(:,:) = subImgs(m,:,:);
        tempHist = Hist(tempImg,bin);%统计每个图像分块的直方图
        totalHist((m-1)*bin+1:m*bin) = tempHist;% 串接LBP直方图
    end
    totalHist=totalHist/sum(totalHist); % 串接LBP直方图归一化
    %绘制直方图条形图
%       figure;
%       bar(totalHist,3);
    function  counts = Hist(img,bin)
        [r,c] = size(img);
        counts = zeros(bin,1);
        for i = 1:r
            for j = 1:c
                counts(img(i,j)+1) = counts(img(i,j)+1)+1;
            end
        end
            
    end

    function subImgs = SUBImg(img,rowsPos,rowsLen,colsPos,colsLen)%从图像中分割出指定的小块
%         rowsPos：分块左上角点在原图中的行数；
%         rowslength：分块高；
%         colsFirst：分块左上角点在原图中的列数；
%         colslength：分块宽。
        subImgs = zeros(rowsLen,colsLen,'uint8');
        for i = 1:rowsLen
            for j = 1:colsLen
                subImgs(i,j) = img(rowsPos+i-1,colsPos+j-1);
            end
        end
    end

    function LBPdata = LBPcode(img,i,j,radius)%计算某一像素点的LBP code,8*radius采样点的LBP算子,旋转不变处理，uniform模式降维
        %圆形LBP特征值的计算
        neighbors = radius*8;%采样点数，radius=1时是八领域
        data = zeros(neighbors,2);
        %获取中心像素点的灰度值
        center = img(i,j);
        LBPdata  = 0;%该像素点的LBP值
        if neighbors == 8
            Data_type = 'uint8';
        elseif neighbors == 16
            Data_type = 'uint16';
            elseif neighbors == 32
                Data_type = 'uint32';
                elseif neighbors == 64
                    Data_type = 'uint64';
        end
        for n = 1:neighbors
            %计算采样点对中心点坐标的偏移量rx，ry
            rx = radius*cos(2*pi*(n-1)/neighbors);%pi:π
            ry = -radius*sin(2*pi*(n-1)/neighbors);
            %双线性插值
            %对采样点偏移量分别进行上下取整
            x1 = floor(rx);%返回小于或等于给定值的最大整数
            x2 = round(rx);%返回大于或等于给定值的最小整数
            y1 = floor(ry);
            y2 = round(ry);
            %将坐标偏移量映射到0-1之间
            tx = rx-x1;
            ty = ry-y1;
            %根据0-1之间x,y的权重计算公式计算权重，权重与坐标具体位置无关，与坐标间的插值有关
            w1 = (1-tx)*(1-ty);
            w2 = tx*(1-ty);
            w3 = (1-tx)*ty;
            w4 = tx*ty;
             %根据双线性插值计算第n个采样点的灰度值
            data(n) = img(i+y1,j+x1)*w1+img(i+y2,j+x1)*w2+img(i+y1,j+x2)*w3+img(i+y2,j+x2)*w4;
            %对应的LBP值通过移位获得
            LBPdata = bitshift(LBPdata,1,Data_type);%按Dtype类型进行位左移1
            if data(n)>center%大于中心像素的灰度值
                LBPdata = bitor(LBPdata,1,Data_type);%按Dtype类型进行位或1
            end
        end
        %进行旋转不变处理
        minValue = LBPdata;
        for n = 1:neighbors
            %循环左移
            temp = bitor(bitshift(LBPdata,n,Data_type),bitshift(LBPdata,n-neighbors,Data_type));
            if temp<minValue
                minValue = temp;
            end
        end
        LBPdata = minValue;   
    end

    function table = uniformTable(neighbors)%生成LBPuniform模式特征值
        %neighbors=8时，58种情况＋1种其他类
        temp = 1;
        table = zeros(1,neighbors);
        total = 2^neighbors;
        for n = 0:total-1
            if getChangeTimes(n,neighbors) < 3%要求跳变次数小于等于2
                table(n+1) = temp;%table[1]对应LBP值为0的uniform模式
                temp = temp+1;
            end
        end
    end

    function count = getChangeTimes(data,neighbors)%判断跳变次数
        count = 0;
        binaryCode = dec2bin(data,neighbors);%dec2bin十进制转二进制，字符数组表示
        dataLen = length(binaryCode);
        for n = 2:dataLen
            if binaryCode(n) ~= binaryCode(n-1)%当前位为前一位取反，则有跳变
                count = count+1;
            end
        end
        
    end
end