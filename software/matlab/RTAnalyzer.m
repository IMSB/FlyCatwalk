function varargout = RTAnalyzer(varargin)
% RTANALYZER MATLAB code for RTAnalyzer.fig
%      RTANALYZER, by itself, creates a new RTANALYZER or raises the existing
%      singleton*.
%
%      H = RTANALYZER returns the handle to a new RTANALYZER or the handle to
%      the existing singleton*.
%
%      RTANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RTANALYZER.M with the given input arguments.
%
%      RTANALYZER('Property','Value',...) creates a new RTANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RTAnalyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RTAnalyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RTAnalyzer

% Last Modified by GUIDE v2.5 04-Sep-2013 11:59:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RTAnalyzer_OpeningFcn, ...
    'gui_OutputFcn',  @RTAnalyzer_OutputFcn, ...
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


% --- Executes just before RTAnalyzer is made visible.
function RTAnalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RTAnalyzer (see VARARGIN)

% Choose default command line output for RTAnalyzer
handles.output = hObject;
setWingXPath();
set(handles.messageBoxExperiment,'String','Welcome');
set(handles.messageBox,'String','Hit ''Start''');
handles.mainDataDir='\\imsbnas.ethz.ch\hafen\projects\wingx_catwalk\WingXDataRemote';
% handles.mainDataDirLocal='D:\Documents\wingX\RTdataLocal\';
% dataDir=uigetdir(dataDir,'Select experiment');
% try
%     matlabpool open 4
% end
distcomp.feature( 'LocalUseMpiexec', false )

while true
    try
        wb=waitbar(0,'Preparing for analysis');
        handles.cluster = parcluster();
        waitbar(0.5,wb,'Preparing for analysis')
        delete(handles.cluster.Jobs);
        waitbar(1,wb,'Preparing for analysis')
        pause(0.5)
        close(wb)
        break;
    catch
        pause(5)
    end
end

[~,name] = system('hostname');
if strcmp(strtrim(name),'vasco-lappy')||strcmp(strtrim(name),'FISSO-PC')
    handles.cluster.NumWorkers = 6;
elseif strcmp(strtrim(name),'wingX-PC')
    handles.cluster.NumWorkers = 6;
else
    handles.cluster.NumWorkers = 12;
end

handles.clusterCheckTimer = timer('TimerFcn',{@checkClusterTimer,handles},'ExecutionMode','fixedSpacing','Period', 60.0);
handles.clusterCheckTimerStarted=false;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RTAnalyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RTAnalyzer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in startPB.
function startPB_Callback(hObject, eventdata, handles)
% hObject    handle to startPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.messageBoxExperiment,'String','Listening...');
set(hObject,'Enable','off');
set(handles.stopPB,'Enable','on');
% handles.experimentDir=uigetdir(handles.mainDataDir,'Select experiment');
handles.experimentDirs=uigetdirn(handles.mainDataDir,'Select experiment');
handles.analysisTimer = timer('TimerFcn',{@analyzeSingleMeasurement,handles},'ExecutionMode','fixedSpacing','Period', 20.0);
guidata(hObject, handles);
start(handles.analysisTimer);
if ~handles.clusterCheckTimerStarted
    handles.clusterCheckTimerStarted=true;
    start(handles.clusterCheckTimer);
end
guidata(hObject, handles);

% --- Executes on button press in stopPB.
function stopPB_Callback(hObject, eventdata, handles)
% hObject    handle to stopPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Enable','off');
set(handles.startPB,'Enable','on');
try
    stop(handles.analysisTimer);
    delete(handles.analysisTimer);
end
set(handles.messageBoxExperiment,'String','Stopped listening');
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
try
    stop(handles.clusterCheckTimer);
    delete(handles.cluster.Jobs);
    pause(1);
    rmdir('C:\Users\flycatwalk\local_cluster_jobs','s');
end
delete(handles.clusterCheckTimer);
delete(hObject);
