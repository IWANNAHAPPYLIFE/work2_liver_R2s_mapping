function [R2MAP_Truth R2masks] = SimuR2Map2D_nonchi(MapSize,R2s_Truth, M, N, BlockSize)

if BlockSize(2)*max(M,N) > MapSize(2)
    disp('The BlockSize doesnot match the Mapsize')
    return;
end

numofT2s = length(R2s_Truth);

imgtemp = zeros(MapSize(1),MapSize(2));
R2masks = zeros(MapSize(1),MapSize(2),numofT2s);

tempA = R2s_Truth;


temp = ones(BlockSize(1),BlockSize(2));

for ii = 1:M
    for jj = 1:N
        mask = zeros(MapSize(1),MapSize(2));
        mask((ii-1)*BlockSize(1)+1:(ii-1)*BlockSize(1)+BlockSize(1),(jj-1)*BlockSize(2)+1:(jj-1)*BlockSize(2)+BlockSize(2)) = 1;
%         mask = circshift(mask, [round((MapSize - BlockSize*M)/2) round((MapSize - BlockSize*N)/2)]);
%         figure(1);imshow(mask,[]);
        
        R2masks(:,:,(ii-1)*N + jj) = mask(:,:);
        
        imgtemp((ii-1)*BlockSize(1)+1:(ii-1)*BlockSize(1)+BlockSize(1),(jj-1)*BlockSize(2)+1:(jj-1)*BlockSize(2)+BlockSize(2))...
            = temp *tempA(ii,jj);
    end
end

imgtemp = circshift(imgtemp,[0 round((MapSize(2) - BlockSize(2)*N))]);

R2MAP_Truth = imgtemp;

% for iT2 = 1:length(T2s_Truth);
%     BWoutline = bwperim(squeeze(T2masks(:,:,iT2)));
%     temIMG = T2MAP_Truth;
%     temIMG(BWoutline) = 1.5*max(T2s_Truth);
%     figure(2);imshow(temIMG,[]);
% end
