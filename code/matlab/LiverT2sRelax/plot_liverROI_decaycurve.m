figure,
imshow(handles.ImgData(:,:,1),[])
hold on;
indx=1;
handles.ROI.Profiles(indx).line = ...
line(handles.ROI.Profiles(indx).points(:,1),handles.ROI.Profiles(indx).points(:,2),...
'Color','green','LineWidth',1.5);
hold on;
indx=2;
handles.ROI.Profiles(indx).line = ...
line(handles.ROI.Profiles(indx).points(:,1),handles.ROI.Profiles(indx).points(:,2),...
'Color','red','LineWidth',1.5);

iROI = 1;
ROIindicies = handles.ROI.indicies{iROI};
tempdata = reshape(handles.ImgData, size(handles.ImgData,1)*size(handles.ImgData,2), size(handles.ImgData,3));
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
[T2_NCEXP M0_NCEXP sigma_NCEXP] = calc_T2_NCEXP(xdata, ydata);
t_NCEXP = toc;
signal_fitted = fun_NCEXP([M0_NCEXP T2_NCEXP sigma_NCEXP], xdata);
Rs_errors_NCEXP = calcRs_error(ydata,signal_fitted);
fittedcurve_NCEXP = fun_NCEXP([M0_NCEXP T2_NCEXP sigma_NCEXP], curve_x);
handles.ROI.ABF_NCEXPR2s(iROI) = 1000/T2_NCEXP;
handles.ROI.ABF_NCEXPErrors(iROI) = Rs_errors_NCEXP ;
figure
plot(xdata, 1.1*ydata, 'go');hold on;
plot(curve_x, 1.1*fittedcurve_NCEXP, 'g-', 'Linewidth', 2 );hold on;
xlabel('TE(ms)');ylabel('Signal Intensity');
axis([0,18,0,220])
hold on;
iROI=2;
ROIindicies = handles.ROI.indicies{iROI};
tempdata = reshape(handles.ImgData, size(handles.ImgData,1)*size(handles.ImgData,2), size(handles.ImgData,3));
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
[T2_NCEXP M0_NCEXP sigma_NCEXP] = calc_T2_NCEXP(xdata, ydata);
t_NCEXP = toc;
signal_fitted = fun_NCEXP([M0_NCEXP T2_NCEXP sigma_NCEXP], xdata);
Rs_errors_NCEXP = calcRs_error(ydata,signal_fitted);
fittedcurve_NCEXP = fun_NCEXP([M0_NCEXP T2_NCEXP sigma_NCEXP], curve_x);
handles.ROI.ABF_NCEXPR2s(iROI) = 1000/T2_NCEXP;
handles.ROI.ABF_NCEXPErrors(iROI) = Rs_errors_NCEXP ;
hold on;
plot(xdata, 1.1*ydata, 'ro');hold on;
plot(curve_x, 1.1*fittedcurve_NCEXP, 'r-', 'Linewidth', 2 );hold on;
