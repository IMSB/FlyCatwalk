

function varargout = catWalkWingFitGUI(varargin)
% CATWALKWINGFITGUI MATLAB code for catWalkWingFitGUI.fig
%      CATWALKWINGFITGUI, by itself, creates a new CATWALKWINGFITGUI or raises the existing
%      singleton*.
%
%      H = CATWALKWINGFITGUI returns the handle to a new CATWALKWINGFITGUI or the handle to
%      the existing singleton*.
%

%      CATWALKWINGFITGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CATWALKWINGFITGUI.M with the given input arguments.
%
%      CATWALKWINGFITGUI('Property','Value',...) creates a new CATWALKWINGFITGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before catWalkWingFitGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to catWalkWingFitGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help catWalkWingFitGUI

% Last Modified by GUIDE v2.5 23-Jan-2014 12:57:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @catWalkWingFitGUI_OpeningFcn, ...
    'gui_OutputFcn',  @catWalkWingFitGUI_OutputFcn, ...
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


% --- Executes just before catWalkWingFitGUI is made visible.
function catWalkWingFitGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to catWalkWingFitGUI (see VARARGIN)

% Choose default command line output for catWalkWingFitGUI
handles.output = hObject;
set(hObject,'WindowStyle','Normal')
% handles.output =handles.resultsText;
% distcomp.feature( 'LocalUseMpiexec', false )
setWingXPath();
handles=loadPreferences(handles);

set(handles.bodyPlotCB,'Value',handles.preferences.plot.body);
set(handles.IODPlotCB,'Value',handles.preferences.plot.IOD);
set(handles.wingsPlotCB,'Value',handles.preferences.plot.wings);
set(handles.sortSexSeparatelyCB,'Value',handles.preferences.sorting.sortSeparately);

set(handles.dataDirEdit,'String',handles.preferences.mainDataDir);
set(handles.visualCheckPanel,'Visible','off');
set(handles.fitResultsPanel,'Visible','off');
set(handles.plotOptionsPanel,'Visible','off');
set(handles.selectionPanel,'Visible','on');
set(handles.statisticsPanel,'Visible','off');

set(handles.numSelectedET,'string',num2str(handles.preferences.sorting.numSelected));
set(handles.numTotalAnalyzedET,'string',num2str(handles.preferences.sorting.numTotalAnalyzed));

axes(handles.resultsFigure) 
imshow(imread('welcomeCatWalk.png'));
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes catWalkWingFitGUI wait for user response (see UIRESUME)
% uiwait(handles.catWalkGUI);


% --- Outputs from this function are returned to the command line.
function varargout = catWalkWingFitGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in analyzePushbutton.
function analyzePushbutton_Callback(hObject, eventdata, handles)
handles.preferences.expDataDir='';
set(handles.selectionPanel,'Visible','off');
set(handles.statisticsPanel,'Visible','off');
set(handles.analyzePushbutton,'Enable','off');
set(handles.checkResultsPushbutton,'Enable','off');
handles=runAnalysis(handles);
handles=checkData(handles);
set(handles.analyzePushbutton,'Enable','on');
set(handles.checkResultsPushbutton,'Enable','on');
set(handles.selectionPanel,'Visible','on');
set(handles.statisticsPanel,'Visible','on');
guidata(hObject, handles);
% hObject    handle to analyzePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function resultsFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resultsFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate resultsFigure



function dataDirEdit_Callback(hObject, eventdata, handles)
% hObject    handle to dataDirEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dataDirEdit as text
%        str2double(get(hObject,'String')) returns contents of dataDirEdit as a double

if exist(get(hObject,'String'),'dir')
    handles.preferences.mainDataDir
else
    set(hObject,'String','The selected directory does not exist!')
    set(hObject,'enable','inactive');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function dataDirEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataDirEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dataDirPushButton.
function dataDirPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to dataDirPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.preferences.mainDataDir=uigetdir;
set(handles.dataDirEdit,'String',handles.preferences.mainDataDir);
% Update handles structure
guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over dataDirEdit.
function dataDirEdit_ButtonDownFcn(hObject, eventdata, handles)
if strcmp(get(hObject,'String'),'The selected directory does not exist!')
    set(hObject,'String','');
    set(hObject,'enable','on');
end
% hObject    handle to dataDirEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkResultsPushbutton.
function checkResultsPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to checkResultsPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.preferences.expDataDir='';
set(handles.analyzePushbutton,'Enable','off');
set(handles.checkResultsPushbutton,'Enable','off');
handles=checkData(handles);
set(handles.analyzePushbutton,'Enable','on');
set(handles.checkResultsPushbutton,'Enable','on');
set(handles.selectionPanel,'Visible','on');
set(handles.statisticsPanel,'Visible','on');
guidata(hObject, handles);

% --- Executes on button press in nextPushbutton.
function nextPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to nextPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.previousPushbutton,'Enable','on');
handles.currentIx=handles.currentIx+1;
set(handles.currentIxET,'String',sprintf('%.0f/%.0f',handles.currentIx,handles.numData));
handles=plotAndCheck(handles);
% plotResults(handles);
if handles.currentIx+1>handles.numData;
    set(hObject,'Enable','off');
end
guidata(hObject, handles);

% --- Executes on button press in previousPushbutton.
function previousPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to previousPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.nextPushbutton,'Enable','on');
handles.currentIx=handles.currentIx-1;
set(handles.currentIxET,'String',sprintf('%.0f/%.0f',handles.currentIx,handles.numData));
plotAndCheck(handles);
% plotResults(handles);
if handles.currentIx==1
    set(hObject,'Enable','off');
end
guidata(hObject, handles);

% --- Executes on button press in FixIODPushbutton.
function FixIODPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to FixIODPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fixIOD(handles);

% --- Executes on button press in fixWingsPushbutton.
function fixWingsPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to fixWingsPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fixWings(handles);

% --- Executes when uipanel7 is resized.
function uipanel7_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close();


% --- Executes when user attempts to close catWalkGUI.
function catWalkGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to catWalkGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
GUIPreferences=handles.preferences;
save('catWalkWingFitGuiPreferences.mat','GUIPreferences');
delete(hObject);


% --- Executes during object creation, after setting all properties.
function visualCheckPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to visualCheckPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected object is changed in sexPanel.
function sexPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in sexPanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
name=get(eventdata.NewValue,'tag');
if strcmp(name,'sexMRadioButton')
    handles=changeSex(handles,'M');
elseif strcmp(name,'sexFRadioButton')
    handles=changeSex(handles,'F');
else
    handles=changeSex(handles,'X');
end
guidata(hObject, handles);

% --- Executes on button press in ViewSequencePushbutton.
function ViewSequencePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ViewSequencePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
viewSequence(handles);


% --- Executes on button press in discardCB.
function discardCB_Callback(hObject, eventdata, handles)
% hObject    handle to discardCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of discardCB
handles=discardFly(handles,get(hObject,'Value'));
guidata(hObject, handles);


% --- Executes on button press in bodyPlotCB.
function bodyPlotCB_Callback(hObject, eventdata, handles)
% hObject    handle to bodyPlotCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bodyPlotCB
handles.preferences.plot.body=get(hObject,'Value');
[~,handles]=plotResults(handles);
guidata(hObject, handles);

% --- Executes on button press in IODPlotCB.
function IODPlotCB_Callback(hObject, eventdata, handles)
% hObject    handle to IODPlotCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IODPlotCB
handles.preferences.plot.IOD=get(hObject,'Value');
[~,handles]=plotResults(handles);
guidata(hObject, handles);

% --- Executes on button press in wingsPlotCB.
function wingsPlotCB_Callback(hObject, eventdata, handles)
% hObject    handle to wingsPlotCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wingsPlotCB
handles.preferences.plot.wings=get(hObject,'Value');
[~,handles]=plotResults(handles);
guidata(hObject, handles);


% --- Executes on button press in selectionPushbutton.
function selectionPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to selectionPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% numControl=str2double(get(hObject,'String'));
% if isnan(numControl) || numControl<0
%     set(handles.numControlET,'String',handles.preferences.sorting.numControl)
%     set(handles.messageText,'String','Invalid entry in numControl, reverting to previous value')
% else
%     handles.sorting.numControl=numControl;
% end
% 
% numSelected=str2double(get(hObject,'String'));
% if isnan(numSelected) || numSelected<0
%     set(handles.numSelectedET,'String',handles.preferences.sorting.numSelected)
%     set(handles.messageText,'String','Invalid entry in numSelected, reverting to previous value')
% else
%     handles.sorting.numSelected=numSelected;
% end
runSelection(handles);
guidata(hObject, handles);


% --- Executes on button press in sortSexSeparatelyCB.
function sortSexSeparatelyCB_Callback(hObject, eventdata, handles)
% hObject    handle to sortSexSeparatelyCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sortSexSeparatelyCB
handles.preferences.sorting.sortSeparately=get(hObject,'Value');
guidata(hObject, handles);



function numControlET_Callback(hObject, eventdata, handles)
% hObject    handle to numControlET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numControlET as text
%        str2double(get(hObject,'String')) returns contents of numControlET as a double
numControl=str2double(get(hObject,'String'));
if isnan(numControl) || numControl<0
    set(hObject,'String',handles.preferences.sorting.numControl)
    set(handles.messageText,'String','Invalid entry in numControl, reverting to previous value')
else
    handles.preferences.sorting.numControl=numControl;
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function numControlET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numControlET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numSelectedET_Callback(hObject, eventdata, handles)
% hObject    handle to numSelectedET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numSelectedET as text
%        str2double(get(hObject,'String')) returns contents of numSelectedET as a double
numSelected=str2double(get(hObject,'String'));
if isnan(numSelected) || numSelected<0 || numSelected>handles.preferences.sorting.numTotalAnalyzed
    set(hObject,'String',handles.preferences.sorting.numSelected)
    set(handles.messageText,'String','Invalid entry in numSelected, reverting to previous value')
else
    handles.preferences.sorting.numSelected=numSelected;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function numSelectedET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numSelectedET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numTotalAnalyzedET_Callback(hObject, eventdata, handles)
% hObject    handle to numTotalAnalyzedET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numTotalAnalyzedET as text
%        str2double(get(hObject,'String')) returns contents of numTotalAnalyzedET as a double
numTotalAnalyzed=str2double(get(hObject,'String'));
if isnan(numTotalAnalyzed) || numTotalAnalyzed<0
    set(hObject,'String',handles.preferences.sorting.numTotalAnalyzed)
    set(handles.messageText,'String','Invalid entry in numTotalAnalyzed, reverting to previous value')
else
    handles.preferences.sorting.numTotalAnalyzed=numTotalAnalyzed;
end
updateSex(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function numTotalAnalyzedET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numTotalAnalyzedET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function currentIxET_Callback(hObject, eventdata, handles)
% hObject    handle to currentIxET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentIxET as text
%        str2double(get(hObject,'String')) returns contents of currentIxET as a double

desiredIxStr=get(hObject,'String');
slashIx=find(desiredIxStr=='/',1);
if isempty(slashIx)
    desiredIx=str2double(desiredIxStr);
else
    desiredIx=str2double(desiredIxStr(1:slashIx-1));
end
if desiredIx>0&&desiredIx<=handles.numData
    handles.currentIx=desiredIx;
    set(handles.previousPushbutton,'Enable','on');
    set(handles.nextPushbutton,'Enable','on');
    if handles.currentIx+1>handles.numData;
        set(handles.nextPushbutton,'Enable','off');
    end
    if handles.currentIx==1;
        set(handles.previousPushbutton,'Enable','off');
    end
    plotAndCheck(handles);
else
    set(hObject,'String',handles.currentIx);
end
set(handles.currentIxET,'String',sprintf('%.0f/%.0f',handles.currentIx,handles.numData));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function currentIxET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentIxET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numMalesET_Callback(hObject, eventdata, handles)
% hObject    handle to numMalesET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numMalesET as text
%        str2double(get(hObject,'String')) returns contents of numMalesET as a double


% --- Executes during object creation, after setting all properties.
function numMalesET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numMalesET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numFemalesET_Callback(hObject, eventdata, handles)
% hObject    handle to numFemalesET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numFemalesET as text
%        str2double(get(hObject,'String')) returns contents of numFemalesET as a double


% --- Executes during object creation, after setting all properties.
function numFemalesET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numFemalesET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function sexPanel_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to sexPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in FixIODSPushButton.
function FixIODSPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to FixIODSPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.IODGUI=eyeFixGUI(handles);
% close(handles.IODGUI);
% plotResults(handles);
% set(handles.messageText,'String','IOD changed')
