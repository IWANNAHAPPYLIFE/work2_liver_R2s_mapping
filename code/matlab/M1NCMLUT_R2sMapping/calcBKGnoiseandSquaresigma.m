function [sigma,squaresigma] = calcBKGnoiseandSquaresigma(IMGs,fudgeFactor, pxlsDel,dilatePxls)
global Ncoils;
I = IMGs(:,:,1);
[junk threshold] = edge(I, 'sobel');
BWs = edge(I,'sobel', threshold * fudgeFactor);
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWsdil = imdilate(BWs, [se90 se0]);
BWdfill = imfill(BWsdil, 'holes');
seD = strel('disk',1);
BWfinal = imerode(BWdfill,seD);
BWfinal = imerode(BWfinal,seD);
mask = double(BWfinal);
[M N] = size(mask);
SE = strel('disk',dilatePxls);
BW1 = imdilate(mask,SE);
BW2 = ones(M, N) - BW1;
BW2(1:pxlsDel,:) = 0;
BW2(M,:) = 0;
BW2(:,1:pxlsDel) = 0;
BW2(:,N) = 0;
MASKs_BKG = repmat(BW2, [1 1 size(IMGs,3)]);

IMGs_BKG = IMGs .* MASKs_BKG;
IMGs_Select = I + 150.*BW2;
% figure
% subplot(121),imshow(IMGs_BKG(:,:,1),[]);
% subplot(122),imshow(IMGs_Select,[]);
IMGs_squareBKG = (IMGs.^2).* MASKs_BKG;
sigma = sum(sum(sum(IMGs_BKG))) / sum(sum(sum(MASKs_BKG)));
xishu=1;
for i=2*Ncoils-1:-2:1
    xishu=xishu*i;
end
xishu=xishu/2^(Ncoils-1)/gamma(Ncoils);
sigma = sigma / sqrt(0.5*pi)/xishu;
squaresigma = sum(sum(sum(IMGs_squareBKG))) / sum(sum(sum(MASKs_BKG)))/(2*Ncoils);


