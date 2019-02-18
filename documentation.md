#Nanosensor-Brain-Imaging Documentation

Input and output of functions in the Nanosensor-Brain-Imaging GUI.

If you're a first time user, please consult the tutorial to begin using this program!

Updates to come!

## Process Video Functions

### Load Stack
* **Requires:** `TIF` or `SPE` file type
* **Creates:** handles *struct* 
    * Prepares DataSet *struct* within handles
        * ````  
            handles.DataSet = struct('frameRate',{},'fileName',{},'pathName',{'PathName'},'roiMask',{},'measuredValues',{},...
            'projectionImages',{},'thresholdValue',{},'numFrames',{},'stimFrames',{})
            ```` 
    * Loads all future user commands and program data into handles *struct* 
    
    
### Process File
* **Requires:** Video File (see Load Stack), Filetype selection, Frame Rate, Threshold Level, ROI Mask
*  **Calculates:** dF/F using average of 50 previous frames, Mean Intensity, ROI size, ROI Center coordinates, ROI Area
* **Saves:** `handles.DataSet` as `video_filename.mat` in the same folder as the video

### Batch Process
* **Requires:** Collection of Image/Video Files (Same as Process File for a set of files), Filetype selection, Frame Rate, Threshold Level, ROI Mask
*  **Calculates:** dF/F using average of 50 previous frames, Mean Intensity, ROI size, ROI Center coordinates, ROI Area
* **Saves:** `handles.DataSet` as `video_filename.mat` in the same folder as the video
 
### Generate ROI Mask
* **Requires:** Image/Video Files, Filetype Selection, Threshold Level, Struct Element Size, IMOpen repeats
* **Calculates:** a ROI Mask based on Struct Element Size after normalization to a threshold level.
    * Using a threshold value defined by the user, the program thresholds the image/video file. 
Following thresholding, the program draws and numbers "globular" shapes around regions with statistically significant dF/F. 
These regions can be shrunk/expanded by increasing the Struct Element Size. 
* **Stores:** ROI Mask in `handles.DataSet.roiMask` 
* **Saves:** `DataSet` to `handles`
* **Outputs:** Image/Video with Mask Overlay

### Generate ROI Grid
* **Requires:** Image/Video Files, Filetype Selection, Threshold Level, ROI Grid Size
* **Calculates:** a ROI Grid based on Grid Size and normalizes to a threshold level.
    * Using a threshold value defined by the user, the program thresholds the image/video file. 
Following thresholding, the program draws and numbers a grid based on the ROI Grid Size input.
* **Stores:** ROI Mask in `handles.DataSet.roiMask` 
* **Saves:** `DataSet` to `handles`
* **Outputs:** Image/Video with Mask Overlay

### Load ROI Mask
* **Requires:** Imgage/Video File, filetype selectoin, ROI Mask File (of the form `*.mat` )
* **Imports:** Previous ROI mask to `handles.DataSet.roiMask` and saves `DataSet` to `handles`
* **Outputs:** Image/Video with Mask Overlay

### Save ROI Mask
* **Requires:** Generation of ROI Mask or Grid, Save Path (after OS prompting)
* **Saves:** `handles.DataSet.roiMask` as a `.mat` file with a user defined name and location 

---


    
## Load Data Functions 

### Load Data
* **Requires:** `*.mat` containing `handles.DataSet` 
* **Clears:** Current value for `handles.DataSet`
* **Saves:** `*.mat` to `handles.DataSet` 
* **Plots:** Previous figures saved in `*.mat`

### Color ROIs by Peak dF/F
* **Requires:** Processed Data (see Process File or Load Data) 
* **Plots:** ROIs color coded by peak dF/F

### Classify Transients
* **Requires:** Processed Data (see Process File or Load Data) 
* **Calculates:** Transient index based on a baseline fit
    * Baseline is calculated using a moving average of dF/F with a window of 2x the frame rate (rounded down)
    * Negative noise is mirrored to create a noise histogram that is fit to a Gaussian curve 
    * Any noise that is 3 standard deviations above the baseline is flagged as statistically significant.
     * Transient index is calculated for all points
* **Plots:** dF/F color-coded heat map based on transient index and dF/F vs Time
* **Saves:** Transient Indices to `handles.DataSet.transients` 


### Plot Average dF/F Trace
* **Requires:** Processed Data (see Process File or Load Data) and Stim Frame Number
* **Calculates:** an average trace from all ROIs and an average decay constant based on first order curve fitting
* **Plots:** Calculated ROI trace overlaid with line used for curve fitting and stimulation line
* **Displays:** Decay Constant

### Stack All dF/F
* **Requires:** Processed Data (see Process File or Load Data) and Stim Frame Number
* **Plots:** Individual Traces for all ROIs and a stimulation line 

### Select ROI
* **Requires:** Processed Data (see Process File or Load Data) 
* **Output:**  Highlights Selected ROI on figure

### Show All ROIs
* **Requires:** Processed Data (see Process File or Load Data) 
* **Output:** Plots all ROIs on the image/video file

### Delete Selected ROI
* **Requires:** Processed Data (see Process File or Load Data) 
* **Deletes:** Selected ROI from Mask and DataSet
* **Updates:** `handles.DataSet`
* **Note:** ROI indices are not updated when this is done so one should be careful of calling ROIs by their indices following deletion using this method

### Calculate Decay Constant
* **Requires:** Processed Data (see Process File or Load Data) 
* **Creates:** Traces *Struct* of ROI numbers and dF/F
* **Calculates:** The decay constants of each trace using Traces *struct*
* **Updates:** `handles.DataSet`
* **Plots:** Stack of all traces and histogram of all ROI values
* **Note:** Attempts to filter out strong outlier values for the decay constant 
    * Anything over 60s will be filtered out
    
### Color ROI By Decay Constant
* **Requires:** Processed Data (see Process File or Load Data) and Calculation of Decay Constants 
* **Plots:** An overlay of color-coded ROIs based on decay constant     

### Filter ROIs
* **Requires:** Processed Data (see Process File or Load Data) in the form of workspace variable `currentDataset`
    * `currentDataset` is generated when data is exported to the workspace or data is loaded into the workspace directly
* **Output:** Filtered ROIs projected onto image/video data 





---

### Export Data to Workspace
* **Requires:** Video File (see Load Stack) 
* **Clears:** currentDataset *struct*
* **Copies:** `handles.DataSet` to `currentDataset` in the workspace 
    