function binariedImg = Binarize(oldImg,r,c,thread)
    binariedImg = zeros(r,c,'uint8');
    for i = 1:r
        for j = 1:c
            if oldImg(i,j)>thread
                binariedImg(i,j) = 1;
            end
        end
    end
end