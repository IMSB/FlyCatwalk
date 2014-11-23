function handles=runAnalysis(handles)
set(handles.messageText,'String','Analyzing...');
set(handles.visualCheckPanel,'Visible','off');
set(handles.fitResultsPanel,'Visible','off');
if strcmp(handles.preferences.expDataDir,'')
    testDirs=uigetdirn(handles.preferences.mainDataDir,'Select the test director(y/ies)');
    if isempty(testDirs)
        handles.preferences.expDataDir=0;
    else
        for p=1:length(testDirs)
            handles.preferences.expDataDir=testDirs{p};
            imshow(imread('waitCatWalk.png'));
            drawnow;
            CatWalkPostProcessing(handles.preferences.analysis.isParallel,handles.preferences.analysis.debug,handles.preferences.expDataDir,handles.messageText);
        end
    end
else
    imshow(imread('waitCatWalk.png'));
    drawnow;
    CatWalkPostProcessing(handles.preferences.analysis.isParallel,handles.preferences.analysis.debug,handles.preferences.expDataDir,handles.messageText);
end

if handles.preferences.expDataDir==0
    set(handles.messageText,'String','Nothing was selected');
    return
end
set(handles.messageText,'String','Done Analyzing');
set(handles.visualCheckPanel,'Visible','on');
set(handles.fitResultsPanel,'Visible','on');