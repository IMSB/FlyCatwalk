function fixIOD(handles)
dataDir=fullfile(handles.preferences.expDataDir,handles.dataFolders(handles.currentIx).name);
dataFile=fullfile(dataDir,'FitResults.mat');
load(dataFile);

headMask = imdilate(roipoly(saveData.bright,saveData.fit.head(1,:),saveData.fit.head(2,:)),strel('disk',30));
stats=regionprops(headMask,'BoundingBox');
cropRect=round(stats.BoundingBox);
headCloseUp=imcrop(saveData.bright,cropRect);
hold off
imshow(headCloseUp)
set(handles.messageText,'String','Draw a line and press enter when done')
h = imline;
pause;
% position = wait(h);
pos = h.getPosition();

saveData.centroids.ocelli=mean(pos)+cropRect(1:2);
saveData.IOD.headSectionLine=[];
saveData.IOD.headSectionLine(1,:)=(pos(:,1)+cropRect(1))';
saveData.IOD.headSectionLine(2,:)=(pos(:,2)+cropRect(2))';
saveData.IOD.start=1;
saveData.IOD.stop=2;
saveData.meas.body.head.IOD.val=sqrt(diff(pos)*diff(pos)')*saveData.meas.pixel2mm;
save(dataFile,'saveData');
plotResults(handles);
set(handles.messageText,'String','IOD changed')