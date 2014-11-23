function meas=extractWingMeasurementsCoeff(par,data,templateData,upScaleFactor,veinNames,debug)

hinge = data.rotHinges;

% if isLight
%     par=[zeros(
[wings,ixUp]=getWingsFromParCoeff(par,templateData,upScaleFactor,hinge,veinNames);

leftOutlineIx=wings.outline.up.startIx:wings.outline.up.endIx;
leftL1Ix=wings.L1.up.startIx:wings.L1.up.endIx;
rightOutlineIx=ixUp+wings.outline.up.startIx:ixUp+wings.outline.up.endIx;
rightL1Ix=ixUp+wings.L1.up.startIx:ixUp+wings.L1.up.endIx;

%substitute outline points closer to L1
leftAreaContour=wings.all(:,leftOutlineIx);
leftAreaL1=wings.all(:,leftL1Ix);
[~,startingPoint]=min(sum((repmat(leftAreaL1(:,1),1,length(leftOutlineIx))-leftAreaContour).^2));
leftArea=[fliplr(leftAreaL1) leftAreaContour(:,startingPoint:end)];
rightAreaContour=wings.all(:,rightOutlineIx);
rightAreaL1=wings.all(:,rightL1Ix);
[~,startingPoint]=min(sum((repmat(rightAreaL1(:,1),1,length(rightOutlineIx))-rightAreaContour).^2));
rightArea=[fliplr(rightAreaL1) rightAreaContour(:,startingPoint:end)];

if debug.plot>1
plot(leftAreaContour(1,:),leftAreaContour(2,:),'color',[1 0.2 0.2])
hold on
plot(leftAreaL1(1,:),leftAreaL1(2,:),'color',[1 0.5 0.5])
plot(leftArea(1,:),leftArea(2,:),'r')
fill(leftArea(1,:),leftArea(2,:),'r','facealpha',.2)

plot(rightAreaContour(1,:),rightAreaContour(2,:),'color',[0.2 0.2 1])
plot(rightAreaL1(1,:),rightAreaL1(2,:),'color',[0.5 0.5 1])
plot(rightArea(1,:),rightArea(2,:),'b')
fill(rightArea(1,:),rightArea(2,:),'b','facealpha',.2)
end

meas.wings.left.plot.areaContour=leftAreaContour;
meas.wings.left.plot.areaL1=leftAreaL1;
meas.wings.left.plot.area=leftArea;
meas.wings.right.plot.areaContour=rightAreaContour;
meas.wings.right.plot.areaL1=rightAreaL1;
meas.wings.right.plot.area=rightArea;
% meas.wings.left.area.val=polyarea(wings.all(1,leftOutlineIx),wings.all(2,leftOutlineIx))*data.meas.pixel2mm^2;
meas.wings.left.area.val=polyarea(leftArea(1,:),leftArea(2,:))*data.meas.pixel2mm^2;
meas.wings.left.area.units='mm^2';
%get scale
S=par(end-7:end-6);
meas.wings.left.scale.val=S;
meas.wings.left.lengthFromScale.val=S(1)*data.meas.pixel2mm;
meas.wings.left.lengthFromScale.units='mm';

meas.wings.left.length.val=norm(wings.all(:,wings.L3.up.startIx)-wings.all(:,wings.outline.up.startIx),2)*data.meas.pixel2mm;
meas.wings.left.length.units='mm';
% meas.wings.left.width.val=S(2)*data.meas.pixel2mm;
meas.wings.left.width.val=norm(wings.all(:,wings.L2.up.startIx)-wings.all(:,wings.L5.up.startIx),2)*data.meas.pixel2mm;
meas.wings.left.width.units='mm';
% meas.wings.right.area.val=polyarea(wings.all(1,rightOutlineIx),wings.all(2,rightOutlineIx))*data.meas.pixel2mm^2;
meas.wings.right.area.val=polyarea(rightArea(1,:),rightArea(2,:))*data.meas.pixel2mm^2;
meas.wings.right.area.units='mm^2';
meas.wings.right.scale.val=S;
meas.wings.right.lengthFromScale.val=S(1)*data.meas.pixel2mm;
meas.wings.right.lengthFromScale.units='mm';
meas.wings.right.length.val=norm(wings.all(:,ixUp+wings.L3.up.startIx)-wings.all(:,ixUp+wings.outline.up.startIx),2)*data.meas.pixel2mm;
meas.wings.right.length.units='mm';
% meas.wings.right.width.val=S(2)*data.meas.pixel2mm;
meas.wings.right.width.val=norm(wings.all(:,ixUp+wings.L2.up.startIx)-wings.all(:,ixUp+wings.L5.up.startIx),2)*data.meas.pixel2mm;
meas.wings.right.width.units='mm';