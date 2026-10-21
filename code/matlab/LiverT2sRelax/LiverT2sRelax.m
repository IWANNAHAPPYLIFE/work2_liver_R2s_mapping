function varargout = LiverT2sRelax(varargin)
% LIVERT2SRELAX MATLAB code for LiverT2sRelax.fig
%      LIVERT2SRELAX, by itself, creates a new LIVERT2SRELAX or raises the existing
%      singleton*.
%
%      H = LIVERT2SRELAX returns the handle to a new LIVERT2SRELAX or the handle to
%      the existing singleton*.
%
%      LIVERT2SRELAX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LIVERT2SRELAX.M with the given input arguments.
%
%      LIVERT2SRELAX('Property','Value',...) creates a new LIVERT2SRELAX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LiverT2sRelax_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LiverT2sRelax_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LiverT2sRelax

% Last Modified by GUIDE v2.5 13-Jun-2014 10:01:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @LiverT2sRelax_OpeningFcn, ...
    'gui_OutputFcn',  @LiverT2sRelax_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1}) % nargin: number of function input arguments, varargin can accept any number of input arguments
    gui_State.gui_Callback = str2func(varargin{1}); % str2fun: construct funstion handle from character vector, e.g., @ones
end

if nargout % number of function output arguments, 
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before LiverT2sRelax is made visible.
function LiverT2sRelax_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LiverT2sRelax (see VARARGIN)
% addpath(genpath('..\code\'));
global LINEWIDTH;
LINEWIDTH = 1.5;
global WLminValue WLmaxValue
WLminValue = 1; WLmaxValue = 300; %default window/level
global EchoNo PositionOfSeries FileNames
EchoNo = 12; PositionOfSeries = 1; FileNames = [];
global  SliderImageNo
SliderImageNo = 1;
% Choose default command line output for LiverT2sRelax
handles.output = hObject; % figure handle

colormap gray(256) % view and set current colormap, 256 colors
% use push-button callback
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
% Update handles structure
guidata(hObject, handles); 

% UIWAIT makes LiverT2sRelax wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LiverT2sRelax_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
set(gcf,'Units','normalized','OuterPosition',[0 0 1 1]);
%set(gcf, 'Position' ,handles.scrsz)
varargout{1} = handles.output;


% --- Executes on button press in LoadOrgImg.
function LoadOrgImg_Callback(hObject, eventdata, handles)
% hObject    handle to LoadOrgImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ROI = [];
handles.ROI.NumOfProfiles  = 0;
handles.ROImasksExistFlag = 0;% flag for existed ROI masks
handles.xypflag = 0;
handles.MultiEchoTE = []; % for T2*/T2 analysis
handles.SeriesSelected = 0; % select imagesbefore playing wit them
handles.ImgData=[];
handles.ImgCp = [];
handles.CurrentImg = [];
handles.ROI.exists = 0; %used in order to clear previous ROIs
handles.axis = [] ;% image range to be shown
handles.T2s = [];
handles.T2s_Offset = [];
handles.T2s_SQEXP = [];
handles.T2s_SQEXP_fixsigma = [];
handles.T2s_NCEXP = [];
handles.T2s_NCEXP_fixsigma = [];
handles.MeanBKnoise = 0;
handles.MeanSquaredBKnoise = 0;
set(handles.ATF_WL_edit,'String',' ');
set(handles.PWF_WL_edit, 'String',' ');
set(handles.ATF_T2s_edit,'String',' ');
set(handles.PWF_T2s_edit,'String',' ');
global ROImasks;
ROImasks = [];
hold off
P = fileparts(mfilename('fullpath')); %% fileparts: get parts of file name; mfilename: 返回当前.m文件所在文件夹的路径
% P = 'Z:\Feng_Meiyan\LiverT2starData\';
nfolder=uigetdir(P,'Select DICOM Directory');% 显示对话框让用户选择一文件夹，并返回其路径, P: start path
if ~ischar(nfolder)
    disp('no valid Directory selected.')
    return;
end
cla(handles.LiverROI); % delelte graphics object from LiverROI
axes(handles.LiverROI) % create Cartesian axes
cbfreeze('off'); % freeze the colormap of a colorbar
colorbar('off');
colormap gray(256)
handles.defaultPath = nfolder;
handles.dfolder = nfolder;
dfiles = dir(handles.dfolder); % 显示详细信息，是一个结构体, list folder contents
file_1 = dfiles(3); % 第三个参数才是所需的第一个数据文件名
img = dicomread(strcat(nfolder,'/',file_1.name)); % strcat: concatenate strings horizontally
handles.imageSize = size(img); 
handles.CurrentImg = img;
axes(handles.MainImg); % set(gcf,'CurrentAxes',handles.MainImg);
set(gca,'Units','Pixels'); % gca: current axes or chart; distance in pixels are independent of system
handles.axis = [0 handles.imageSize(2) 0 handles.imageSize(1)]; % axis limits
axis([0 handles.imageSize(2) 0 handles.imageSize(1)]); % set axis limits
axis ij % Reverse the coordinate system so that the y values increase from top to bottom.
global FileNames SeriesInfo    % save file names, and series info
dfiles = dfiles(3:end);                   % avoid . and ..
FileNames = char (dfiles.name); % ave file names, convert into a single character array
nfiles=length(dfiles);
if nfiles<1
    disp('no files available.')
    return;
end
s = [num2str(nfiles) ' files in: ' handles.dfolder];
set(handles.NofFiles,'String', s);% show the number of files in the current folder
set(handles.ListBox,'String',FileNames,'value',1); % list files, i need to change here
% display series in table
SeriesInfo = cell(100,9); % sets the variable data, which governs one row with 7 columns, cell: create cell array of empty matrices
% loop over all files to sort out series information, number,
% description,position of the series, number of images etc, total number of series
DicomFileNo = 0; No_of_Series = 0;
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
    axes(handles.MainImg);
    set(gca,'Units','Pixels');
    handles.axis = [0 handles.imageSize(2) 0 handles.imageSize(1)];
    axis([0 handles.imageSize(2) 0 handles.imageSize(1)]);
    axis ij
    
    imshow(handles.ImgData(:,:,DicomFileNo),[]);
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
        SeriesInfo(No_of_Series,9) = cellstr( num2str (currentfile) );
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
set(handles.table,'Data',SeriesInfo);
handles.ImgCp = handles.ImgData;
close (hWaitBar);
guidata(hObject, handles);

ListBox_Callback(hObject, eventdata, handles)
global T2mapfilename;
% try
%     load(strcat(nfolder,'/T2s_allMAPs.mat'))
%     T2mapfilename = strcat(nfolder,'/T2s_allMAPs.mat');
%     handles.T2s = reshape(T2s,handles.imageSize(1),handles.imageSize(2));
%     handles.T2s_Offset = reshape(T2s_Offset,handles.imageSize(1),handles.imageSize(2));
%     handles.T2s_SQEXP = reshape(T2s_SQEXP,handles.imageSize(1),handles.imageSize(2));
%     handles.T2s_SQEXP_fixsigma = reshape(T2s_SQEXP_fixsigma,handles.imageSize(1),handles.imageSize(2));
%     handles.T2s_NCEXP = reshape(T2s_NCEXP,handles.imageSize(1),handles.imageSize(2));
%     handles.T2s_NCEXP_fixsigma = reshape(T2s_NCEXP_fixsigma,handles.imageSize(1),handles.imageSize(2));
%     PlotT2sMap(handles.T2s_NCEXP_fixsigma,handles);
% catch
%     msgbox('There is no T2*map')
% end
guidata(hObject, handles); %updates the handles



%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in ListBox.
function ListBox_Callback(hObject, eventdata, handles)
% hObject    handle to ListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListBox
global LINEWIDTH;
fname = get(handles.ListBox,'String'); % 12*名字长度的char类型
fname = fname(get(handles.ListBox,'value'),:);
try
    metadata = dicominfo([handles.dfolder '\' fname]);
catch
    disp ('apparently not a DICOM file');
    return
end
img = dicomread([handles.dfolder '\' fname]);
handles.imageSize = size(img);
handles.CurrentImg = img;
axes(handles.MainImg);
set(handles.MainImg,'UserData',img);
set(gca,'Units','Pixels');
handles.axis = [0 handles.imageSize(2) 0 handles.imageSize(1)];
axis([0 handles.imageSize(2) 0 handles.imageSize(1)]);
axis ij
guidata(hObject, handles);
%         load(strcat(handles.dfolder,'/T2sLiverLargeMask1.mat'))
%         mask_ROI = LiverLargeMask{1};
%         img_ROIm = immultiply(img,mask_ROI);
%        img=img_ROIm(9:62,19:81);
PlotImage(img, handles);
if handles.ROI.NumOfProfiles >0;
    for indx = 1:handles.ROI.NumOfProfiles
        handles.ROI.Profiles(indx).line = ...
            line(handles.ROI.Profiles(indx).points(:,1),handles.ROI.Profiles(indx).points(:,2),...
            'Color','yellow','LineWidth',LINEWIDTH); % plot line using vector data
    end
end
guidata(hObject, handles); %updates the handles


% --- Executes during object creation, after setting all properties.
function ListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc % determine if version is for Windows (PC) platform
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));
end


function PlotImage(img,handles)
global MyHandle
axes(handles.MainImg);
set(gca,'Units','Pixels');
r =axis; % lim = axis 返回当前坐标区的 x 轴和 y 坐标轴范围。[xmin xmax ymin ymax]
axis([r(1) r(2) r(3) r(4)]);axis equal;axis ij % equal: 沿每个坐标轴使用相同的数据单位长度
tol = 0.01; % [0.01 0.99]
lowhigh = stretchlim(img, tol);
lowhigh = lowhigh * 65535;
lowhigh = lowhigh .';
colormap gray(256);
MyHandle = imagesc(img,lowhigh); %imshow(img, [WLminValue, WLmaxValue], 'InitialMagnification','fit');
%colormap gray(256);
%freezeColors;
axis(handles.axis);axis equal;axis ij
guidata(MyHandle, handles);
return % -- End PlotImage


% --- Executes when selected cell(s) is changed in table.
function table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
global PositionOfSeries EchoNo  FileNames SeriesInfo
hold off;
Selection = eventdata.Indices;
TableData = get(hObject,'Data');
if ( numel(Selection) == 0 ) % the selection is lost during updating, do not know how to handle it yet, numel: number of array elements
    disp('Updating Table');
    return
end
Selection = Selection(1);
if (  Selection > size(SeriesInfo,1))
    msgbox('Please choose a valid Series!','r')
    return
end
handles.SeriesSelected = Selection; % series changed?
handles.ImgData = []; % to store image  data of the selceted series
handles.MultiEchoTI=[];
handles.MultiEchoTE=[];% initialisation
handles.ROI = [];
handles.ROI.NumOfProfiles = 0;
handles.ROI.Profiles = [];
handles.ROImaskssExistFlag = 0;
handles.ROI.exists = 0; %used in order to clear previous ROIs
guidata(hObject, handles);
handles.xypflag = 0;
cla(handles.MainImg) % clear axes
cla(handles.LiverROI)
axes(handles.LiverROI)
cbfreeze('off');
colorbar('off');
EchoNo = TableData (Selection, 3);
PositionOfSeries = TableData (Selection, 9);
for EchoLoop = 1:str2double(char(EchoNo))
    fname = FileNames(str2num(char(PositionOfSeries))+EchoLoop-1, :);
    fname = [handles.dfolder,'\',fname] ;
    try
        fname = char (fname);
        metadata = dicominfo(fname);
    catch
        disp ('Apparently not DICOM series');
        return
    end
    img = dicomread(fname);
    %     axes(handles.MainImage);
    handles.imageSize = size(img);
    set(gca,'Units','Pixels');
    handles.axis = [0 handles.imageSize(2) 0 handles.imageSize(1)];
    axis([0 handles.imageSize(2) 0 handles.imageSize(1)]);
    axis ij
    handles.MultiEchoTE (EchoLoop) = metadata.EchoTime;
    handles.ImgData(:,:,EchoLoop)=img;
    PlotImage(img, handles);
end
img(:, :)=handles.ImgData(:,:,1);
axes(handles.MainImg);
handles.imageSize = size(img);
set(gca,'Units','Pixels');
handles.axis = [0 handles.imageSize(2) 0 handles.imageSize(1)];
axis([0 handles.imageSize(2) 0 handles.imageSize(1)]);
axis ij
PlotImage(img,handles);
handles.CurrentImg = handles.ImgData(:,:,1);
handles.ImgCp=handles.ImgData;
guidata(hObject, handles);
return


% --- Executes on slider movement.
function SliderEcho_Callback(hObject, eventdata, handles)
% hObject    handle to SliderEcho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = guidata(hObject);
global SliderImageNo LINEWIDTH;
global Hxy;
if (handles.SeriesSelected==0)
    msgbox('please select the series of images!');
    return
end
SliderNo = size(handles.ImgData,3); % the third dimension, the number of echo image
set(handles.SliderEcho,'sliderstep',[1/(SliderNo-1) 2/(SliderNo-1)]); % 控制slider的步长，一个是小步长，是点击slider两端的箭头移动的步长；一个是大步长，是点击slider时移动的步长
SliderValue = get(handles.SliderEcho,'Value');
SliderImageNo = round( SliderValue*(SliderNo-1) )+1; % 重新乘回分母
img(:,:) = handles.ImgData(:,:,SliderImageNo); % 获得当前echo的图像
handles.CurrentImg = img;
PlotImage(uint16(img), handles);
if handles.ROI.NumOfProfiles >0;
    for indx = 1:handles.ROI.NumOfProfiles
        handles.ROI.Profiles(indx).line = ...
            line(handles.ROI.Profiles(indx).points(:,1),handles.ROI.Profiles(indx).points(:,2),...
            'Color','yellow','LineWidth',LINEWIDTH);
    end
end
if handles.xypflag == 1;
    axes(handles.MainImg)
    axis ij;
    Hxy = plot(handles.yp,handles.xp,'rs','MarkerSize',3); % red square, marker size = 3
end
guidata(hObject, handles);
return

% --- Executes during object creation, after setting all properties.
function SliderEcho_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderEcho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in savefiles.
function savefiles_Callback(hObject, eventdata, handles)
% hObject    handle to savefiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fname = get(handles.ListBox,'String');
h = waitbar(0,'Saving files....');
Nfiles = length(fname);
pid_raw_old = '';
for k=1:Nfiles,
    waitbar(k/Nfiles);
    try
        fnamek = fname(k,:);
        source = [handles.dfolder '\' fnamek];
        metadata = dicominfo(source);
        % --- get the fileds for the new file name
        pid_raw = char(metadata.PatientID);
        % check the pid
        if (length(pid_raw)>10) && (~strcmp(pid_raw,pid_raw_old))%ID编号大于10且与当前的不一样
            prompt={'Enter the patient ID'};
            name='Wrong patient ID';
            numlines=1;
            defaultanswer={pid_raw};
            pid = char(inputdlg(prompt,name,numlines,defaultanswer));
        elseif (length(pid_raw)<=10)
            pid = pid_raw;
        end
        pid_raw_old = pid_raw;
        seq = metadata.SeriesDescription;   %         seq = metadata.SequenceName;
        ser = metadata.SeriesNumber;   %         TE = round(metadata.EchoTime);
        ima = num2str(metadata.InstanceNumber); %         TR = round(metadata.RepetitionTime);
        b = '000';
        b(end-length(ima)+1:end) = ima;
        seq(isspace(seq)) = '_';
        % --- construct the new name
        newname = ['pid' pid '-seq' seq '-image' num2str(b) '.dcm'];
        % --- create the a new directory with the series #
        wiam = cd;
        cd(handles.dfolder)
        dirname = ['PatientID' pid '-series' num2str(ser)];
        if exist([handles.dfolder '\' dirname],'dir')~=7,%若exist返回7则表示是a directory
            mkdir(dirname)
        end
        destination = [(handles.dfolder) '\' dirname '\' newname];
        % -- check if the file name exist, and add x's
        if exist(destination,'file'),
            while exist(destination,'file'),
                destination = [destination(1:end-4) 'x.dcm'];
            end
        end
        % --- copy the file
        %[status,mess] = copyfile(source,destination,'f');
        info=dicominfo(source);
        info.AcquisitionMatrix = [0    256    204      0];
        info.ImageOrientationPatient = [ 0.4600 0.8702 -0.1764 -0.4183 0.0371 -0.9075];
        img=dicomread(source);
        dicomwrite(img, destination, info); % strange thing to do
    catch
        disp ('apparently not a DICOM file, trying next one...');
        lasterr
    end
end
close(h)
guidata(hObject, handles); %updates the handles


% --- Executes on button press in ZoomOn.
function ZoomOn_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.MainImg);
handles.ROI.exists = 0;
zoom on
guidata(hObject, handles);

% --- Executes on button press in ZoomOff.
function ZoomOff_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.MainImg);
handles.axis = axis;
axis(handles.axis);axis equal;axis ij
handles.axis = axis;
zoom off
guidata(hObject, handles); %updates the handles


% --- Executes on button press in WindowLevel.
function WindowLevel_Callback(hObject, eventdata, handles)
% hObject    handle to WindowLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom off
axes(handles.MainImg);
colormap gray(256);
global WLminValue WLmaxValue
uiwait (imcontrast(handles.MainImg));
newCLim = get(handles.MainImg,'CLim');
WLminValue = newCLim(1); %just a simple way to adjust contrast
WLmaxValue = newCLim(2);
guidata(hObject, handles); %updates the handles

%%plot data points
function handles = PlotDataPnts(handles)
% clear figure if it exists already
if ishandle( handles.figures.figure_decay )
    close( handles.figures.figure_decay )
end
% Launch new window for plotting
handles.figures.figure_decay = figure (handles.figures.figure_decay);
handles.scrsz;

xdata = handles.MultiEchoTE;
ydata = handles.MultiEchoMeanData;

TitleStr = 'Multiecho Decay Curve';
ydataCorr=ydata;
axes( 'Parent', handles.figures.figure_decay, 'FontSize', 12, 'FontName',... % parent指定父对象为后面参数
    'Times New Roman' )
set(handles.figures.figure_decay, 'Name','DecayData','Position',...
    [handles.scrsz(3)*2/4 handles.scrsz(4)/6 handles.scrsz(3)/3 handles.scrsz(4)/2] )

plot(xdata, ydata, 'o' )

axis( [0  1.1*max(xdata) min(0,1.2*min(ydataCorr))  1.3*max(ydata)] );
set(gca, 'Parent', gcf, 'FontSize', 12, 'FontName','Times New Roman','box','on') % gca current axes, gcf current figure
%ydataCorr
title( TitleStr, 'FontWeight','bold','FontSize',12,...
    'FontName','Times New Roman' );
xlabel( 'Time (ms)', 'FontSize', 12, 'FontName', 'Times New Roman' )
ylabel( 'SI', 'FontSize', 12, 'FontName', 'Times New Roman' )
legend( 'Measured Data' )


% --- Executes on button press in AddROI.
function AddROI_Callback(hObject, eventdata, handles)
% hObject    handle to AddROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ATF_WL_edit,'String',' ');
set(handles.PWF_WL_edit, 'String',' ');
set(handles.ATF_T2s_edit,'String',' ');
set(handles.PWF_T2s_edit,'String',' ');
cla(handles.LiverROI);
axes(handles.LiverROI)
cbfreeze('off');
colorbar('off');
global LINEWIDTH;
if isempty(handles.CurrentImg)
    msgbox('Please check the data, it is empty','r')
    return;
end
handles.ROI.NumOfProfiles = handles.ROI.NumOfProfiles + 1;
indx = handles.ROI.NumOfProfiles;
axes(handles.MainImg);
img = handles.CurrentImg;
[mask ,points,~] = roispline(img,handles.axis);
if size(points,1) <3
    msgbox('the number of points is less than 3', 'r');
    handles.ROI.NumOfProfiles = handles.ROI.NumOfProfiles - 1;
else
    handles.ROI.Profiles(indx).points = points;
    handles.ROI.Profiles(indx).mask = mask;
    handles.ROI.Profiles(indx).line = line(handles.ROI.Profiles(indx).points(:,1),...
        handles.ROI.Profiles(indx).points(:,2), 'Color','yellow','LineWidth',LINEWIDTH);
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
    handles.ROI.mask{iROI+1} = handles.ROI.mask{iROI};
    handles.ROI.mask{iROI} = handles.ROI.Profiles(iROI).mask;
    handles.ROI.indicies{iROI} = find(handles.ROI.mask{iROI});
    handles.ROI.mask{iROI+1} = handles.ROI.mask{iROI}|... % |:或，取并集？
        handles.ROI.mask{iROI+1};
    handles.ROI.indicies{iROI+1} = find(handles.ROI.mask{iROI+1});
    handles.ROImasksExistFlag = 1;
end
if iROI ==0
    handles.ROI.mask = [];
    handles.ROI.indicies = [];
    handles.ROImasksExistFlag = 0;
end
guidata(hObject,handles);

% --- Executes on button press in DeleteROI.
function DeleteROI_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ATF_WL_edit,'String',' ');
set(handles.PWF_WL_edit, 'String',' ');
set(handles.ATF_T2s_edit,'String',' ');
set(handles.PWF_T2s_edit,'String',' ');
cla(handles.LiverROI);
axes(handles.LiverROI)
cbfreeze('off');
colorbar('off');
if handles.ROI.NumOfProfiles <1
    handles.ROImasksExistFlag = 0;
    handles.ROI.mask = [];
    handles.ROI.indicies = [];
    errordlg('There is no Profiles')
    return;
end
if handles.ROI.NumOfProfiles >0;
    indx = handles.ROI.NumOfProfiles;
    if ishandle(handles.ROI.Profiles(indx).line)
        delete(handles.ROI.Profiles(indx).line);
    end
    handles.ROI.Profiles(indx).xi = [];
    handles.ROI.Profiles(indx).yi = [];
    handles.ROI.NumOfProfiles = handles.ROI.NumOfProfiles - 1;
    iROI = handles.ROI.NumOfProfiles;
    if iROI > 0
        handles.ROI.mask{iROI+1} = xor(handles.ROI.mask{iROI+1},handles.ROI.mask{iROI+2});
        handles.ROI.indicies{iROI+1} = find(handles.ROI.mask{iROI+1});
        handles.ROI.mask{iROI+2} = [];
        handles.ROI.indicies{iROI+2} = [];
        handles.ROImasksExistFlag = 1;
    else
        handles.ROI.mask = [];
        handles.ROI.indicies = [];
        handles.ROImasksExistFlag = 0;
    end
end
% set(handles.ATF_T2s_edit,'String','');
% set(handles.PWF_T2s_edit,'String','');
guidata(hObject,handles);


% --- Executes on button press in SaveROIResu.
function SaveROIResu_Callback(hObject, eventdata, handles)
% hObject    handle to SaveROIResu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LiverSmallMask = handles.ROI.mask;
global global_sigma;global squaresigma;
% [mask1filename,mask1pathname] = uiputfile('*.mat','Save your mask files','LiverMapping_ROImask.mat');
% if isempty(mask1filename)
%     return
% else
%     save([mask1pathname mask1filename],'LiverMappingROImask','LiverROImask');
% end
save([handles.dfolder '\T2sLiverSmallMask.mat'],'LiverSmallMask'); 
ROI_R2_Resu = handles.ROI;
save([handles.dfolder '\T2sLiverROI_resu.mat'],'ROI_R2_Resu'); 
guidata(hObject,handles);

% --- Executes on button press in SaveSAPEResu.
function SaveSAPEResu_Callback(hObject, eventdata, handles)
% hObject    handle to SaveSAPEResu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LiverLargeMask = handles.ROI.mask;
% [mask1filename,mask1pathname] = uiputfile('*.mat','Save your mask files','LiverMapping_ROImask.mat');
% if isempty(mask1filename)
%     return
% else
%     save([mask1pathname mask1filename],'LiverMappingROImask','LiverROImask');
% end
global global_sigma;global squaresigma;
save([handles.dfolder '\T2sLiverLargeMask.mat'],'LiverLargeMask'); % save specific variables to MAT-file
SAPE_ATF_Mea_Med = handles.SAPE;
save([handles.dfolder '\T2sLiverSAPEResu.mat'],'SAPE_ATF_Mea_Med');
guidata(hObject,handles);
% --- Executes on button press in SaveROIMasks.

% --- Executes on button press in SaveAnaResu.
function SaveAnaResu_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAnaResu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% cd(handles.dfolder);
[filename,pathname] = uiputfile([handles.dfolder(1:32) '\default'],'Save your GUI settings');
if pathname == 0 %if the user pressed cancelled, then we exit this callback
    return
end
saveDataName = fullfile(pathname,filename); %construct the path name of the save location
hgsave(saveDataName);%saves the gui data
guidata(hObject,handles);


% --- Executes on button press in LoadAnaResu.
function LoadAnaResu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadAnaResu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile([handles.dfolder(1:32) '\*.fig'], 'Choose the GUI settings file to load');
loadDataName = fullfile(pathname,filename);%construct the path name of the file to be loaded
theCurrentGUI = gcf;  %this is the gui that will be closed once we load the new settings
hgload(loadDataName); %load the settings, which creates a new gui
close(theCurrentGUI);%closes the old gui
guidata(hObject,handles);


% --- Executes on button press in MeanNoise.
function MeanNoise_Callback(hObject, eventdata, handles) % 只画一个profile,也就被前面命名为mappingROI
% hObject    handle to MeanNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% % tempdata = reshape(handles.ImgData, size(handles.ImgData,1)*size(handles.ImgData,2), size(handles.ImgData,3));
% % if handles.mappingmasksExistFlag == 0
% %     errordlg('There is no ROI profiles')
% %     return
% % end
% % MultiEchoMeanBKnoise = mean( tempdata(handles.MappingROI.indicies, :) );
% % handles.MeanBKnoise = mean(MultiEchoMeanBKnoise);
% % squareddata = tempdata .^2;
% % MultiEchoMeanSquaredBKnoise = mean( squareddata(handles.MappingROI.indicies, :) );
% % handles.MeanSquaredBKnoise =  mean (MultiEchoMeanSquaredBKnoise);
% % try
% %     MeanBKnoise = handles.MeanBKnoise;
% %     MeanSquareBKnoise = handles.MeanSquaredBKnoise;
% % catch
% %     msgbox('Please select the  images you want to analysis')
% %     return
% % end
% % write into excel file
dicomfiles = dir([handles.dfolder '\*.dcm']);
file_info = dicominfo([handles.dfolder '\' dicomfiles(1).name]);
try
    patientName = strcat(file_info.PatientName.FamilyName,'_',file_info.PatientName.GivenName); %makes the two string patient name (first and last)
catch
    try
        patientName = strcat(file_info.PatientName.FamilyName); %makes the two string patient name (first and last) into one string
    catch
        patientName ='UNKNOWN';
        msgbox('The name of patient is unkown')
        return
    end
end
global global_sigma squaresigma;
IMGs = handles.ImgData;
[global_sigma,squaresigma] = calcBKGnoiseandSquaresigma(IMGs,0.1, 1,8);
handles.MeanBKnoise = global_sigma * sqrt(0.5*pi);
handles.MeanSquareBKnoise = squaresigma;
% xlswrite('LiverT2sSigma.xls', [{'Noise'} {'SquareNoise'}], patientName, 'A1:B1');
% xlswrite('LiverT2sSigma.xls', [MeanBKnoise MeanSquareBKnoise], patientName, 'A2:B2');
guidata(hObject,handles);



% --- Executes on button press in LoadT2sMap.
function LoadT2sMap_Callback(hObject, eventdata, handles)
% hObject    handle to LoadT2sMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% T2sMapname = 'T2s_allMAPs.mat';%或者改为创建对话框让用户选择dicom图像对应的T2s_allMAPs
% T2sMapname = fullfile(handles.dfolder,T2sMapname);
% load(T2sMapname);
global T2mapfilename;
[mfilename, mpathname] = uigetfile({'*.mat';'*.fig'},'Choose T2 Mapping Result');
if isequal(mfilename,0)||isequal(mpathname,0)
    return;
else
    set(handles.ATF_WL_edit,'String',' ');
    set(handles.PWF_WL_edit, 'String',' ');
    T2mapfilename = fullfile(mpathname, mfilename);
    load(T2mapfilename);
    handles.T2s = reshape(T2s,handles.imageSize(1),handles.imageSize(2));
    handles.T2s_Offset = reshape(T2s_Offset,handles.imageSize(1),handles.imageSize(2));
    handles.T2s_SQEXP = reshape(T2s_SQEXP,handles.imageSize(1),handles.imageSize(2));
    handles.T2s_SQEXP_fixsigma = reshape(T2s_SQEXP_fixsigma,handles.imageSize(1),handles.imageSize(2));
    handles.T2s_NCEXP = reshape(T2s_NCEXP,handles.imageSize(1),handles.imageSize(2));
    handles.T2s_NCEXP_fixsigma = reshape(T2s_NCEXP_fixsigma,handles.imageSize(1),handles.imageSize(2));
    PlotT2sMap(handles.T2s_SQEXP,handles);
end
guidata(hObject,handles);

function PlotT2sMap(t2s,handles)
global LINEWIDTH;
axes(handles.LiverROI)
cbfreeze('off')
colorbar('off')
set(gca,'Units','Pixels');
% r =handles.axis;
% axis([r(1) r(2) r(3) r(4)]);axis equal;axis ij
imagesc(t2s); % plot r28 map
colormap jet;
freezeColors; % freeze the color in the current axis from later subsequnce changes
colorbar;
cbfreeze;
axis(handles.axis);axis equal;axis ij
if handles.ROI.NumOfProfiles >0;
    for indx = 1:handles.ROI.NumOfProfiles
        handles.ROI.Profiles(indx).line = ...
            line(handles.ROI.Profiles(indx).points(:,1),handles.ROI.Profiles(indx).points(:,2),...
            'Color','yellow','LineWidth',LINEWIDTH);
    end
end
% figure
% axis equal;
% imagesc(t2s);
% colormap jet;
% freezeColors;
% colorbar;
return % -- End PlotImage
%colorbar('peer',handles.LiverROI,'EastOutside','Ylim',[min(t2s(:)),max(t2s(:))])




% --- Executes on button press in ATF_pushbutton.
function ATF_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ATF_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ATF_T2s_edit,'String',' ');
if handles.ROImasksExistFlag  == 0
    msgbox('ROI does not exist, Please delinate it first!')
    return;
end
global Ncoils;
global global_sigma  squaresigma;
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
Cmodel = get(handles.ModelChooseGBtn,'UserData');
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
            legend('Measured data',['Trunction T2* =' num2str(T2_AutoTrunc,'%.2f') 'ms'],...
                'Deleted points for Trunction',...
                'color','k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            set(handles.ATF_T2s_edit,'String',num2str(1000./T2));
        case 2
            [T2_Offset, M0_Offset, Offset] = calc_T2_Offset(xdata, ydata);
            signal_fitted = fun_T2_Offset([M0_Offset T2_Offset Offset], xdata);
            Rs_errors_Offset = calcRs_error(ydata,signal_fitted);
            fittedcurve_Offset = fun_T2_Offset([M0_Offset T2_Offset Offset], curve_x); % fitted curve
            handles.ROI.ABF_OffsetR2s = 1000/T2_Offset; % result R2*
            handles.ROI.ABF_OffsetErrors = Rs_errors_Offset ;
            figure
            set(gcf,'position',[200 200 450 350])
            plot(xdata, ydata, 'ko');hold on;
            plot(curve_x, fittedcurve_Offset,'r--', 'Linewidth', 2.5 );
            xlabel('TE(ms)', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('Signal Intensity', 'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            legend('Measured data',['Offset T2* =' num2str(T2_Offset,'%.2f') 'ms'],...
                'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            set(handles.ATF_T2s_edit,'String',num2str(1000./T2_Offset));
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
            legend('Measured data',['SQEXP T2* =' num2str(T2_SQEXP,'%.2f') 'ms'],...
                'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            set(handles.ATF_T2s_edit,'String',num2str(1000./T2_SQEXP));
        case 4
            [T2_SQEXP_fixsigma M0_SQEXP_fixsigma] = calc_T2_SQEXP_fixsigma(xdata, squaredydata);
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
            legend('Measured data',['SQEXP-fixsigma T2* =' num2str(T2_SQEXP_fixsigma,'%.2f') 'ms'],...
                'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            set(handles.ATF_T2s_edit,'String',num2str(1000./T2_SQEXP_fixsigma));
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
            legend('Measured data',['NCEXP-fixsigma T2* =' num2str(T2_NCEXP,'%.2f') 'ms'],...
                'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            set(handles.ATF_T2s_edit,'String',num2str(1000./T2_NCEXP));
        case 6
            [T2_NCEXP_fixsigma M0_NCEXP_fixsigma ] = calc_T2_NCEXP_fixsigma(xdata, ydata);
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
            legend('Measured data',['NCEXP-fixsigma T2* =' num2str(T2_NCEXP_fixsigma,'%.2f') 'ms'],...
                'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
            set(handles.ATF_T2s_edit,'String',num2str(1000./T2_NCEXP_fixsigma));
    end
else
    [T2_NCEXP_fixsigma M0_NCEXP_fixsigma ] = calc_T2_NCEXP_fixsigma(xdata, ydata);
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
    legend('Measured data',['T2* =' num2str(T2_NCEXP_fixsigma,'%.2f') 'ms'],...
        'Color', 'k' ,'FontName','times', 'FontSize', 12, 'FontWeight', 'bold');
    set(handles.ATF_T2s_edit,'String',num2str(1000./T2_NCEXP_fixsigma));
    disp('No model choosed and show NCEXP_fixsigma')
end
guidata(hObject,handles);


% --- Executes on button press in PWF_pushbutton.
function PWF_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to PWF_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.PWF_T2s_edit,'String',' ');
if handles.ROImasksExistFlag  == 0
    msgbox('ROI does not exist, Please delinate it first!')
    return;
end
global T2mapfilename;
if isempty(T2mapfilename)
%     msgbox('T2map has not been loaded.So it may take long time')
    iROI = handles.ROI.NumOfProfiles+1;
    ROIindicies = handles.ROI.indicies{iROI};
    tempdata = reshape(handles.ImgData, size(handles.ImgData,1)*size(handles.ImgData,2), size(handles.ImgData,3));
    numofpixel = length(ROIindicies); % num of the pixel in ROI
    
    handles.ROI.MultiEchoData = tempdata(ROIindicies,:); % extract all pixel data in ROI
    squareddata = tempdata .^2;
    handles.ROI.MultiEchoSquaredData = squareddata(ROIindicies,:);
    try
        xdata=handles.MultiEchoTE;
        ydata=handles.ROI.MultiEchoData;
        squaredydata = handles.ROI.MultiEchoSquaredData;
    catch
        msgbox('Please select the images you want to analysis')
        return
    end
    T2_OffsetRes  = zeros(numofpixel,1);
    T2_SQEXPRes = zeros(numofpixel,1);
    T2_AutoTruncRes  = zeros(numofpixel,1);
    T2_NCEXPRes_fixsigma = zeros(numofpixel,1);
    T2_SQEXPRes_fixsigma = zeros(numofpixel,1);
    T2_NCEXPRes = zeros(numofpixel,1);
    global Ncoils;
    global global_sigma squaresigma;
    Ncoils = 4;
    % global_sigma = handles.MeanBKnoise /sqrt(0.5*pi);
    % squaresigma = handles.MeanSquaredBKnoise;
    Cmodel = get(handles.ModelChooseGBtn,'UserData');
    if ~isempty(Cmodel)
        switch Cmodel
            case 1
                for i = 1:numofpixel;
                    [T2_AutoTrunc M0_AutoTrunc numofTrunc] = calc_T2_AutoTrunc(xdata, ydata(i,:));
                    signal_fitted = M0_AutoTrunc*exp(-xdata./T2_AutoTrunc);
                    T2_AutoTruncRes(i) = T2_AutoTrunc;
                end
                PWF_AutoTruncMeanR2s = mean(1000./T2_AutoTruncRes);
                handles.ROI.PWF_AutoTruncMeanR2s = PWF_AutoTruncMeanR2s;
                PWF_AutoTruncMedianR2s = median(1000./T2_AutoTruncRes);
                handles.ROI.PWF_AutoTruncMedianR2s = PWF_AutoTruncMedianR2s;
                set(handles.PWF_T2s_edit,'String',num2str(PWF_AutoTruncMedianR2s));
            case 2
                for i = 1:numofpixel;
                    [T2_Offset M0_Offset Offset] = calc_T2_Offset(xdata, ydata(i,:));
                    signal_fitted = fun_T2_Offset([M0_Offset T2_Offset Offset], xdata);
                    T2_OffsetRes(i) = T2_Offset;
                end
                PWF_OffsetMeanR2s = mean(1000./T2_OffsetRes);
                handles.ROI.PWF_OffsetMeanR2s = PWF_OffsetMeanR2s;
                PWF_OffsetMedianR2s = median(1000./T2_OffsetRes);
                handles.ROI.PWF_OffsetMedianR2s = PWF_OffsetMedianR2s;
                set(handles.PWF_T2s_edit,'String',num2str(PWF_OffsetMedianR2s));
            case 3
                for i = 1:numofpixel;
                    [T2_SQEXP M0_SQEXP sigma_SQEXP] = calc_T2_SQEXP(xdata, squaredydata(i,:));
                    signal_fitted = fun_SQEXP([M0_SQEXP T2_SQEXP sigma_SQEXP], xdata);
                    T2_SQEXPRes(i) = T2_SQEXP;
                end
                PWF_SQEXPMeanR2s = mean(1000./T2_SQEXPRes);
                handles.ROI.PWF_SQEXPMeanR2s(iROI) = PWF_SQEXPMeanR2s;
                PWF_SQEXPMedianR2s = median(1000./T2_SQEXPRes);
                handles.ROI.PWF_SQEXPMedianR2s(iROI) = PWF_SQEXPMedianR2s;
                set(handles.PWF_T2s_edit,'String',num2str(PWF_SQEXPMedianR2s));
            case 4
                for i = 1:numofpixel;
                    [T2_SQEXP_fixsigma M0_SQEXP_fixsigma] = calc_T2_SQEXP_fixsigma(xdata, squaredydata(i,:));
                    signal_fitted = fun_SQEXP_fixsigma([M0_SQEXP_fixsigma T2_SQEXP_fixsigma], xdata);
                    T2_SQEXPRes_fixsigma(i) = T2_SQEXP_fixsigma;
                end
                PWF_SQEXP_fixsigmaMeanR2s = mean(1000./T2_SQEXPRes_fixsigma);
                handles.ROI.PWF_SQEXP_fixsigmaMeanR2s(iROI) = PWF_SQEXP_fixsigmaMeanR2s;
                PWF_SQEXP_fixsigmaMedianR2s = median(1000./T2_SQEXPRes_fixsigma);
                handles.ROI.PWF_SQEXP_fixsigmaMedianR2s(iROI) = PWF_SQEXP_fixsigmaMedianR2s;
                set(handles.PWF_T2s_edit,'String',num2str(PWF_SQEXP_fixsigmaMedianR2s));
            case 5
                for i = 1:numofpixel;
                    [T2_NCEXP M0_NCEXP sigma_NCEXP] = calc_T2_NCEXP(xdata, ydata(i,:));
                    signal_fitted = fun_NCEXP([M0_NCEXP T2_NCEXP sigma_NCEXP], xdata);
                    T2_NCEXPRes(i) = T2_NCEXP;
                end
                PWF_NCEXPMeanR2s = mean(1000./T2_NCEXPRes);
                handles.ROI.PWF_NCEXPMeanR2s(iROI) = PWF_NCEXPMeanR2s;
                PWF_NCEXPMedianR2s = median(1000./T2_NCEXPRes);
                handles.ROI.PWF_NCEXPMedianR2s(iROI) = PWF_NCEXPMedianR2s;
                set(handles.PWF_T2s_edit,'String',num2str(PWF_NCEXPMedianR2s));
            case 6
                for i = 1:numofpixel;
                    [T2_NCEXP_fixsigma M0_NCEXP_fixsigma] = calc_T2_NCEXP_fixsigma(xdata, ydata(i,:));
                    signal_fitted = fun_NCEXP_fixsigma([M0_NCEXP_fixsigma T2_NCEXP_fixsigma], xdata);
                    T2_NCEXPRes_fixsigma(i) = T2_NCEXP_fixsigma;
                end
                PWF_NCEXP_fixsigmaMeanR2s = mean(1000./T2_NCEXPRes_fixsigma);
                handles.ROI.PWF_NCEXP_fixsigmaMeanR2s(iROI) = PWF_NCEXP_fixsigmaMeanR2s;
                PWF_NCEXP_fixsigmaMedianR2s = median(1000./T2_NCEXPRes_fixsigma);
                handles.ROI.PWF_NCEXP_fixsigmaMedianR2s(iROI) = PWF_NCEXP_fixsigmaMedianR2s;
                set(handles.PWF_T2s_edit,'String',num2str(PWF_NCEXP_fixsigmaMedianR2s));
        end
    else
        disp('No model choosed and show NCEXP_fixsigma model');
        for i = 1:numofpixel;
            [T2_NCEXP_fixsigma M0_NCEXP_fixsigma] = calc_T2_NCEXP_fixsigma(xdata, ydata(i,:));
            signal_fitted = fun_NCEXP_fixsigma([M0_NCEXP_fixsigma T2_NCEXP_fixsigma], xdata);
            T2_NCEXPRes_fixsigma(i) = T2_NCEXP_fixsigma;
        end
        PWF_NCEXP_fixsigmaMeanR2s = mean(1000./T2_NCEXPRes_fixsigma);
        handles.ROI.PWF_NCEXP_fixsigmaMeanR2s(iROI) = PWF_NCEXP_fixsigmaMeanR2s;
        PWF_NCEXP_fixsigmaMedianR2s = median(1000./T2_NCEXPRes_fixsigma);
        handles.ROI.PWF_NCEXP_fixsigmaMedianR2s(iROI) = PWF_NCEXP_fixsigmaMedianR2s;
        set(handles.PWF_T2s_edit,'String',num2str(PWF_NCEXP_fixsigmaMedianR2s));
    end  
else
    load(T2mapfilename)
    iROI = handles.ROI.NumOfProfiles+1
    mask_indicies = handles.ROI.indicies{iROI};
    T2_MonoexpRes = T2s(mask_indicies);
    PWF_MonoexpMeanR2s = mean(1000./T2_MonoexpRes);
    handles.ROI.PWF_MonoexpMeanR2s(iROI) = PWF_MonoexpMeanR2s;
    PWF_MonoexpMedianR2s = median(1000./T2_MonoexpRes);
    handles.ROI.PWF_MonoexpMedianR2s(iROI) = PWF_MonoexpMedianR2s;
    T2_OffsetRes = T2s_Offset(mask_indicies);
    PWF_OffsetMeanR2s = mean(1000./T2_OffsetRes);
    handles.ROI.PWF_OffsetMeanR2s(iROI) = PWF_OffsetMeanR2s;
    PWF_OffsetMedianR2s = median(1000./T2_OffsetRes);
    handles.ROI.PWF_OffsetMedianR2s(iROI) = PWF_OffsetMedianR2s;
    T2_SQEXPRes = T2s_SQEXP(mask_indicies);
    PWF_SQEXPMeanR2s = mean(1000./T2_SQEXPRes);
    handles.ROI.PWF_SQEXPMeanR2s(iROI) = PWF_SQEXPMeanR2s;
    PWF_SQEXPMedianR2s = median(1000./T2_SQEXPRes);
    handles.ROI.PWF_SQEXPMedianR2s(iROI) = PWF_SQEXPMedianR2s;
    T2_SQEXPRes_fixsigma = T2s_SQEXP_fixsigma(mask_indicies);
    PWF_SQEXP_fixsigmaMeanR2s = mean(1000./T2_SQEXPRes_fixsigma);
    handles.ROI.PWF_SQEXP_fixsigmaMeanR2s(iROI) = PWF_SQEXP_fixsigmaMeanR2s;
    PWF_SQEXP_fixsigmaMedianR2s = median(1000./T2_SQEXPRes_fixsigma);
    handles.ROI.PWF_SQEXP_fixsigmaMedianR2s(iROI) = PWF_SQEXP_fixsigmaMedianR2s;
    T2_NCEXPRes = T2s_NCEXP(mask_indicies);
    PWF_NCEXPMeanR2s = mean(1000./T2_NCEXPRes);
    handles.ROI.PWF_NCEXPMeanR2s(iROI) =  PWF_NCEXPMeanR2s;
    PWF_NCEXPMedianR2s = median(1000./T2_NCEXPRes);
    handles.ROI.PWF_NCEXPMedianR2s(iROI) =  PWF_NCEXPMedianR2s;
    T2_NCEXPRes_fixsigma = T2s_NCEXP_fixsigma(mask_indicies);
    PWF_NCEXP_fixsigmaMeanR2s = mean(1000./T2_NCEXPRes_fixsigma);
    handles.ROI.PWF_NCEXP_fixsigmaMeanR2s(iROI) = PWF_NCEXP_fixsigmaMeanR2s;
    PWF_NCEXP_fixsigmaMedianR2s = median(1000./T2_NCEXPRes_fixsigma);
    handles.ROI.PWF_NCEXP_fixsigmaMedianR2s(iROI) = PWF_NCEXP_fixsigmaMedianR2s;
end
guidata(hObject,handles);


function PlotLiver(T2map,mask0,cf,strtitle,handles)
global H3;global LINEWIDTH;
if ishandle(H3) % test for valid graphics handle
    delete(H3)
end
hold on
H3 = plot(cf,'fit',0.95);
xlabel('R2s');
ylabel('number')
set(H3,'LineWidth',2);
cla(handles.LiverROI);
axes(handles.LiverROI)
cbfreeze('off');
colorbar('off');
r2 = immultiply(mask0,1000./T2map);
mask = mask0|(~handles.ROI.mask{1});
r2s = immultiply(mask,1000./T2map);
imagesc(r2s,[min(r2(:)),max(r2(:))]);
colormap jet;
freezeColors;
colorbar('Ylim',[min(r2(:)),max(r2(:))]);
cbfreeze;
axis equal;axis ij;
hold on
if handles.ROI.NumOfProfiles >0;
    for indx = 1:handles.ROI.NumOfProfiles
        handles.ROI.Profiles(indx).line = ...
            line(handles.ROI.Profiles(indx).points(:,1),handles.ROI.Profiles(indx).points(:,2),...
            'Color','yellow','LineWidth',LINEWIDTH);
    end
end
title(strtitle)




% --- Executes when selected object is changed in ModelChooseGBtn.
function ModelChooseGBtn_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ModelChooseGBtn
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Tag') % 注意这里的hObject和别的不同，并不是指这个BUtton Group,而是指在组里面，被选中的那个控件
    case 'MonoexponentialRBtn'   %按钮1的tag
%     case 'TrunctionRBtn' % @Lu
        set(handles.ModelChooseGBtn,'UserData',1);
        handles = guidata(hObject); % return previously stored data.
        
    case 'OffsetRBtn'
        set(handles.ModelChooseGBtn,'UserData',2);
        handles = guidata(hObject);
        
    case 'SQEXPRBtn'
        set(handles.ModelChooseGBtn,'UserData',3);
        handles = guidata(hObject);
        
    case 'SQEXP_fixsigmaRBtn'
        set(handles.ModelChooseGBtn,'UserData',4);
        handles = guidata(hObject);
        
        
    case 'NCEXPRBtn'
        set(handles.ModelChooseGBtn,'UserData',5);
        handles = guidata(hObject);
        
        
    case 'NCEXP_fixsigmaRBtn'
        set(handles.ModelChooseGBtn,'UserData',6);
        handles = guidata(hObject);
        
    otherwise
        disp('wrong selections');
        set(handles.ModelChooseGBtn,'UserData',6);
end
guidata(hObject,handles);

% --- Executes on button press in ExitBtn.
function ExitBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ExitBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['退出 ' get(handles.figure1,'Name') '?'],... % question
    ['退出 ' get(handles.figure1,'Name') '...'],...  % title displayed in the dislog's title bar
    '是','否','是'); % two push buttons, and default button
if strcmp(selection,'否')
    return;
end
delete(handles.figure1);


% --- Executes during object creation, after setting all properties.
function MainImg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MainImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate MainImg


function ATF_T2s_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ATF_T2s_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ATF_T2s_edit as text
%        str2double(get(hObject,'String')) returns contents of ATF_T2s_edit as a double


% --- Executes during object creation, after setting all properties.
function ATF_T2s_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ATF_T2s_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function LiverROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LiverROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate LiverROI



% --- Executes on button press in TrunctionRBtn.
function TrunctionRBtn_Callback(hObject, eventdata, handles)
% hObject    handle to TrunctionRBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TrunctionRBtn


% --- Executes on button press in OffsetRBtn.
function OffsetRBtn_Callback(hObject, eventdata, handles)
% hObject    handle to OffsetRBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OffsetRBtn


% --- Executes on button press in SQEXPRBtn.
function SQEXPRBtn_Callback(hObject, eventdata, handles)
% hObject    handle to SQEXPRBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SQEXPRBtn


% --- Executes on button press in NCEXPRBtn.
function NCEXPRBtn_Callback(hObject, eventdata, handles)
% hObject    handle to NCEXPRBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NCEXPRBtn


% --- Executes on button press in SQEXP_fixsigmaRBtn.
function SQEXP_fixsigmaRBtn_Callback(hObject, eventdata, handles)
% hObject    handle to SQEXP_fixsigmaRBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SQEXP_fixsigmaRBtn


% --- Executes on button press in NCEXP_fixsigmaRBtn.
function NCEXP_fixsigmaRBtn_Callback(hObject, eventdata, handles)
% hObject    handle to NCEXP_fixsigmaRBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NCEXP_fixsigmaRBtn



function ATF_WL_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ATF_WL_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ATF_WL_edit as text
%        str2double(get(hObject,'String')) returns contents of ATF_WL_edit as a double


% --- Executes during object creation, after setting all properties.
function ATF_WL_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ATF_WL_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PWF_WL_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PWF_WL_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PWF_WL_edit as text
%        str2double(get(hObject,'String')) returns contents of PWF_WL_edit as a double


% --- Executes during object creation, after setting all properties.
function PWF_WL_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PWF_WL_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PWF_T2s_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PWF_T2s_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PWF_T2s_edit as text
%        str2double(get(hObject,'String')) returns contents of PWF_T2s_edit as a double


% --- Executes during object creation, after setting all properties.
function PWF_T2s_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PWF_T2s_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function ModelChooseGBtn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ModelChooseGBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on button press in showbadpints.
function showbadpints_Callback(hObject, eventdata, handles)
% hObject    handle to showbadpints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Hxy;
axes(handles.MainImg);
axis ij;
hold on
mpoints =  xor(handles.ROI.mask{1},handles.maskNCEXPALM);
[xp,yp] = find(mpoints);
if ishandle(Hxy)
    delete(Hxy)
end;
Hxy = plot(yp,xp,'rs','MarkerSize',3);
handles.xp = xp;
handles.yp = yp;
handles.xypflag = 1;
guidata(hObject,handles);




% --- Executes during object creation, after setting all properties.
function movethredEt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to movethredEt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in MovebadcoinPBtn.
function MovebadcoinPBtn_Callback(hObject, eventdata, handles)
% hObject    handle to MovebadcoinPBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Hxy;
axes(handles.MainImg)
if ishandle(Hxy)
    delete(Hxy)
end;
handles.xypflag = 0;
handles.xp = [];
handles.yp = [];
guidata(hObject,handles);


% --- Executes on button press in pbtnSAPE.
function pbtnSAPE_Callback(hObject, eventdata, handles)
% hObject    handle to pbtnSAPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LINEWIDTH;
global global_sigma;
global Ncoils;
Ncoils = 4;
if handles.ROImasksExistFlag  == 0
    msgbox('ROI does not exist, Please delinate it first!')
    return;
end
[global_sigma,squaresigma] = calcBKGnoiseandSquaresigma(handles.ImgData,0.1, 1,8);
mask_ROI = handles.ROI.mask{1};
[Xindexs, Yindexs] = find(mask_ROI); % get ROI
tempdata = handles.ImgData;
f=1; % radio of similarity window
t=5; % radio of search window
alphaPara =0.4; % for degree of filtering
IMG = NLmeansfilter_RelaxMap(tempdata,t,f,global_sigma*alphaPara); % NLM filtering
handles.SAPE.MultiEchoData = IMG;
handles.SAPE.ROI = mask_ROI;
xdata=handles.MultiEchoTE;
T2smap = zeros(size(IMG,1),size(IMG,2));
for i = 1:length(Xindexs) ;
    Xindex = Xindexs(i);
    Yindex = Yindexs(i);
    ydata = squeeze(IMG(Xindex,Yindex,:)); % 3D -> 1D
    [T2_NCEXP_fixsigma, M0_NCEXP_fixsigma] = calc_T2_NCEXP_fixsigma(xdata, ydata');  % fit single pixel
    T2smap(Xindex,Yindex) = T2_NCEXP_fixsigma;
end
PlotT2sMap(T2smap,handles);
T2s_NCEXP_fixsigma = T2smap;
handles.SAPE.T2smap = T2smap;
R2s_NCEXP_fixsigma = 1000./(T2s_NCEXP_fixsigma+0.0000000001) ;
R2s_NCEXP_ROI  = R2s_NCEXP_fixsigma(mask_ROI); % ROI中的R2s值，列向量的形式; mask_ROI is logical
T2s_NCEXP_ROIm  = immultiply(T2s_NCEXP_fixsigma,mask_ROI);
row = size(mask_ROI,1); % 图像的行
coloum = size(mask_ROI,2); % 图像的列
maskroi1 = T2s_NCEXP_ROIm>0.5;
maskroi2 = T2s_NCEXP_ROIm<=0.5&T2s_NCEXP_ROIm>0;
R2s_NCEXP_ROI(R2s_NCEXP_ROI>2000)=[];
[~,Un,~] = fcm(R2s_NCEXP_ROI,2); % Un: fuzzy partition matrix, indicates the degree of the jth data point in the ith cluster % FCM cluster
maxUn = max(Un); % compare two rows, get the max one
indexNCEXP1 = find(Un(1, :) == maxUn); % 第一类点的索引指
indexNCEXP2 = find(Un(2, :) == maxUn); % 第二类的索引指
if length(indexNCEXP1)>length(indexNCEXP2) % 取选中点多的这一类
    indexNCEXP = indexNCEXP1;
else
    indexNCEXP = indexNCEXP2;
end
index_mask = find(maskroi1 == 1);
pointchoose = index_mask(indexNCEXP);%以下将索引指转化为mask中对应的坐标
index_pointchooseN = zeros(length(pointchoose),2);
index_pointchooseN(:,2) = floor(pointchoose./row) +1; % 行 round toward negative infinity
index_pointchooseN(:,1) = rem(pointchoose,row);%列 remainder after division
maskNCEXP = zeros(row,coloum);
for index=1:size(index_pointchooseN,1)
    maskNCEXP(index_pointchooseN(index,1),index_pointchooseN(index,2)) = 1;
end % 所获得肝实质的mask
maskNCEXP = (maskNCEXP==1);%转化为logical类型的mask
maskNCEXP = maskNCEXP|maskroi2;%加上》2000的roi;
BW = bwareaopen(~maskNCEXP,2);%去掉孤立的，只有一个像素的血管
maskNCEXP0 = ~BW;
SE = strel('disk',1);
maskNCEXP0 = imerode(~xor(mask_ROI,maskNCEXP0),SE); % erode image
maskNCEXP = maskNCEXP0&mask_ROI;
handles.maskNCEXPALM = maskNCEXP;

tempdata = reshape(IMG, size(IMG,1)*size(IMG,2), size(IMG,3));
xdata = handles.MultiEchoTE;
%NCEXP_fixsigma求T2s
ydata4=mean( tempdata(maskNCEXP(:), :) );
[T2_NCEXP_fixsigmaResu,~] = calc_T2_NCEXP_fixsigma(xdata, ydata4);
 R2_NCEXP_fixsigma_median = median(R2s_NCEXP_fixsigma(maskNCEXP));%对所求mask里的R2求中值
% R2_NCEXP_fixsigma_mean = mean(R2s_NCEXP_fixsigma(maskNCEXP));%对所求mask里的R2求均值
set(handles.ATF_WL_edit,'String',num2str(1000/T2_NCEXP_fixsigmaResu));
set(handles.PWF_WL_edit,'String',num2str(R2_NCEXP_fixsigma_median));
handles.SAPE.R2sABF_R2sPWF_Resu = [1000/T2_NCEXP_fixsigmaResu,...
    R2_NCEXP_fixsigma_median];
cla(handles.LiverROI);
axes(handles.LiverROI)
cbfreeze('off');
colorbar('off');
r2 = immultiply(maskNCEXP,R2s_NCEXP_fixsigma);
mask = maskNCEXP|(~handles.ROI.mask{1});
r2s = immultiply(mask,R2s_NCEXP_fixsigma);
imagesc(r2s,[min(r2(:)),max(r2(:))]);
colormap jet;
freezeColors;
colorbar('Ylim',[min(r2(:)),max(r2(:))]);
cbfreeze;
axis equal;axis ij;
hold on
if handles.ROI.NumOfProfiles >0;
    for indx = 1:handles.ROI.NumOfProfiles
        handles.ROI.Profiles(indx).line = ...
            line(handles.ROI.Profiles(indx).points(:,1),handles.ROI.Profiles(indx).points(:,2),...
            'Color','yellow','LineWidth',LINEWIDTH);
    end
end
guidata(hObject,handles);
