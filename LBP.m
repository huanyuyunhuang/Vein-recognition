function [totalHist,totalBin] = LBP(img,rr,cc,radius)%LBP������ȡ
    LBP_Img = zeros(rr-2*radius,cc-2*radius);
    LBP_Table = uniformTable(radius*8);%���ɸ�����������Ŀ�µ�uniform��
    for p = radius+1:rr-radius
        for q = radius+1:cc-radius
            LBP_data = LBPcode(img,p,q,radius);%����(p��q)���LBPֵ
            LBP_Img(p-radius,q-radius) = LBP_Table(LBP_data+1);%LBPImg��Ӧ���ֵΪLBPdata��Ӧ����
        end
    end
    R_blocks = 2;%�зֿ�
    C_blocks = 4;%�зֿ�
    sumBlocks = R_blocks*C_blocks;%�ֿܷ���Ŀ
    LeftUp_Corner = zeros(sumBlocks,2);%ÿһ�ֿ����Ͻǵ�����
    rowsLen = floor((rr-2*radius)/R_blocks);%�ֿ��
    colsLen = floor((cc-2*radius)/C_blocks);%�ֿ��
    index = 1;
    for p = 1:R_blocks%�õ�ÿ���ֿ�����Ͻǵ�����
        for q = 1:C_blocks
            LeftUp_Corner(index,:) = [(p-1)*rowsLen+1 (q-1)*colsLen+1];
            index = index+1;
        end
    end
    subImgs = zeros(sumBlocks,rowsLen,colsLen);%sumBlocks����С��ͬ��ͼ
    bin = radius*8*(radius*8-1)+3;%ֱ��ͼbin����/�����radius=1ʱbin=59
    totalBin = bin*sumBlocks;%����ͼ���ֱ��ͼbin����,59*8
    totalHist = zeros(totalBin,1);%����ͼ���ֱ��ͼ��ֵ
    tempImg = zeros(rowsLen,colsLen);
    for m = 1:sumBlocks
        subImgs(m,:,:) = SUBImg(LBP_Img,LeftUp_Corner(m,1),rowsLen,LeftUp_Corner(m,2),colsLen);%��ȡÿ��ͼ��ֿ�
        tempImg(:,:) = subImgs(m,:,:);
        tempHist = Hist(tempImg,bin);%ͳ��ÿ��ͼ��ֿ��ֱ��ͼ
        totalHist((m-1)*bin+1:m*bin) = tempHist;% ����LBPֱ��ͼ
    end
    totalHist=totalHist/sum(totalHist); % ����LBPֱ��ͼ��һ��
    %����ֱ��ͼ����ͼ
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

    function subImgs = SUBImg(img,rowsPos,rowsLen,colsPos,colsLen)%��ͼ���зָ��ָ����С��
%         rowsPos���ֿ����Ͻǵ���ԭͼ�е�������
%         rowslength���ֿ�ߣ�
%         colsFirst���ֿ����Ͻǵ���ԭͼ�е�������
%         colslength���ֿ��
        subImgs = zeros(rowsLen,colsLen,'uint8');
        for i = 1:rowsLen
            for j = 1:colsLen
                subImgs(i,j) = img(rowsPos+i-1,colsPos+j-1);
            end
        end
    end

    function LBPdata = LBPcode(img,i,j,radius)%����ĳһ���ص��LBP code,8*radius�������LBP����,��ת���䴦��uniformģʽ��ά
        %Բ��LBP����ֵ�ļ���
        neighbors = radius*8;%����������radius=1ʱ�ǰ�����
        data = zeros(neighbors,2);
        %��ȡ�������ص�ĻҶ�ֵ
        center = img(i,j);
        LBPdata  = 0;%�����ص��LBPֵ
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
            %�������������ĵ������ƫ����rx��ry
            rx = radius*cos(2*pi*(n-1)/neighbors);%pi:��
            ry = -radius*sin(2*pi*(n-1)/neighbors);
            %˫���Բ�ֵ
            %�Բ�����ƫ�����ֱ��������ȡ��
            x1 = floor(rx);%����С�ڻ���ڸ���ֵ���������
            x2 = round(rx);%���ش��ڻ���ڸ���ֵ����С����
            y1 = floor(ry);
            y2 = round(ry);
            %������ƫ����ӳ�䵽0-1֮��
            tx = rx-x1;
            ty = ry-y1;
            %����0-1֮��x,y��Ȩ�ؼ��㹫ʽ����Ȩ�أ�Ȩ�����������λ���޹أ��������Ĳ�ֵ�й�
            w1 = (1-tx)*(1-ty);
            w2 = tx*(1-ty);
            w3 = (1-tx)*ty;
            w4 = tx*ty;
             %����˫���Բ�ֵ�����n��������ĻҶ�ֵ
            data(n) = img(i+y1,j+x1)*w1+img(i+y2,j+x1)*w2+img(i+y1,j+x2)*w3+img(i+y2,j+x2)*w4;
            %��Ӧ��LBPֵͨ����λ���
            LBPdata = bitshift(LBPdata,1,Data_type);%��Dtype���ͽ���λ����1
            if data(n)>center%�����������صĻҶ�ֵ
                LBPdata = bitor(LBPdata,1,Data_type);%��Dtype���ͽ���λ��1
            end
        end
        %������ת���䴦��
        minValue = LBPdata;
        for n = 1:neighbors
            %ѭ������
            temp = bitor(bitshift(LBPdata,n,Data_type),bitshift(LBPdata,n-neighbors,Data_type));
            if temp<minValue
                minValue = temp;
            end
        end
        LBPdata = minValue;   
    end

    function table = uniformTable(neighbors)%����LBPuniformģʽ����ֵ
        %neighbors=8ʱ��58�������1��������
        temp = 1;
        table = zeros(1,neighbors);
        total = 2^neighbors;
        for n = 0:total-1
            if getChangeTimes(n,neighbors) < 3%Ҫ���������С�ڵ���2
                table(n+1) = temp;%table[1]��ӦLBPֵΪ0��uniformģʽ
                temp = temp+1;
            end
        end
    end

    function count = getChangeTimes(data,neighbors)%�ж��������
        count = 0;
        binaryCode = dec2bin(data,neighbors);%dec2binʮ����ת�����ƣ��ַ������ʾ
        dataLen = length(binaryCode);
        for n = 2:dataLen
            if binaryCode(n) ~= binaryCode(n-1)%��ǰλΪǰһλȡ������������
                count = count+1;
            end
        end
        
    end
end