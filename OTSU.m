function [thread,yiTa] = OTSU(Img,r,c)%OTSU
    h = (0:255);%1*256 double
    p = zeros(1,256);%1*256 double
    for i = 1:r
        for j = 1:c
            p(Img(i,j)+1) = p(Img(i,j)+1)+1/(r*c);
        end
    end
    p1 = zeros(1,256);%1*256 double
    p1(1) = p(1);
    for i = 2:256
        p1(i) = p1(i-1)+p(i);%0<p1(k)<=1
    end
    m = zeros(1,256);%1*256 double
    m(1) = h(1)*p(1);
    for i = 2:256
        m(i) = m(i-1)+h(i)*p(i);
    end
    mG = m(256);
    sigmaB = zeros(1,256);%1*256 double
    for i = 1:256
        if p1(i)==0 || p1(i)==1
            sigmaB(i) = 0;
        else
            sigmaB(i) = (mG*p1(i)-m(i)).^2/p1(i)/(1-p1(i));
        end
    end
    mx = max(sigmaB);
    indexs = find(sigmaB==mx);
    num = length(indexs);
    thread = 0;
    for i = 1:num
        thread = thread+indexs(i)/num;
    end
    sigmaG = 0;
    for i = 1:256
        sigmaG = sigmaG+(h(i)-mG).^2*p(i);
    end
    yiTa = sigmaB(thread)/sigmaG;
end