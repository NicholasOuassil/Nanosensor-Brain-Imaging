function subRoiCalculationsMaxdF(handles)
axes(handles.axes3);
cla(handles.axes3);

image = zeros(512,512);
%Use ROI selected in listbox

roi_selected_value = get(handles.roi_listbox,'Value'); %Number of selected element
roi_names = get(handles.roi_listbox,'string'); %Name of ROI selected (using roi_selected_value as index)
roi_num=str2num(roi_names(roi_selected_value,:));

roi_idx = find([handles.dataset.measuredValues.ROInum]==roi_num);

roi_num=roi_idx;

%Calculate dF/F for each pixel
pixelValues = handles.dataset.measuredValues(roi_num).PixelValues;
F0=mean(pixelValues(1:floor((size(pixelValues,1)*.05)),:),1);
dFnorm = (pixelValues-F0)./F0;

%As a test, try peak dF/F as the pixel value
clusterIdx = max(dFnorm);

%Plot ROIs with pixel intensity corresponding to cluster index
frameNum = 1; %Using pixel coordinates from first frame. Assuming they are the same for each.

%Reconstruct image using color of each pixel as cluster ID
pixelLocsRow = handles.dataset.measuredValues(roi_num).PixelListRow;
pixelLocsCol = handles.dataset.measuredValues(roi_num).PixelListCol;
for pixidx=1:size(pixelValues,2)
    image(pixelLocsRow(frameNum,pixidx),pixelLocsCol(frameNum,pixidx))=clusterIdx(pixidx);
    imagesc(image');
end

imagesc(image');
set(handles.axes3,'Ydir','reverse')
xlim([0 size(image,1)])
ylim([0 size(image,2)])
ylabel('')
xlabel('')

end