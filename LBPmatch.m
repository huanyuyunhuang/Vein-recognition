function LBPScore = LBPmatch(hist1,hist2,totalBin,i)
    LBPScore = 0;
    %�ཻ��
    if i==1
        for i = 1:totalBin
            LBPScore = LBPScore+min([hist1(i),hist2(i)]);
        end
    elseif i==2
    %����ֵ����
        for i = 1:totalBin
            LBPScore = LBPScore+abs([hist1(i)-hist2(i)]);
        end
    %������
    else
        for i=1:totalBin
            if hist1(i)~=0
                   LBPScore=LBPScore+([hist1(i)-hist2(i)])*([hist1(i)-hist2(i)])/hist1(i);
            end
        end
    end
end