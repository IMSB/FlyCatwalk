function handles=checkData(handles)
if strcmp(handles.preferences.expDataDir,'')
    handles.preferences.expDataDir=uigetdir(handles.preferences.mainDataDir);    
    if handles.preferences.expDataDir==0
    set(handles.messageText,'String','Nothing was selected');
    return
    end
elseif handles.preferences.expDataDir==0
    handles.preferences.expDataDir=''
    return
end
expDirContent=listDirectories(handles.preferences.expDataDir);
%this will only be used for the preliminary data, the rest of the data will
%be in alphabetical order anyway
testedIndividuals=1:length(expDirContent);
handles.numData=length(testedIndividuals);

[~,alphabeticallySorted]=sort(expDirContent);
for p=1:handles.numData
    try
        toSort(p)=str2num(expDirContent{p}(find(expDirContent{p}=='_',1,'last')+1:end));
%         toSort(p)=str2num(expDirContent{p});
    catch
        toSort(p)=alphabeticallySorted(p);
    end
end
[~,ix]=sort(toSort);
for p=1:handles.numData
    handles.dataFolders(p).name=expDirContent{ix(p)};
end

handles.stats.numMales=0;
handles.stats.numMalesUnchecked=0;
handles.stats.numFemales=0;
handles.stats.numFemalesUnchecked=0;
%new parallel code
r=0;
    
% try 
%     matlabpool open 
% end

ppm = ParforProgressStarter2('Loading data...', length(handles.dataFolders), 0.1);
parfor p=1:length(handles.dataFolders)
    dataDir{p}=fullfile(handles.preferences.expDataDir,handles.dataFolders(p).name);
    sex(p)=nan;
    validData(p)=false;
    checkedData(p)=false;
    try
        dataFile=fullfile(dataDir{p},'FitResults.mat');
        saveData=load(dataFile);
        if saveData.saveData.sex.sex=='M'
            sex(p)=0;
        elseif saveData.saveData.sex.sex=='F'
            sex(p)=1;
        else
            sex(p)=2;
        end
        validData(p)=saveData.saveData.useFly&sex(p)~=2;       
        checkedData(p)=saveData.saveData.checked;
    end
    ppm.increment();
end

delete(ppm);
% try
%     matlabpool close
% end

handles.stats.numMales=sum(sex==0&checkedData&validData);
handles.stats.numMalesUnchecked=sum(sex==0&~checkedData&validData);
handles.stats.numFemales=sum(sex==1&checkedData&validData);
handles.stats.numFemalesUnchecked=sum(sex==1&~checkedData&validData);

%endof new parallel code
% wb=waitbar(0,'Loading data...');
% for p=1:handles.numData
%     dataDir=fullfile(handles.preferences.expDataDir,handles.dataFolders(p).name);
%     dataFile=fullfile(dataDir,'FitResults.mat');
%     if exist(dataFile,'file')
%         try
%             load(dataFile);
%             if ~isfield(saveData,'checked')
%                 saveData.checked=false;
%                 save(dataFile,'saveData');
%             end
%             if saveData.useFly
%                 if saveData.sex.sex=='M'
%                     if saveData.checked
%                         handles.stats.numMales=handles.stats.numMales+1;
%                     else
%                         handles.stats.numMalesUnchecked=handles.stats.numMalesUnchecked+1;
%                     end
%                 elseif saveData.sex.sex=='F'
%                     if saveData.checked
%                         handles.stats.numFemales=handles.stats.numFemales+1;
%                     else
%                         handles.stats.numFemalesUnchecked=handles.stats.numFemalesUnchecked+1;
%                     end
%                 end
%             end
%         end
%     end
%     waitbar(p/handles.numData,wb);
% end
% close(wb)
updateSex(handles);
handles.currentIx=1;
[success,handles]=plotResults(handles);
if ~success
    button = questdlg('The analysis failed or this experiment was never analyzed, do you want to run the analysis?','Run Analysis first','Yes','No','Yes');
    if strcmp(button,'Yes')
%         handles
          runAnalysis(handles);
        return;
    else
        set(handles.messageText,'String',sprintf('%d/%d\n(%s)',handles.currentIx,handles.numData,dataDir));
        axes(handles.resultsTextAxes)
        set(handles.resultsTextAxes,'visible','off')
        resultsMessage={sprintf('Fly %d/%d',handles.currentIx,handles.numData),...
            'FAILED OR NEVER ANALYZED'};
        cla
        text(0, 0.5, resultsMessage,'interpreter', 'latex','vert','bottom');
        %         text(0,0.5,txt,'interpreter','latex',...
        %             'horiz','left','vert','middle')
        axes(handles.resultsFigure)
    end
end
set(handles.visualCheckPanel,'Visible','on');
set(handles.previousPushbutton,'Enable','off');
set(handles.nextPushbutton,'Enable','on');
set(handles.fitResultsPanel,'Visible','on');
set(handles.plotOptionsPanel,'Visible','on');