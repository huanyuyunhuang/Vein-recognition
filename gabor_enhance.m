function gabor_Img = gabor_enhance(img,rr,cc)
    gSize = 20;
    orientation = [0 22.5 45 67.5 90 112.5 135 157.5];
    g = gabor(gSize,orientation,'SpatialFrequencyBandwidth',1.6,'SpatialAspectRatio',1);
    Imgs = imgaborfilt(img,g);
    gabor_Img = zeros(rr,cc,'double');
    for i = 1:rr
        for j = 1:cc
            gabor_Img(i,j) = min(Imgs(i,j,:));
        end
    end
    m_n = min(gabor_Img);
    m_n = min(m_n);
    m_x = max(gabor_Img);
    m_x = max(m_x);
    gabor_Img = mat2gray(gabor_Img,[m_n m_x]);
end