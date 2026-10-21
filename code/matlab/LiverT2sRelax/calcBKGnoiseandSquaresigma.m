function [sigma,squaresigma] = calcBKGnoiseandSquaresigma(IMGs,fudgeFactor, pxlsDel,dilatePxls)

I = IMGs(:,:,1);
[~ ,threshold] = edge(I, 'sobel'); % return the threshold value used in the computation
BWs = edge(I,'sobel', threshold * fudgeFactor); % detect edges using the Soble method; returna binary image; 
se90 = strel('line', 3, 90); % reate a line-shaped structing element with a length of 3 at an angle of 90 
se0 = strel('line', 3, 0);
BWsdil = imdilate(BWs, [se90 se0]); % 沿两个方向进行膨胀
BWdfill = imfill(BWsdil, 'holes'); % fill image regions and hole
seD = strel('disk',1); % disk-shape structing element with a radius of 15
BWfinal = imerode(BWdfill,seD); % 腐蚀
BWfinal = imerode(BWfinal,seD);
mask = double(BWfinal);
[M N] = size(mask);
SE = strel('disk',dilatePxls);
BW1 = imdilate(mask,SE);
BW2 = ones(M, N) - BW1; % inver-mask
BW2(1:pxlsDel,:) = 0;
BW2(M,:) = 0;
BW2(:,1:pxlsDel) = 0;
BW2(:,N) = 0;
MASKs_BKG = repmat(BW2, [1 1 size(IMGs,3)]); % repeat copies in the third dimension
IMGs_BKG = IMGs .* MASKs_BKG;
IMGs_Select = I + 150.*BW2;
% figure
% subplot(121),imshow(IMGs_BKG(:,:,1),[]);
% subplot(122),imshow(IMGs_Select,[]);
IMGs_squareBKG = (IMGs.^2).* MASKs_BKG;
sigma = sum(sum(sum(IMGs_BKG))) / sum(sum(sum(MASKs_BKG)));
sigma = sigma / sqrt(0.5*pi);
squaresigma = sum(sum(sum(IMGs_squareBKG))) / sum(sum(sum(MASKs_BKG)));

