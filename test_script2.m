%% Testing for sub-ROI pixel correlation

image = zeros(512,512);


%Plots original pixel values for a given frame

frameNum = 1;
for roi_num = 1:size(currentDataset.measuredValues,2)
    pixelValues = currentDataset.measuredValues(roi_num).PixelValues;
    pixelLocsRow = currentDataset.measuredValues(roi_num).PixelListRow;
    pixelLocsCol = currentDataset.measuredValues(roi_num).PixelListCol;
    for pixidx=1:size(pixelValues,2)
        image(pixelLocsRow(frameNum,pixidx),pixelLocsCol(frameNum,pixidx))=pixelValues(frameNum,pixidx);
    end
end

%%
image = zeros(512,512);
for roiIdx = 1:size(currentDataset.measuredValues,2)   
    roi_num=roiIdx;


    %Calculate dF/F for each pixel
    pixelValues = currentDataset.measuredValues(roi_num).PixelValues;
    F0=mean(pixelValues(1:floor((size(pixelValues,1)*.05)),:),1);
    pixelValuesNormed = (pixelValues-F0)./F0;

    R = corrcoef(pixelValuesNormed);
    % rows = observations (frame number); columns = variables (pixels).

    %Run k-means clustering on correlation coefficients to 

    clusterIdx = kmeans(R,5);

    %Plot ROIs with pixel intensity corresponding to cluster index
    frameNum = 1;

    pixelLocsRow = currentDataset.measuredValues(roi_num).PixelListRow;
    pixelLocsCol = currentDataset.measuredValues(roi_num).PixelListCol;
    for pixidx=1:size(pixelValues,2)
        image(pixelLocsRow(frameNum,pixidx),pixelLocsCol(frameNum,pixidx))=clusterIdx(pixidx);
    end
end

%%

figure(), imagesc(image)

