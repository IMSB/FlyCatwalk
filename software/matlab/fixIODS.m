function fixIODS(handles)
dataFile=fullfile(handles.dataDir,'FitResults.mat');
load(dataFile);
I=handles.rawImages{handles.ix};
set(handles.messageText,'String','Select the head')
rec=imrect();
recPos = getPosition(rec);
ICrop=imcrop(I,recPos);

hold off
imshow(ICrop)
set(handles.messageText,'String','Draw a line and press enter when done')
h = imline;
pause;
% position = wait(h);
pos = h.getPosition();

% saveData.centroids.ocelli=mean(pos)+cropRect(1:2);
saveData.IOD.headSectionLine=[];
saveData.IOD.headSectionLine(1,:)=pos(:,1)';
saveData.IOD.headSectionLine(2,:)=pos(:,2)';
saveData.IOD.start=1;
saveData.IOD.stop=2;
saveData.IOD.fixedFromSequence=1;
saveData.IOD.ICrop=ICrop;
saveData.meas.body.head.IOD.val=sqrt(diff(pos)*diff(pos)')*saveData.meas.pixel2mm;
save(dataFile,'saveData');

axes(handles.handlesMainGUI.resultsFigure);
plotResults(handles.handlesMainGUI);
set(handles.handlesMainGUI.messageText,'String','IOD changed')