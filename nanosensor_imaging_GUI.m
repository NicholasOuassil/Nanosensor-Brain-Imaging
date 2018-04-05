function varargout = nanosensor_imaging_GUI(varargin)
% NANOSENSOR_IMAGING_GUI MATLAB code for nanosensor_imaging_GUI.fig
%      NANOSENSOR_IMAGING_GUI, by itself, creates a new NANOSENSOR_IMAGING_GUI or raises the existing
%      singleton*.
%
%      H = NANOSENSOR_IMAGING_GUI returns the handle to a new NANOSENSOR_IMAGING_GUI or the handle to
%      the existing singleton*.
%
%      NANOSENSOR_IMAGING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NANOSENSOR_IMAGING_GUI.M with the given input arguments.
%
%      NANOSENSOR_IMAGING_GUI('Property','Value',...) creates a new NANOSENSOR_IMAGING_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nanosensor_imaging_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nanosensor_imaging_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nanosensor_imaging_GUI

% Last Modified by GUIDE v2.5 03-Apr-2018 23:24:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nanosensor_imaging_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @nanosensor_imaging_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before nanosensor_imaging_GUI is made visible.
function nanosensor_imaging_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nanosensor_imaging_GUI (see VARARGIN)

% Choose default command line output for nanosensor_imaging_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nanosensor_imaging_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = nanosensor_imaging_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in loadbutton.
function loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

%Load file
[FileName,PathName,FilterIndex] = uigetfile('*.mat');
if isequal(FileName,0)
    %Do nothing
else
    handles.dataset = load(strcat(PathName,'/',FileName));
    guidata(hObject,handles);%To save dataset to handles
    frameRate=str2double(get(handles.enterframerate,'String'));
    %CurrentFileLoaded();
    %set(handles.CurrentFileLoaded, 'String', FileName);

    %Plot file
    plotResults(handles.dataset.mask,handles.dataset.imagemed,handles.dataset.measuredValues,frameRate,handles);
   
    set(handles.CurrentFileLoaded,'String',FileName);
    assignin('base', 'measuredValues', handles.dataset.measuredValues) %Adds measuredValues for the loaded file to the current MATLAB workspace
    
    %Generate listbox containing list of each ROI for selection
    roiNames = 1:size(handles.dataset.measuredValues,2);
    roiNamesStr = num2str(roiNames');
    set(handles.roi_listbox,'Value',1); 
    set(handles.roi_listbox,'string',roiNamesStr);
    
end
% --- Executes on button press in processfilebutton.
function processfilebutton_Callback(hObject, eventdata, handles)
% hObject    handle to processfilebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

frameRate=str2double(get(handles.enterframerate,'String'));
if true(get(handles.radiobuttonSPE,'Value'))
    fileType = 'spe';
elseif true(get(handles.radiobuttonTIF,'Value'))
    fileType = 'tif';
end
[FileName,PathName,FilterIndex] = uigetfile(strcat('*.',fileType));
file = struct('name',FileName); %Convert to structure for consistency with batch processing code
if true(FilterIndex)
    
    %file.name = strcat(PathName,'/',FileName);
    %fprintf(1,'Processing file ')
        if strmatch(fileType,'spe')
            %Make progress bar
            barhandle = waitbar(0,'Loading Frame: x of x','Name',sprintf('Processing File 1 of 1'),...
                    'CreateCancelBtn',...
                    'setappdata(gcbf,''canceling'',1)');
            setappdata(barhandle,'canceling',0)

            [imagestack,filename]=loadIMstackSPE(PathName,file,1,barhandle);
        elseif strmatch(fileType,'tif')
            %Make progress bar
            barhandle = waitbar(0,'1','Name',sprintf('Processing File 1 of 1'),...
                    'CreateCancelBtn',...
                    'setappdata(gcbf,''canceling'',1)');
            setappdata(barhandle,'canceling',0)

            [imagestack,filename]=loadIMstackTIF(PathName,file,1,barhandle);
        else
            error('Error. Filetype must be "tif" or "spe"');
        end
        strelsize=get(handles.strelSlider,'Value');
        numopens=get(handles.numopens_slider,'Value');
        [Lmatrix,mask,imagemed]=processImage(imagestack,strelsize,numopens);
        [measuredValues]=processROI(imagestack,Lmatrix,barhandle,frameRate);
        if isempty(measuredValues)
            %do nothing
            delete(barhandle);
        else
            plotResults(mask,imagemed,measuredValues,frameRate,handles);
            %csvwrite(strcat(PathName,'/',FileName(1:end-4),'.csv'),measuredValues);
            savefig(strcat(PathName,'/',FileName(1:end-4)));
            save(strcat(PathName,'/',FileName(1:end-4),'.mat'),'Lmatrix','mask','imagemed','measuredValues');
            %handles.dataset.measuredValues = measuredValues;
            guidata(hObject,handles);%To save dataset to handles
            clear imagestack Lmatrix mask imagemed measuredValues 

            delete(barhandle);
        end

        %[FileName,PathName,FilterIndex] = uigetfile('*.mat');
        FileName = strcat(FileName(1:end-4),'.mat');
        handles.dataset = load(strcat(PathName,'/',FileName));
        guidata(hObject,handles);%To save dataset to handles
        assignin('base', 'measuredValues', handles.dataset.measuredValues) %Adds measuredValues for the loaded file to the current MATLAB workspace
        %Generate listbox containing list of each ROI for selection
        roiNames = 1:size(handles.dataset.measuredValues,2);
        roiNamesStr = num2str(roiNames');
        set(handles.roi_listbox,'Value',1); 
        set(handles.roi_listbox,'string',roiNamesStr);
end



% --- Executes on button press in batchprocessbutton.
function batchprocessbutton_Callback(hObject, eventdata, handles)
% hObject    handle to batchprocessbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
frameRate=str2double(get(handles.enterframerate,'String'));
if true(get(handles.radiobuttonSPE,'Value'))
    fileType = 'spe';
elseif true(get(handles.radiobuttonTIF,'Value'))
    fileType = 'tif';
end
strelsize=get(handles.strelSlider,'Value');
numopens=get(handles.numopens_slider,'Value');
batchProcessVideos(fileType,frameRate,strelsize,numopens,handles);

% --- Executes on button press in driftcheck.
function driftcheck_Callback(hObject, eventdata, handles)
% hObject    handle to driftcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of driftcheck

% --- Executes on button press in spikecheck.
function spikecheck_Callback(hObject, eventdata, handles)
% hObject    handle to spikecheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spikecheck

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [frameRate]=enterframerate_Callback(hObject, eventdata, handles)
% hObject    handle to enterframerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enterframerate as text
%        str2double(get(hObject,'String')) returns contents of enterframerate as a double
frameRate = get(hObject,'String');
frameRate = str2double(frameRate);

% --- Executes during object creation, after setting all properties.
function enterframerate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enterframerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','6.92');
input = str2double(get(hObject,'String'));
if isnan(input)
  errordlg('You must enter a numeric value','Invalid Input','modal')
  uicontrol(hObject)
  return

end

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in savedatabutton.
function savedatabutton_Callback(hObject, eventdata, handles)
% hObject    handle to savedatabutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function CurrentFileLoaded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentFileLoaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function strelSlider_Callback(hObject, eventdata, handles)
% hObject    handle to strelSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function strelSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strelSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function numopens_slider_Callback(hObject, eventdata, handles)
% hObject    handle to numopens_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function numopens_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numopens_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in radiobuttonSPE.
function radiobuttonSPE_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSPE


% --- Executes on button press in radiobuttonTIF.
function radiobuttonTIF_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonTIF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonTIF


% --- Executes on button press in selectROI.
function selectROI_Callback(hObject, eventdata, handles)
% hObject    handle to selectROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
roicoordinates=ginput(1);
d=[floor(roicoordinates(1)),floor(roicoordinates(2))];
selectedROI=handles.dataset.Lmatrix(d(2),d(1));
    if selectedROI == 0
        return
    else
    axes(handles.axes2);
    hold off
    x=1:size(handles.dataset.measuredValues(selectedROI).MeanIntensity,2);
    frameRate=str2double(get(handles.enterframerate,'String'));
    
    x=x./frameRate;
    plot(x,handles.dataset.measuredValues(selectedROI).dF);
    xlabel('Time (s)');
    ylabel('dF/F')
    title(sprintf('ROI: %s',num2str(selectedROI)));
end


% --- Executes on button press in CloseAll.
function CloseAll_Callback(hObject, eventdata, handles)
% hObject    handle to CloseAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(findall(0,'Type','Figure')) %Closes all open windows, including pesky waitbars


% --- Executes on button press in plotHistogram.
function plotHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to plotHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i=1:size(handles.dataset.measuredValues,2);
    ROIsize(i) = handles.dataset.measuredValues(i).Area(1);
end
axes(handles.axes2)
cla(handles.axes2)
hist(sqrt(ROIsize));
xlabel('sqrt(ROI size) (pixels)')
ylabel('Count')


% --- Executes on button press in plotAlldF.
function plotAlldF_Callback(hObject, eventdata, handles)
% hObject    handle to plotAlldF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
measuredValues=handles.dataset.measuredValues;
axes(handles.axes2);
hold off
for i=1:size(measuredValues,2)
    
    plot(measuredValues(i).dF)
    hold on
    xlabel('Time (s)')
    ylabel('dF/F')
end


% --- Executes on button press in CorrelationMatrix.
function CorrelationMatrix_Callback(hObject, eventdata, handles)
% hObject    handle to CorrelationMatrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes3);

hold off
data=handles.dataset.measuredValues;
for rois=1:size(data,2)
    allTraces(rois,:)=data(rois).dF;
end
R=corrcoef(allTraces');
imagesc(R);


% --------------------------------------------------------------------
function edit_Callback(hObject, eventdata, handles)
% hObject    handle to edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function copy_figure_Callback(hObject, eventdata, handles)
% hObject    handle to copy_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ax=gca;
newFig=figure('visible','off');
newHandle = copyobj(ax,newFig);
%print(newFig,'-noui','-clipboard','-dpdf');
editmenufcn(newFig,'EditCopyFigure')
delete(newFig);



% --- Executes on button press in calc_spike_slope.
function calc_spike_slope_Callback(hObject, eventdata, handles)
% hObject    handle to calc_spike_slope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

measuredValues=handles.dataset.measuredValues;
frameRate=str2double(get(handles.enterframerate,'String'));
spikeSlopes=[]; %Store slopes in this array
%fileNumbers = []; %Stores file number for each slope measurements
roiNumbers = []; %Stores roiNumber for each slope measurement

[spikeSlopes,roiNumbers]=computespikeslope(measuredValues,frameRate,spikeSlopes,roiNumbers);
axes(handles.axes2);
cla(handles.axes2);
notBoxPlot(spikeSlopes);
xlabel('All Spike Events')
ylabel('Slope ([dF/F]/s)')
axes(handles.axes3);
cla(handles.axes3);
hist(spikeSlopes)
xlabel('Slope ([dF/F]/s)')
ylabel('Counts')

% --- Executes on button press in batch_calc_spike_slope.
function batch_calc_spike_slope_Callback(hObject, eventdata, handles)
% hObject    handle to batch_calc_spike_slope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

frameRate=str2double(get(handles.enterframerate,'String'));

folder = uigetdir();
files=dir(strcat(folder,'/','*.mat'));

spikeSlopes=[]; %Store slopes in this array
%fileNumbers = []; %Stores file number for each slope measurements
roiNumbers = []; %Stores roiNumber for each slope measurement
for ifile = 1:length(files)

    load(strcat(folder,'/',files(ifile).name),'measuredValues');
    [spikeSlopes,roiNumbers]=computespikeslope(measuredValues,frameRate,spikeSlopes,roiNumbers);
end

axes(handles.axes2);
hold off
notBoxPlot(spikeSlopes);
xlabel('All Spike Events')
ylabel('Slope ([dF/F]/s)')
axes(handles.axes3);
hold off
hist(spikeSlopes)
xlabel('Slope ([dF/F]/s)')
ylabel('Counts')


% --- Executes on selection change in roi_listbox.
function roi_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to roi_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns roi_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roi_listbox
roi_selected = get(handles.roi_listbox,'Value');
axes(handles.axes2)
cla(handles.axes2)
plot(handles.dataset.measuredValues(roi_selected).dF)

% --- Executes during object creation, after setting all properties.
function roi_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in delete_roi_button.
function delete_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f = msgbox('Not Yet Operational. <3 Travis');
