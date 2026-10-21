clear;clc;
global sigma;
% INDEX = [3 13 15 18 37 39 53 56 60 65 70 72 81 82 83 96 106 116 119 129];
% INDEX = [134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170];
INDEX = [74 171 172 174 175 176 177 179 180 182 183 184 185 186 187 188 189 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 209 210 211 212 214 216 217 218 219];
% T2star = [];
% Rsquare = [];
%% 读取图片
for k = 1 : 1
    nfolder = ['F:\data\liver internal dcm\TE=0.9\62\', num2str(INDEX(k))];
    dfiles = dir(nfolder);
    dfiles = dfiles(3 : end);  
    nfiles=length(dfiles);
    DicomFileNo = 0;
    for currentfile = 1 : nfiles
        file_info = dicominfo([nfolder, '\', dfiles(currentfile).name]);
        DicomFileNo = DicomFileNo + 1;
        TE(DicomFileNo) = file_info.EchoTime;
        ImgData(:, :, DicomFileNo) = dicomread(file_info);
        ImgData = double(ImgData);
    end
    %% 计算背景噪声
    [sigma, squaresigma] = calcBKGnoiseandSquaresigma(ImgData, 0.1, 1,8);
    %% NLM
    f=1; 
    t=5; 
    alphaPara =0.4; 
    IMG = NLmeansfilter_RelaxMap(ImgData,t,f,sigma*alphaPara); 
    %% mask
    mask = double(imread(['F:\data\liver internal liver\label\', num2str(INDEX(k)), '.png']));
    mask = mask(:, :, 1);
    mask(mask == 255) = 1;
    mask = logical(mask);
    [Xindexs, Yindexs] = find(mask);
    %% Liver
    figure; 
    imshow(ImgData(:,:,1), []);
    Liver = ImgData(:,:,1) .* mask;
    figure; 
    imshow(Liver, []);
    %% 逐点拟合
    T2smap = zeros(size(IMG, 1),size(IMG, 2));
    for i = 1 : length(Xindexs)
        Xindex = Xindexs(i);
        Yindex = Yindexs(i);
        ydata = squeeze(IMG(Xindex, Yindex, :)); 
        [T2_NCEXP_fixsigma, M0_NCEXP_fixsigma] = calc_T2_NCEXP_fixsigma(TE, ydata');  
        T2smap(Xindex, Yindex) = T2_NCEXP_fixsigma;
    end
    T2s_NCEXP_fixsigma = T2smap;
    R2s_NCEXP_fixsigma = 1000 ./ (T2s_NCEXP_fixsigma + 0.0000000001) ;
    R2s_NCEXP_ROI  = R2s_NCEXP_fixsigma(mask); 
    T2s_NCEXP_ROIm = immultiply(T2s_NCEXP_fixsigma, mask);
    row = size(mask, 1); 
    coloum = size(mask, 2);
    maskroi1 = T2s_NCEXP_ROIm > 0.5;
    maskroi2 = T2s_NCEXP_ROIm <= 0.5&T2s_NCEXP_ROIm > 0;
    R2s_NCEXP_ROI(R2s_NCEXP_ROI > 2000)=[];
    %% FCM
    [~, Un, ~] = fcm(R2s_NCEXP_ROI,2); 
    maxUn = max(Un);
    indexNCEXP1 = find(Un(1, :) == maxUn); 
    indexNCEXP2 = find(Un(2, :) == maxUn);
    if length(indexNCEXP1) > length(indexNCEXP2) 
        indexNCEXP = indexNCEXP1;
    else
        indexNCEXP = indexNCEXP2;
    end
    index_mask = find(maskroi1 == 1);
    pointchoose = index_mask(indexNCEXP);
    index_pointchooseN = zeros(length(pointchoose), 2);
    index_pointchooseN(:, 2) = floor(pointchoose ./ row) + 1; 
    index_pointchooseN(:, 1) = rem(pointchoose, row);
    %% 肝实质
    maskNCEXP = zeros(row, coloum);
    for index=1 : size(index_pointchooseN, 1)
        maskNCEXP(index_pointchooseN(index, 1), index_pointchooseN(index, 2)) = 1;
    end 
    maskNCEXP = (maskNCEXP == 1);
    maskNCEXP = maskNCEXP | maskroi2;
    %% parenchyma
    figure;
    imshow(maskNCEXP, []);
      parenchyma = ImgData(:,:,1) .* maskNCEXP;
      figure; 
      imshow(parenchyma, []);
    %% MP
%     BW = bwareaopen(~maskNCEXP, 2);
%     maskNCEXP0 = ~BW;
%     SE = strel('disk', 1);
%     maskNCEXP0 = imerode(~xor(mask, maskNCEXP0), SE); 
%     maskNCEXP = maskNCEXP0 & mask;
    %% MP_parenchyma
%     figure;
%     imshow(maskNCEXP, []);
%       MP_parenchyma = ImgData(:,:,1) .* ~maskNCEXP;
%       figure; 
%       imshow(MP_parenchyma, []);
%     %% ATF
%     tempdata = reshape(IMG, size(IMG, 1) * size(IMG, 2), size(IMG, 3));
%     ydata2=mean(tempdata(maskNCEXP(:), :));
%     [T2_NCEXP_fixsigmaResu, M0_NCEXP_fixsigmaResu] = calc_T2_NCEXP_fixsigma(TE, ydata2);
%     T2star(k) = T2_NCEXP_fixsigmaResu;
%     %% T2*曲线
% %     x = 0 : 0.2 : 16.5;
%     signal = fun_NCEXP_fixsigma([M0_NCEXP_fixsigmaResu T2_NCEXP_fixsigmaResu], TE);
%     Rs_errors = calcRs_error(ydata2,signal);
%     Rsquare(k) = Rs_errors;
%     curve = fun_NCEXP_fixsigma([M0_NCEXP_fixsigmaResu T2_NCEXP_fixsigmaResu], x);
%     figure
%     set(gcf, 'position', [200 200 450 350])
%     plot(TE, ydata, 'ko');hold on;
%     plot(x, curve, 'r--', 'Linewidth', 2.5 );
%     xlabel('TE(ms)', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%     ylabel('Signal Intensity', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%     clear TE
%     clear ImgData
%     clc;
end