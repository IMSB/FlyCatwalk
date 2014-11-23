function fixWings(handles)
dataDir=fullfile(handles.preferences.expDataDir,handles.dataFolders(handles.currentIx).name);
dataFile=fullfile(dataDir,'FitResults.mat');
load(dataFile);
hold off
imshow(saveData.bright);
        
onlyOutline=true;

if onlyOutline
    toFix=1;
else
    toFix=1:length(saveData.veinNames);
end

col=lines(length(toFix));
for p=toFix 
    set(handles.messageText,'String',sprintf('Select left wing''s %s starting from the hinge\nHit return when done',saveData.veinNames{p}))
    vein(p).raw=[];
    while true
        rawData=ginput(1);
        if ~isempty(rawData)
            vein(p).raw=[vein(p).raw rawData'];
            if size(vein(p).raw,2)>3
                vein(p).t=knotsChordLengthMethod(vein(p).raw');
                vein(p).pp = csape(vein(p).t,vein(p).raw,'clamped');
                vein(p).bs=fn2fm(vein(p).pp,'B-');
                hold off
                imshow(saveData.bright);
                hold on
                for q=1:p
                    plotPoints=fnplt(vein(q).pp);
                    plot(plotPoints(1,:),plotPoints(2,:),'linewidth',4,'color',col(q,:));
                end
            else
                hold off
                imshow(saveData.bright);
                hold on
                for q=1:p-1
                    plotPoints=fnplt(vein(q).pp);
                    plot(plotPoints(1,:),plotPoints(2,:),'linewidth',4,'color',col(q,:));
                end
                plot(vein(p).raw(1,:),vein(p).raw(2,:),'linewidth',4,'color',col(p,:));
            end
        else
            break
        end
    end
end

%length and width
veinNames={'outline','L1','L2','L3','L4','L5'};
wings=getWingsFromParCoeff(saveData.wings.wingMeas.fullO.fittedP,saveData.wings.wingMeas.templateData,saveData.wings.wingMeas.upScaleFactor,saveData.rotHinges,veinNames);
hold on
lengthPoints(:,1)=vein(1).raw(:,1);
h=plot(wings.all(1,wings.L3.up.startIx),wings.all(2,wings.L3.up.startIx),'wo','MarkerSize',75);
set(handles.messageText,'String','Select L3/outline intersection point for wing length')
[lengthPoints(1,2),lengthPoints(2,2)]=ginput(1); 
plot(lengthPoints(1,:),lengthPoints(2,:),'y');
delete(h)
h=plot(wings.all(1,wings.L2.up.startIx),wings.all(2,wings.L2.up.startIx),'wo','MarkerSize',75);
set(handles.messageText,'String','Select L2/outline intersection point for wing width')
[widthPoints(1,1),widthPoints(2,1)]=ginput(1); 
delete(h)
h=plot(wings.all(1,wings.L5.up.startIx),wings.all(2,wings.L5.up.startIx),'wo','MarkerSize',75);
set(handles.messageText,'String','Select L5/outline intersection point for wing width')
[widthPoints(1,2),widthPoints(2,2)]=ginput(1); 
plot(widthPoints(1,:),widthPoints(2,:),'y');
delete(h)

%recalculate area length and width
%area
outlinePoints=fnplt(vein(1).pp);
saveData.wings.wingMeas.manualCorrection.isCorrected=true;
saveData.wings.wingMeas.manualCorrection.left.outlinePoints=outlinePoints;
saveData.wings.wingMeas.manualCorrection.right.outlinePoints=outlinePoints;
saveData.wings.wingMeas.fullO.wings.left.area.val=polyarea(outlinePoints(1,:),outlinePoints(2,:))*saveData.meas.pixel2mm^2;
saveData.wings.wingMeas.fullO.wings.left.area.units='mm^2';
saveData.wings.wingMeas.fullO.wings.right.area.val=saveData.wings.wingMeas.fullO.wings.left.area.val;
saveData.wings.wingMeas.fullO.wings.right.area.units='mm^2';

%length
saveData.wings.wingMeas.fullO.wings.left.length.val=norm(lengthPoints(:,1)-lengthPoints(:,2))*saveData.meas.pixel2mm;
saveData.wings.wingMeas.fullO.wings.left.length.units='mm^2';
saveData.wings.wingMeas.manualCorrection.left.lengthPoints=lengthPoints;
saveData.wings.wingMeas.fullO.wings.right.length.val=saveData.wings.wingMeas.fullO.wings.left.length.val;
saveData.wings.wingMeas.fullO.wings.right.length.units='mm^2';
saveData.wings.wingMeas.manualCorrection.right.lengthPoints=lengthPoints;
%width
saveData.wings.wingMeas.fullO.wings.left.width.val=norm(widthPoints(:,1)-widthPoints(:,2))*saveData.meas.pixel2mm;
saveData.wings.wingMeas.fullO.wings.left.width.units='mm^2';
saveData.wings.wingMeas.manualCorrection.left.widthPoints=widthPoints;
saveData.wings.wingMeas.fullO.wings.right.width.val=saveData.wings.wingMeas.fullO.wings.left.width.val;
saveData.wings.wingMeas.fullO.wings.right.width.units='mm^2';
saveData.wings.wingMeas.manualCorrection.right.widthPoints=widthPoints;

save(dataFile,'saveData');
plotResults(handles);
set(handles.messageText,'String','Done Fixing the wing')