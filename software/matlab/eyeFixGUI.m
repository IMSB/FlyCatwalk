function varargout = eyeFixGUI(varargin)
% EYEFIXGUI MATLAB code for eyeFixGUI.fig
%      EYEFIXGUI, by itself, creates a new EYEFIXGUI or raises the existing
%      singleton*.
%
%      H = EYEFIXGUI returns the handle to a new EYEFIXGUI or the handle to
%      the existing singleton*.
%
%      EYEFIXGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EYEFIXGUI.M with the given input arguments.
%
%      EYEFIXGUI('Property','Value',...) creates a new EYEFIXGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eyeFixGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eyeFixGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eyeFixGUI

% Last Modified by GUIDE v2.5 23-Jan-2014 12:21:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eyeFixGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @eyeFixGUI_OutputFcn, ...
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


% --- Executes just before eyeFixGUI is made visible.
function eyeFixGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eyeFixGUI (see VARARGIN)
handles.handlesMainGUI=varargin{1};
handles.dataDir=fullfile(handles.handlesMainGUI.preferences.expDataDir,handles.handlesMainGUI.dataFolders(handles.handlesMainGUI.currentIx).name);
imageFiles=dir(fullfile(handles.dataDir,'temp*.bmp'));
imageFiles={imageFiles.name};
handles.numImages=length(imageFiles);
for p=1:handles.numImages
    handles.rawImages{p}=imread(fullfile(handles.dataDir,imageFiles{p}));
end
handles.ix=1;
imshow(handles.rawImages{handles.ix})
set(handles.messageText,'String',sprintf('%.f/%.f',handles.ix,handles.numImages));

%init slider
set(handles.imageSlider,'Value',1);
set(handles.imageSlider,'Max',handles.numImages);
sliderStep = [1, 5] / (get(handles.imageSlider,'Max') - get(handles.imageSlider,'Min'));
set(handles.imageSlider,'SliderStep', sliderStep);

% Choose default command line output for eyeFixGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eyeFixGUI wait for user response (see UIRESUME)
% uiwait(handles.eyeFixGUI);


% --- Outputs from this function are returned to the command line.
function varargout = eyeFixGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function imageSlider_Callback(hObject, eventdata, handles)
% hObject    handle to imageSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.ix=round(get(hObject,'Value'));
set(hObject,'Value',handles.ix);
imshow(handles.rawImages{handles.ix})
set(handles.messageText,'String',sprintf('%.f/%.f',handles.ix,get(hObject,'Max')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function imageSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Value',1.0)
set(hObject,'Min',1.0)
set(hObject,'Max',1000.0)
guidata(hObject, handles);

% --- Executes on button press in selectButton.
function selectButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fixIODS(handles);
close(handles.eyeFixGUI);
