clear;clc;close all;
global global_sigma;
global squaresigma;
global Ncoils;
Ncoils = 4;
global LINEWIDTH;
LINEWIDTH = 1.5;
global WLminValue WLmaxValue
WLminValue = 1; WLmaxValue = 300; %default window/level
global EchoNo PositionOfSeries FileNames
EchoNo = 12; PositionOfSeries = 1; 
FileNames = [];
global  SliderImageNo
SliderImageNo = 1;
colormap gray(256) % view and set current colormap, 256 colors
handles.ROI.exists = 0; % used in order to clear previous ROIs
handles.MultiEchoTE = []; % for T2*/T2 analysis
handles.scrsz = get(0,'ScreenSize'); % determines user's screen size
handles.figures.figure_decay = figure('Visible', 'off'); % create figure window, invisible
handles.SeriesSelected = 0; % select images before playing wit them
handles.ImgData=[];
handles.ImgCp = [];
handles.axis = []; % image range to be shown
handles.defaultPath = ''; % default path for dicom files
handles.patientName = '';
handles.ROI = [];
handles.ROI.NumOfProfiles = 0;
handles.CurrentImg = [];
handles.ROImasksExistFlag = 0;% flag for existed ROI masks
handles.xypflag = 0;
handles.T2s = [];
handles.T2s_Offset = [];
handles.T2s_SQEXP = [];
handles.T2s_SQEXP_fixsigma = [];
handles.T2s_NCEXP = [];
handles.T2s_NCEXP_fixsigma = [];
handles.MeanBKnoise = 0; 
handles.MeanSquaredBKnoise = 0;

%% load dicom image
P = fileparts(mfilename('fullpath')); %% fileparts: get parts of file name; mfilename: 返回当前.m文件所在文件夹的路径
nfolder=uigetdir(P,'Select DICOM Directory');% 显示对话框让用户选择一文件夹，并返回其路径, P: start path
colormap gray(256)
handles.defaultPath = nfolder;
handles.dfolder = nfolder;
dfiles = dir(handles.dfolder); % 显示详细信息，是一个结构体, list folder contents
file_1 = dfiles(3); % 第三个参数才是所需的第一个数据文件名
img = dicomread(strcat(nfolder,'/',file_1.name)); % strcat: concatenate strings horizontally
handles.imageSize = size(img); 
% handles.CurrentImg = img;
% % axes(handles.MainImg); % set(gcf,'CurrentAxes',handles.MainImg);
% set(gca,'Units','Pixels'); % gca: current axes or chart; distance in pixels are independent of system
% handles.axis = [0 handles.imageSize(2) 0 handles.imageSize(1)]; % axis limits
% axis([0 handles.imageSize(2) 0 handles.imageSize(1)]); % set axis limits
% axis ij % Reverse the coordinate system so that the y values increase from top to bottom.
% % global FileNames SeriesInfo    % save file names, and series info
dfiles = dfiles(3:end);                   % avoid . and ..
FileNames = char (dfiles.name); % ave file names, convert into a single character array
nfiles=length(dfiles);

% s = [num2str(nfiles) ' files in: ' handles.dfolder];
% set(handles.NofFiles,'String', s);% show the number of files in the current folder
% set(handles.ListBox,'String',FileNames,'value',1); % list files, i need to change here
% display series in table
SeriesInfo = cell(100,9); % sets the variable data, which governs one row with 7 columns, cell: create cell array of empty matrices
% loop over all files to sort out series information, number,
% description,position of the series, number of images etc, total number of series
DicomFileNo = 0; No_of_Series = 0;

% read each dicom file
hWaitBar = waitbar(0,'Reading Dicom Series ...');
for currentfile = 1:length(dfiles) % set variable currentfile to each file in the directory
    waitbar(currentfile/length(dfiles),hWaitBar)
    try
        dicominfo([handles.dfolder,'\', dfiles(currentfile).name]); % read dicom info of current file
    catch
        disp ('apparently not a DICOM file');
        continue;
    end
    file_info = dicominfo([handles.dfolder,'\', dfiles(currentfile).name]);%read dicom info of current file
    DicomFileNo = DicomFileNo + 1;
    handles.ImgData(:,:,DicomFileNo) = dicomread(file_info);
%     axes(handles.MainImg);
%     set(gca,'Units','Pixels');
    handles.axis = [0 handles.imageSize(2) 0 handles.imageSize(1)];
%     axis([0 handles.imageSize(2) 0 handles.imageSize(1)]);
%     axis ij    
%     imshow(handles.ImgData(:,:,DicomFileNo),[]);
    handles.MultiEchoTE(DicomFileNo) = file_info.EchoTime; % record TE
    if  ( DicomFileNo == 1 )     % case for 1st DICOM file
        old_series = file_info.SeriesNumber; % if it's the first image from the first series, then define old_series as the series number
        No_of_Images = 1;
        No_of_Series = 1;
    end
    if ( (old_series ~= file_info.SeriesNumber) )%|| (old_SeriesTime ~= file_info.SeriesTime) ) % detect if it is a new series
        No_of_Images = 1; % reset number of images
        No_of_Series = No_of_Series+1;% then increase by one and progressive to next series
        old_series = file_info.SeriesNumber;
    end % if old_series, new series
    if (No_of_Images == 1) % update the SeriesInfo for 1st image of the series
        try
            name = strcat(file_info.PatientName.FamilyName,'_',file_info.PatientName.GivenName); %makes the two string patient name (first and last)
        catch
            try
                name = strcat(file_info.PatientName.FamilyName); % makes the two string patient name (first and last) into one string
            catch
                name='UNKNOWN';
            end
        end
        SeriesInfo(No_of_Series,1) = cellstr(num2str (file_info.SeriesDescription)); % num -> string array -> cell array
        SeriesInfo(No_of_Series,2) = cellstr(num2str (file_info.SeriesNumber));
        SeriesInfo(No_of_Series,4) = cellstr(name); % set column 1 to name
        SeriesInfo(No_of_Series,5) = cellstr(dfiles(currentfile).name); %this gives the actual filename which enables the string compare with the list of
        SeriesInfo(No_of_Series,6) = cellstr(num2str (file_info.StudyDate));
        SeriesInfo(No_of_Series,7) = cellstr(num2str (file_info.Filename));
        SeriesInfo(No_of_Series,8) = cellstr(num2str (file_info.SeriesTime));
        SeriesInfo(No_of_Series,9) = cellstr(num2str (currentfile) );
    end % No_of_Images, 1st file
    SeriesInfo(No_of_Series,3) = cellstr(num2str (No_of_Images)); % update every file
    No_of_Images = No_of_Images+1;
end % the last file
%No_of_Images = No_of_Images-1;
handles.patientName = name;
% display in the table
if (No_of_Series > 0)
    SeriesInfo= SeriesInfo(1:No_of_Series,:);
end
%size(SeriesInfo)
% set(handles.table,'Data',SeriesInfo);
handles.ImgCp = handles.ImgData;
close (hWaitBar);

%% ROI set
AddROIFlag = 1;

while(AddROIFlag)
    
    handles.ROI.NumOfProfiles = handles.ROI.NumOfProfiles + 1;
    indx = handles.ROI.NumOfProfiles;
    img  = handles.ImgData(:,:,5);
    figure
    imshow(img,[]);
    [mask ,points,~] = roispline(img,handles.axis);
    if size(points,1) <3
        msgbox('the number of points is less than 3', 'r');
        handles.ROI.NumOfProfiles = handles.ROI.NumOfProfiles - 1;
    else
        handles.ROI.Profiles(indx).points = points;
        handles.ROI.Profiles(indx).mask   = mask;
    end
    set(gcf, 'Pointer', 'arrow'); % pointer symbol
    iROI = handles.ROI.NumOfProfiles;
    if iROI == 1
        handles.ROI.mask{1} = handles.ROI.Profiles(1).mask;
        handles.ROI.indicies{1} = find(handles.ROI.mask{1}); % find nonzero elements in mask image
        handles.ROI.mask{2} = handles.ROI.mask{1};
        handles.ROI.indicies{2} = find(handles.ROI.mask{2});
        handles.ROImasksExistFlag = 1;
    end
    if iROI > 1
        handles.ROI.mask{iROI+1}   = handles.ROI.mask{iROI};
        handles.ROI.mask{iROI}     = handles.ROI.Profiles(iROI).mask;
        handles.ROI.indicies{iROI} = find(handles.ROI.mask{iROI});
        handles.ROI.mask{iROI+1}   = handles.ROI.mask{iROI}|... % |:或，取并集？
            handles.ROI.mask{iROI+1};
        handles.ROI.indicies{iROI+1} = find(handles.ROI.mask{iROI+1});
        handles.ROImasksExistFlag = 1;
    end
    if iROI ==0
        handles.ROI.mask = [];
        handles.ROI.indicies = [];
        handles.ROImasksExistFlag = 0;
    end
    close
    AddROIFlag = input('add more roi? (1/0)');
end

ROIsMask = handles.ROI.mask{handles.ROI.NumOfProfiles+1};
ROIsImages = immultiply(handles.ImgData,repmat(ROIsMask,[1,1,No_of_Images-1]));
%% ATF

if handles.ROImasksExistFlag  == 0
    msgbox('ROI does not exist, Please delinate it first!')
    return;
end
IMGs = handles.ImgData;
[global_sigma,squaresigma] = calcBKGnoiseandSquaresigma(IMGs,0.1, 1,8);
Ncoils = 4;
iROI = handles.ROI.NumOfProfiles+1;
ROIindicies = handles.ROI.indicies{iROI};
tempdata = reshape(handles.ImgData, size(handles.ImgData,1)*size(handles.ImgData,2), size(handles.ImgData,3)); % 3D -> 2D
handles.ROI.MultiEchoMeanData = mean( tempdata(ROIindicies, :) );
handles.ROI.MultiEchoStdData = std( double( tempdata(ROIindicies,: ) ) );
squareddata = tempdata .^2;
handles.ROI.MultiEchoMeanSquaredData = mean( squareddata(ROIindicies, :) );
try
    xdata=handles.MultiEchoTE;
    ydata=handles.ROI.MultiEchoMeanData;
    squaredydata = handles.ROI.MultiEchoMeanSquaredData;
catch
    msgbox('Please select the images you want to analysis')
    return
end
curve_x = 0 : 0.2: max(xdata)+0.4;
% Cmodel = get(handles.ModelChooseGBtn,'UserData');
Cmodel =input('input fitting model (1/AutoTruncation, 2/Offset, 3/SQEXP, 4/SQEXPsigma, 5/NCEXP, 6/NCEXPsigma) : ');

% [T2_AutoTrunc, M0_AutoTrunc, numofTrunc] = calc_T2_AutoTrunc(xdata, ydata);
% signal_fitted_AutoTrunc = M0_AutoTrunc*exp(-xdata/T2_AutoTrunc);
% Rs_errors_AutoTrunc = calcRs_error(ydata(1:end-numofTrunc),signal_fitted_AutoTrunc(1:end-numofTrunc)); % error after autotrunc
% fittedcurve_AutoTrunc = M0_AutoTrunc*exp(-curve_x/T2_AutoTrunc);
% 
% [T2_Offset, M0_Offset, Offset] = calc_T2_Offset(xdata, ydata);
% signal_fitted_Offset = fun_T2_Offset([M0_Offset T2_Offset Offset], xdata);
% Rs_errors_Offset = calcRs_error(ydata,signal_fitted_Offset);
% fittedcurve_Offset = fun_T2_Offset([M0_Offset T2_Offset Offset], curve_x); % fitted curve
% 
% [T2_Mon, M0_Mon] = calc_T2(xdata, ydata);
% signal_fitted_Mon = fun_T2([M0_Mon T2_Mon], xdata);
% Rs_errors_Mon = calcRs_error(ydata,signal_fitted_Mon);
% fittedcurve_Mon = fun_T2([M0_Mon T2_Mon], curve_x);  
% 
% figure
% plot(xdata, ydata, 'ko');hold on;
% plot(curve_x, fittedcurve_AutoTrunc, 'r--', 'Linewidth', 2.5 );
% plot(xdata(end-numofTrunc+1:end),ydata(end-numofTrunc+1:end),'b*');
% legend('Measured data', 'Truncation', 'Deleted points for Truncation');
% 
% figure
% plot(xdata, ydata, 'ko');hold on;
% plot(curve_x, fittedcurve_Offset,'r--', 'Linewidth', 2.5 );
% legend('Measured data', 'Offset');
% 
% figure
% plot(xdata, ydata, 'ko');hold on;
% plot(curve_x, fittedcurve_Mon,'b--', 'Linewidth', 2.5 );
% legend('Measured data', 'Monoexponential');

            
if ~isempty(Cmodel)
    switch Cmodel
        case 1
            %     [T2 M0] = calc_T2(xdata, ydata);
            %     t_Monoexp = toc;
            %     signal_fitted = M0*exp(-xdata/T2);
            %     Rs_errors_Monoexp = calcRs_error(ydata,signal_fitted);
            %     fittedcurve_Monoexp = M0*exp(-curve_x/T2);
            %     handles.ROI.ABF_MonoexpR2s(iROI) = 1000/T2;
            %     handles.ROI.ABF_MonoexpErrors(iROI) = Rs_errors_Monoexp ;
            
            [T2_AutoTrunc, M0_AutoTrunc, numofTrunc] = calc_T2_AutoTrunc(xdata, ydata);
            signal_fitted = M0_AutoTrunc*exp(-xdata/T2_AutoTrunc);
            Rs_errors_AutoTrunc = calcRs_error(ydata(1:end-numofTrunc),signal_fitted(1:end-numofTrunc)); % error after autotrunc
            fittedcurve_AutoTrunc = M0_AutoTrunc*exp(-curve_x/T2_AutoTrunc); % fitted curve
            handles.ROI.ABF_AutoTruncR2s = 1000/T2_AutoTrunc; % result R2*
            handles.ROI.ABF_AutoTruncErrors = Rs_errors_AutoTrunc ;
            figure
            plot(xdata, ydata, 'ko');hold on;
            plot(curve_x, fittedcurve_AutoTrunc, 'r--', 'Linewidth', 2.5 );
            plot(xdata(end-numofTrunc+1:end),ydata(end-numofTrunc+1:end),'b*')
            xlabel('TE(ms)', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('Signal Intensity', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%             legend('Measured data',['Trunction T2* =' num2str(T2_AutoTrunc,'%.2f') 'ms'],...
%                 'Deleted points for Trunction',...
%                 'color','k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%             set(handles.ATF_T2s_edit,'String',num2str(1000./T2));
        case 2
            [T2_Offset, M0_Offset, Offset] = calc_T2_Offset(xdata, ydata);
            signal_fitted = fun_T2_Offset([M0_Offset T2_Offset Offset], xdata);
            Rs_errors_Offset = calcRs_error(ydata,signal_fitted);
            fittedcurve_Offset = fun_T2_Offset([M0_Offset T2_Offset Offset], curve_x); % fitted curve
            handles.ROI.ABF_OffsetR2s = 1000/T2_Offset; % result R2*
            handles.ROI.ABF_OffsetErrors = Rs_errors_Offset;
            
            figure
            set(gcf,'position',[200 200 450 350])
            plot(xdata, ydata, 'ko');hold on;
            plot(curve_x, fittedcurve_Offset,'r--', 'Linewidth', 2.5 );
            
            xlabel('TE(ms)', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('Signal Intensity', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%             legend('Measured data',['Offset T2* =' num2str(T2_Offset,'%.2f') 'ms'],...
%                 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%             set(handles.ATF_T2s_edit,'String',num2str(1000./T2_Offset));
        case 3
            [T2_SQEXP, M0_SQEXP, sigma_SQEXP] = calc_T2_SQEXP(xdata, squaredydata);
            signal_fitted = fun_SQEXP([M0_SQEXP T2_SQEXP sigma_SQEXP], xdata);
            Rs_errors_SQEXP = calcRs_error(squaredydata,signal_fitted);
            fittedcurve_SQEXP = fun_SQEXP([M0_SQEXP T2_SQEXP sigma_SQEXP], curve_x);
            handles.ROI.ABF_SQEXPR2s = 1000/T2_SQEXP;
            handles.ROI.ABF_SQEXPErrors = Rs_errors_SQEXP ;
            figure
            set(gcf,'position',[200 200 450 350])
            plot(xdata, ydata, 'ko');hold on;
            plot(curve_x, fittedcurve_SQEXP,'r--', 'Linewidth', 2.5 );
            xlabel('TE(ms)', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('Signal Intensity', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%             legend('Measured data',['SQEXP T2* =' num2str(T2_SQEXP,'%.2f') 'ms'],...
%                 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%             set(handles.ATF_T2s_edit,'String',num2str(1000./T2_SQEXP));
        case 4
            [T2_SQEXP_fixsigma, M0_SQEXP_fixsigma] = calc_T2_SQEXP_fixsigma(xdata, squaredydata);
            signal_fitted = fun_SQEXP_fixsigma([M0_SQEXP_fixsigma T2_SQEXP_fixsigma], xdata);
            Rs_errors_SQEXP_fixsigma = calcRs_error(squaredydata,signal_fitted);
            fittedcurve_SQEXP_fixsigma = fun_SQEXP_fixsigma([M0_SQEXP_fixsigma T2_SQEXP_fixsigma], curve_x);
            handles.ROI.ABF_SQEXP_fixsigmaR2s = 1000/T2_SQEXP_fixsigma;
            handles.ROI.ABF_SQEXP_fixsigmaErrors = Rs_errors_SQEXP_fixsigma ;
            figure
            set(gcf,'position',[200 200 450 350])
            plot(xdata, ydata, 'ko');hold on;
            plot(curve_x, fittedcurve_SQEXP_fixsigma, 'r--', 'Linewidth', 2.5 );
            xlabel('TE(ms)', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('Signal Intensity', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%             legend('Measured data',['SQEXP-fixsigma T2* =' num2str(T2_SQEXP_fixsigma,'%.2f') 'ms'],...
%                 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%             set(handles.ATF_T2s_edit,'String',num2str(1000./T2_SQEXP_fixsigma));
        case 5
            [T2_NCEXP, M0_NCEXP, sigma_NCEXP] = calc_T2_NCEXP(xdata, ydata);
            signal_fitted = fun_NCEXP([M0_NCEXP T2_NCEXP sigma_NCEXP], xdata);
            Rs_errors_NCEXP = calcRs_error(ydata,signal_fitted);
            fittedcurve_NCEXP = fun_NCEXP([M0_NCEXP T2_NCEXP sigma_NCEXP], curve_x);
            handles.ROI.ABF_NCEXPR2s = 1000/T2_NCEXP;
            handles.ROI.ABF_NCEXPErrors = Rs_errors_NCEXP ;
            figure
            set(gcf,'position',[200 200 450 350])
            plot(xdata, ydata, 'ko');hold on;
            plot(curve_x, fittedcurve_NCEXP, 'r--', 'Linewidth', 2.5 );
            xlabel('TE(ms)', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('Signal Intensity', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%             legend('Measured data',['NCEXP-fixsigma T2* =' num2str(T2_NCEXP,'%.2f') 'ms'],...
%                 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%             set(handles.ATF_T2s_edit,'String',num2str(1000./T2_NCEXP));
        case 6
            [T2_NCEXP_fixsigma ,M0_NCEXP_fixsigma ] = calc_T2_NCEXP_fixsigma(xdata, ydata);
            signal_fitted = fun_NCEXP_fixsigma([M0_NCEXP_fixsigma T2_NCEXP_fixsigma], xdata);
            Rs_errors_NCEXP_fixsigma = calcRs_error(ydata,signal_fitted);
            fittedcurve_NCEXP_fixsigma = fun_NCEXP_fixsigma([M0_NCEXP_fixsigma T2_NCEXP_fixsigma], curve_x);
            handles.ROI.ABF_NCEXP_fixsigmaR2s = 1000/T2_NCEXP_fixsigma ;
            handles.ROI.ABF_NCEXP_fixsigmaErrors = Rs_errors_NCEXP_fixsigma ;
            figure
            set(gcf,'position',[200 200 450 350])
            plot(xdata, ydata, 'ko');hold on;
            plot(curve_x, fittedcurve_NCEXP_fixsigma,'r--', 'Linewidth', 2.5 );
            xlabel('TE(ms)', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('Signal Intensity', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%             legend('Measured data',['NCEXP-fixsigma T2* =' num2str(T2_NCEXP_fixsigma,'%.2f') 'ms'],...
%                 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%             set(handles.ATF_T2s_edit,'String',num2str(1000./T2_NCEXP_fixsigma));
    end
else
    [T2_NCEXP_fixsigma, M0_NCEXP_fixsigma ] = calc_T2_NCEXP_fixsigma(xdata, ydata);
    signal_fitted = fun_NCEXP_fixsigma([M0_NCEXP_fixsigma T2_NCEXP_fixsigma], xdata);
    Rs_errors_NCEXP_fixsigma = calcRs_error(ydata,signal_fitted);
    fittedcurve_NCEXP_fixsigma = fun_NCEXP_fixsigma([M0_NCEXP_fixsigma T2_NCEXP_fixsigma], curve_x);
    handles.ROI.ABF_NCEXP_fixsigmaR2s = 1000/T2_NCEXP_fixsigma ;
    handles.ROI.ABF_NCEXP_fixsigmaErrors = Rs_errors_NCEXP_fixsigma ;
    figure
    set(gcf,'position',[200 200 450 350])
    plot(xdata, ydata, 'ko');hold on;
    plot(curve_x, fittedcurve_NCEXP_fixsigma, 'r-', 'Linewidth', 2.5 );
    xlabel('TE(ms)', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Signal Intensity', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%     legend('Measured data',['T2* =' num2str(T2_NCEXP_fixsigma,'%.2f') 'ms'],...
%         'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
%     set(handles.ATF_T2s_edit,'String',num2str(1000./T2_NCEXP_fixsigma));
    disp('No model choosed and show NCEXP_fixsigma')
end

%% PWF
% if handles.ROImasksExistFlag  == 0
%     msgbox('ROI does not exist, Please delinate it first!')
%     return;
% end
% global T2mapfilename;
% 
% if isempty(T2mapfilename)
% %     msgbox('T2map has not been loaded.So it may take long time')
%     iROI = handles.ROI.NumOfProfiles+1;
%     ROIindicies = handles.ROI.indicies{iROI};
%     tempdata = reshape(handles.ImgData, size(handles.ImgData,1)*size(handles.ImgData,2), size(handles.ImgData,3));
%     numofpixel = length(ROIindicies); % num of the pixel in ROI
%     
%     handles.ROI.MultiEchoData = tempdata(ROIindicies,:); % extract all pixel data in ROI
%     squareddata = tempdata .^2;
%     handles.ROI.MultiEchoSquaredData = squareddata(ROIindicies,:);
%     try
%         xdata=handles.MultiEchoTE;
%         ydata=handles.ROI.MultiEchoData;
%         squaredydata = handles.ROI.MultiEchoSquaredData;
%     catch
%         msgbox('Please select the images you want to analysis')
%         return
%     end
%     
%     
%     
%     
%     
%     
% 
%     % global_sigma = handles.MeanBKnoise /sqrt(0.5*pi);
%     % squaresigma = handles.MeanSquaredBKnoise;
% %     Cmodel = get(handles.ModelChooseGBtn,'UserData');
% %%
% 
%     Cmodel =input('input fitting model (1/AutoTruncation, 2/Offset, 3/SQEXP, 4/SQEXPsigma, 5/NCEXP, 6/NCEXPsigma) : ');
%     if ~isempty(Cmodel)
%         switch Cmodel
%             case 1
%                 T2_AutoTruncRes  = zeros(numofpixel,1);
%                 M0_AutoTruncRes  = zeros(numofpixel,1);
%                 for i = 1:numofpixel
%                     [T2_AutoTrunc, M0_AutoTrunc, numofTrunc] = calc_T2_AutoTrunc(xdata, ydata(i,:));
%                     signal_fitted = M0_AutoTrunc*exp(-xdata./T2_AutoTrunc);
%                     T2_AutoTruncRes(i) = T2_AutoTrunc;
%                     M0_AutoTruncRes(i) = M0_AutoTrunc;
%                 end
%                 PWF_AutoTruncMeanR2s = mean(1000./T2_AutoTruncRes);
%                 handles.ROI.PWF_AutoTruncMeanR2s = PWF_AutoTruncMeanR2s;
%                 PWF_AutoTruncMedianR2s = median(1000./T2_AutoTruncRes);
%                 handles.ROI.PWF_AutoTruncMedianR2s = PWF_AutoTruncMedianR2s;
% %                 set(handles.PWF_T2s_edit,'String',num2str(PWF_AutoTruncMedianR2s));
%             case 2
%                 T2_OffsetRes  = zeros(numofpixel,1);
%                 for i = 1:numofpixel
%                     [T2_Offset, M0_Offset, Offset] = calc_T2_Offset(xdata, ydata(i,:));
%                     signal_fitted = fun_T2_Offset([M0_Offset T2_Offset Offset], xdata);
%                     T2_OffsetRes(i) = T2_Offset;
%                 end
%                 PWF_OffsetMeanR2s = mean(1000./T2_OffsetRes);
%                 handles.ROI.PWF_OffsetMeanR2s = PWF_OffsetMeanR2s;
%                 PWF_OffsetMedianR2s = median(1000./T2_OffsetRes);
%                 handles.ROI.PWF_OffsetMedianR2s = PWF_OffsetMedianR2s;
% %                 set(handles.PWF_T2s_edit,'String',num2str(PWF_OffsetMedianR2s));
%             case 3
%                 T2_SQEXPRes = zeros(numofpixel,1);
%                 for i = 1:numofpixel
%                     [T2_SQEXP, M0_SQEXP, sigma_SQEXP] = calc_T2_SQEXP(xdata, squaredydata(i,:));
%                     signal_fitted = fun_SQEXP([M0_SQEXP T2_SQEXP sigma_SQEXP], xdata);
%                     T2_SQEXPRes(i) = T2_SQEXP;
%                 end
%                 PWF_SQEXPMeanR2s = mean(1000./T2_SQEXPRes);
%                 handles.ROI.PWF_SQEXPMeanR2s(iROI) = PWF_SQEXPMeanR2s;
%                 PWF_SQEXPMedianR2s = median(1000./T2_SQEXPRes);
%                 handles.ROI.PWF_SQEXPMedianR2s(iROI) = PWF_SQEXPMedianR2s;
% %                 set(handles.PWF_T2s_edit,'String',num2str(PWF_SQEXPMedianR2s));
%             case 4
%                 T2_SQEXPRes_fixsigma = zeros(numofpixel,1);
%                 for i = 1:numofpixel
%                     [T2_SQEXP_fixsigma, M0_SQEXP_fixsigma] = calc_T2_SQEXP_fixsigma(xdata, squaredydata(i,:));
%                     signal_fitted = fun_SQEXP_fixsigma([M0_SQEXP_fixsigma T2_SQEXP_fixsigma], xdata);
%                     T2_SQEXPRes_fixsigma(i) = T2_SQEXP_fixsigma;
%                 end
%                 PWF_SQEXP_fixsigmaMeanR2s = mean(1000./T2_SQEXPRes_fixsigma);
%                 handles.ROI.PWF_SQEXP_fixsigmaMeanR2s(iROI) = PWF_SQEXP_fixsigmaMeanR2s;
%                 PWF_SQEXP_fixsigmaMedianR2s = median(1000./T2_SQEXPRes_fixsigma);
%                 handles.ROI.PWF_SQEXP_fixsigmaMedianR2s(iROI) = PWF_SQEXP_fixsigmaMedianR2s;
% %                 set(handles.PWF_T2s_edit,'String',num2str(PWF_SQEXP_fixsigmaMedianR2s));
%             case 5
%                 T2_NCEXPRes = zeros(numofpixel,1);
%                 for i = 1:numofpixel
%                     [T2_NCEXP, M0_NCEXP, sigma_NCEXP] = calc_T2_NCEXP(xdata, ydata(i,:));
%                     signal_fitted = fun_NCEXP([M0_NCEXP T2_NCEXP sigma_NCEXP], xdata);
%                     T2_NCEXPRes(i) = T2_NCEXP;
%                 end
%                 PWF_NCEXPMeanR2s = mean(1000./T2_NCEXPRes);
%                 handles.ROI.PWF_NCEXPMeanR2s(iROI) = PWF_NCEXPMeanR2s;
%                 PWF_NCEXPMedianR2s = median(1000./T2_NCEXPRes);
%                 handles.ROI.PWF_NCEXPMedianR2s(iROI) = PWF_NCEXPMedianR2s;
% %                 set(handles.PWF_T2s_edit,'String',num2str(PWF_NCEXPMedianR2s));
%             case 6
%                 T2_NCEXPRes_fixsigma = zeros(numofpixel,1);
%                 for i = 1:numofpixel
%                     [T2_NCEXP_fixsigma, M0_NCEXP_fixsigma] = calc_T2_NCEXP_fixsigma(xdata, ydata(i,:));
%                     signal_fitted = fun_NCEXP_fixsigma([M0_NCEXP_fixsigma T2_NCEXP_fixsigma], xdata);
%                     T2_NCEXPRes_fixsigma(i) = T2_NCEXP_fixsigma;
%                 end
%                 PWF_NCEXP_fixsigmaMeanR2s = mean(1000./T2_NCEXPRes_fixsigma);
%                 handles.ROI.PWF_NCEXP_fixsigmaMeanR2s(iROI) = PWF_NCEXP_fixsigmaMeanR2s;
%                 PWF_NCEXP_fixsigmaMedianR2s = median(1000./T2_NCEXPRes_fixsigma);
%                 handles.ROI.PWF_NCEXP_fixsigmaMedianR2s(iROI) = PWF_NCEXP_fixsigmaMedianR2s;
% %                 set(handles.PWF_T2s_edit,'String',num2str(PWF_NCEXP_fixsigmaMedianR2s));
%         end
%     else
%         disp('No model choosed and show NCEXP_fixsigma model');
%         T2_NCEXPRes_fixsigma = zeros(numofpixel,1);
%         for i = 1:numofpixel
%             [T2_NCEXP_fixsigma, M0_NCEXP_fixsigma] = calc_T2_NCEXP_fixsigma(xdata, ydata(i,:));
%             signal_fitted = fun_NCEXP_fixsigma([M0_NCEXP_fixsigma T2_NCEXP_fixsigma], xdata);
%             T2_NCEXPRes_fixsigma(i) = T2_NCEXP_fixsigma;
%         end
%         PWF_NCEXP_fixsigmaMeanR2s = mean(1000./T2_NCEXPRes_fixsigma);
%         handles.ROI.PWF_NCEXP_fixsigmaMeanR2s(iROI) = PWF_NCEXP_fixsigmaMeanR2s;
%         PWF_NCEXP_fixsigmaMedianR2s = median(1000./T2_NCEXPRes_fixsigma);
%         handles.ROI.PWF_NCEXP_fixsigmaMedianR2s(iROI) = PWF_NCEXP_fixsigmaMedianR2s;
% %         set(handles.PWF_T2s_edit,'String',num2str(PWF_NCEXP_fixsigmaMedianR2s));
%     end  
% else
%     load(T2mapfilename)
%     iROI = handles.ROI.NumOfProfiles+1;
%     mask_indicies = handles.ROI.indicies{iROI};
%     T2_MonoexpRes = T2s(mask_indicies);
%     PWF_MonoexpMeanR2s = mean(1000./T2_MonoexpRes);
%     handles.ROI.PWF_MonoexpMeanR2s(iROI) = PWF_MonoexpMeanR2s;
%     PWF_MonoexpMedianR2s = median(1000./T2_MonoexpRes);
%     handles.ROI.PWF_MonoexpMedianR2s(iROI) = PWF_MonoexpMedianR2s;
%     T2_OffsetRes = T2s_Offset(mask_indicies);
%     PWF_OffsetMeanR2s = mean(1000./T2_OffsetRes);
%     handles.ROI.PWF_OffsetMeanR2s(iROI) = PWF_OffsetMeanR2s;
%     PWF_OffsetMedianR2s = median(1000./T2_OffsetRes);
%     handles.ROI.PWF_OffsetMedianR2s(iROI) = PWF_OffsetMedianR2s;
%     T2_SQEXPRes = T2s_SQEXP(mask_indicies);
%     PWF_SQEXPMeanR2s = mean(1000./T2_SQEXPRes);
%     handles.ROI.PWF_SQEXPMeanR2s(iROI) = PWF_SQEXPMeanR2s;
%     PWF_SQEXPMedianR2s = median(1000./T2_SQEXPRes);
%     handles.ROI.PWF_SQEXPMedianR2s(iROI) = PWF_SQEXPMedianR2s;
%     T2_SQEXPRes_fixsigma = T2s_SQEXP_fixsigma(mask_indicies);
%     PWF_SQEXP_fixsigmaMeanR2s = mean(1000./T2_SQEXPRes_fixsigma);
%     handles.ROI.PWF_SQEXP_fixsigmaMeanR2s(iROI) = PWF_SQEXP_fixsigmaMeanR2s;
%     PWF_SQEXP_fixsigmaMedianR2s = median(1000./T2_SQEXPRes_fixsigma);
%     handles.ROI.PWF_SQEXP_fixsigmaMedianR2s(iROI) = PWF_SQEXP_fixsigmaMedianR2s;
%     T2_NCEXPRes = T2s_NCEXP(mask_indicies);
%     PWF_NCEXPMeanR2s = mean(1000./T2_NCEXPRes);
%     handles.ROI.PWF_NCEXPMeanR2s(iROI) =  PWF_NCEXPMeanR2s;
%     PWF_NCEXPMedianR2s = median(1000./T2_NCEXPRes);
%     handles.ROI.PWF_NCEXPMedianR2s(iROI) =  PWF_NCEXPMedianR2s;
%     T2_NCEXPRes_fixsigma = T2s_NCEXP_fixsigma(mask_indicies);
%     PWF_NCEXP_fixsigmaMeanR2s = mean(1000./T2_NCEXPRes_fixsigma);
%     handles.ROI.PWF_NCEXP_fixsigmaMeanR2s(iROI) = PWF_NCEXP_fixsigmaMeanR2s;
%     PWF_NCEXP_fixsigmaMedianR2s = median(1000./T2_NCEXPRes_fixsigma);
%     handles.ROI.PWF_NCEXP_fixsigmaMedianR2s(iROI) = PWF_NCEXP_fixsigmaMedianR2s;
% end




%% SAPE
% % background noise calculation
% [global_sigma,squaresigma] = calcBKGnoiseandSquaresigma(handles.ImgData,0.1, 1,8);
% 
% mask_ROI = handles.ROI.mask{1}; % full liver mask (manual)
% [Xindexs, Yindexs] = find(mask_ROI); % get ROI
% tempdata = handles.ImgData; 
% 
% % NLM filtering
% f=1; % radio of similarity window
% t=5; % radio of search window
% alphaPara =0.4; % for degree of filtering
% IMG = NLmeansfilter_RelaxMap(tempdata,t,f,global_sigma*alphaPara); % filtered images
% 
% FullLiverImagesFiltered = immultiply(IMG,repmat(mask_ROI,[1,1,No_of_Images-1])); % full liver images after filtering
% 
% % NCM fitting
% handles.SAPE.MultiEchoData = IMG;
% handles.SAPE.ROI = mask_ROI;
% xdata=handles.MultiEchoTE;
% T2smap = zeros(size(IMG,1),size(IMG,2));
% for i = 1:length(Xindexs) % pixel wise fitting
%     Xindex = Xindexs(i);
%     Yindex = Yindexs(i);
%     ydata = squeeze(IMG(Xindex,Yindex,:)); % 3D -> 1D
%     [T2_NCEXP_fixsigma, M0_NCEXP_fixsigma] = calc_T2_NCEXP_fixsigma(xdata, ydata');  % fit single pixel, NCEXP
%     T2smap(Xindex,Yindex) = T2_NCEXP_fixsigma;
% end
% 
% % PlotT2sMap(T2smap,handles);
% T2s_NCEXP_fixsigma = T2smap;
% handles.SAPE.T2smap = T2smap;
% R2s_NCEXP_fixsigma = 1000./(T2s_NCEXP_fixsigma+0.0000000001) ; % T2* -> R2*
% R2s_NCEXP_ROI  = R2s_NCEXP_fixsigma(mask_ROI); % ROI; mask_ROI is logical
% 
% T2s_NCEXP_ROIm  = immultiply(T2s_NCEXP_fixsigma,mask_ROI);
% row = size(mask_ROI,1); % 
% coloum = size(mask_ROI,2); % 
% maskroi1 = T2s_NCEXP_ROIm>0.5; % 0/1 image
% maskroi2 = T2s_NCEXP_ROIm<=0.5&T2s_NCEXP_ROIm>0;
% 
% R2s_NCEXP_ROI(R2s_NCEXP_ROI>2000)=[]; % exclude values >2000
% 
% % FCM custering
% [~,Un,~] = fcm(R2s_NCEXP_ROI,2); % Un: fuzzy partition matrix, indicates the degree of the jth data point in the ith cluster % FCM cluster
% maxUn = max(Un); % compare two rows, get the max one
% indexNCEXP1 = find(Un(1, :) == maxUn); % 
% indexNCEXP2 = find(Un(2, :) == maxUn); % 
% if length(indexNCEXP1)>length(indexNCEXP2) % 
%     indexNCEXP = indexNCEXP1;
% else
%     indexNCEXP = indexNCEXP2;
% end
% index_mask = find(maskroi1 == 1);
% pointchoose = index_mask(indexNCEXP);%
% index_pointchooseN = zeros(length(pointchoose),2);
% index_pointchooseN(:,2) = floor(pointchoose./row) +1; %  round toward negative infinity
% index_pointchooseN(:,1) = rem(pointchoose,row);% remainder after division
% maskNCEXP = zeros(row,coloum);
% for index=1:size(index_pointchooseN,1)
%     maskNCEXP(index_pointchooseN(index,1),index_pointchooseN(index,2)) = 1;
% end  % liver parenchyma mask
% 
% % MP
% maskNCEXP = (maskNCEXP==1); % logicalmask, 0/1 image -> logical mask
% maskNCEXP = maskNCEXP|maskroi2; % 2000roi;
% BW = bwareaopen(~maskNCEXP,2); % remove small objects from the ~mask area
% maskNCEXP0 = ~BW; 
% SE = strel('disk',1);
% maskNCEXP0 = imerode(~xor(mask_ROI,maskNCEXP0),SE); % erode image
% maskNCEXPMP = maskNCEXP0&mask_ROI;
% handles.maskNCEXPALM = maskNCEXPMP; % liver paenchyma mask after MP
% 
% LiverParenchymaImages = immultiply(IMG,repmat(maskNCEXPMP,[1,1,No_of_Images-1]));
% LiverParenchymaT2smapping = immultiply(T2smap,maskNCEXPMP);
% 
% % ATF
% tempdata = reshape(IMG, size(IMG,1)*size(IMG,2), size(IMG,3));
% xdata = handles.MultiEchoTE;
% %NCEXP_fixsigma T2s
% ydata4=mean( tempdata(maskNCEXPMP(:), :) ); 
% [T2_NCEXP_fixsigmaResu,~] = calc_T2_NCEXP_fixsigma(xdata, ydata4); % T2*
% 
% R2_NCEXP_fixsigma_median = median(R2s_NCEXP_fixsigma(maskNCEXPMP));
% R2_NCEXP_fixsigma_mean = mean(R2s_NCEXP_fixsigma(maskNCEXPMP));%
% 
% handles.SAPE.R2sABF_R2sPWF_Resu = [1000/T2_NCEXP_fixsigmaResu,... % R2*
%     R2_NCEXP_fixsigma_median];



