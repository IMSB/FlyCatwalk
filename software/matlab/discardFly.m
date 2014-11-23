function handles=discardFly(handles,discard)
dataDir=fullfile(handles.preferences.expDataDir,handles.dataFolders(handles.currentIx).name);
dataFile=fullfile(dataDir,'FitResults.mat');
load(dataFile);
saveData.useFly=~discard;

if discard
    if saveData.sex.sex=='M'
        handles.stats.numMales=handles.stats.numMales-1;
    elseif saveData.sex.sex=='F'
        handles.stats.numFemales=handles.stats.numFemales-1;
    end
else
    if saveData.sex.sex=='M'
        handles.stats.numMales=handles.stats.numMales+1;
    elseif saveData.sex.sex=='F'
        handles.stats.numFemales=handles.stats.numFemales+1;
    end
end

updateSex(handles);

save(dataFile,'saveData');
% plotResults(handles);
if discard
    set(handles.messageText,'String','Fly discarded')
else
    set(handles.messageText,'String','Fly retained')
end