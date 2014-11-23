function handles=changeSex(handles,newSex)
dataDir=fullfile(handles.preferences.expDataDir,handles.dataFolders(handles.currentIx).name);
dataFile=fullfile(dataDir,'FitResults.mat');
load(dataFile);
oldSex=saveData.sex.sex;
saveData.sex.sex=newSex;

if oldSex=='M'
    handles.stats.numMales=handles.stats.numMales-1;
    if saveData.sex.sex=='F'
        handles.stats.numFemales=handles.stats.numFemales+1;
    end
elseif oldSex=='F'
    handles.stats.numFemales=handles.stats.numFemales-1;
    if saveData.sex.sex=='M'
        handles.stats.numMales=handles.stats.numMales+1;
    end
else
    if saveData.sex.sex=='F'
        handles.stats.numFemales=handles.stats.numFemales+1;
    else
         handles.stats.numMales=handles.stats.numMales+1;
    end
end

updateSex(handles);
save(dataFile,'saveData');
changeSexPanelBGColor(handles,[0 1 0]);