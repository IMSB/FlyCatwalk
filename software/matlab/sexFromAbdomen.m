function abdomenSex=sexFromAbdomen(data,debug)
if nargin<2
    debug.plot=0;
end
load('sexAbdTemplate.mat');
%get region props
s = regionprops(data.masks.abdomen, 'BoundingBox');
R=[cos(data.rot) -sin(data.rot);
    sin(data.rot) cos(data.rot)];
%rotate centroid around center
imageCenter=[size(data.masks.abdomen,2) size(data.masks.abdomen,1)]'/2;
rotatedCentroid=R*(data.centroids.abdomen-imageCenter)+imageCenter;
projectedCentroid=rotatedCentroid*data.scale+[data.displacement(2);data.displacement(1)];

rectX=[s.BoundingBox(1) s.BoundingBox(1)+s.BoundingBox(3) s.BoundingBox(1)+s.BoundingBox(3) s.BoundingBox(1)];
rectY=[s.BoundingBox(2) s.BoundingBox(2) s.BoundingBox(2)+s.BoundingBox(4) s.BoundingBox(2)+s.BoundingBox(4)];
rotatedRect=R*([rectX;rectY]-repmat(imageCenter,1,4))+repmat(imageCenter,1,4);
projectedRect=rotatedRect*data.scale+repmat([data.displacement(2);data.displacement(1)],1,4);
bBox=[min(projectedRect(1,:)) min(projectedRect(2,:)) max(projectedRect(1,:))-min(projectedRect(1,:)) max(projectedRect(2,:))-min(projectedRect(2,:))];
ICrop=imcrop(data.bright(:,:,1),bBox);
ICropB=imcrop(data.backgroundC(:,:,3)-data.bright(:,:,3),bBox);
ICropMask=imcrop(data.WSInFly,bBox);

if debug.plot>0
    figure
    imshow(data.bright)
    hold on
    plot(projectedCentroid(1),projectedCentroid(2),'g*')
end

projectedCentroidCrop=projectedCentroid-bBox(1:2)';
G = fspecial('gaussian',[10 10],5);
%# Filter it
IBlurred = imfilter(ICrop,G,'same');

IRot = double(imrotate(IBlurred,data.rot*180/pi));
IRotB = imclose(imrotate(ICropB,data.rot*180/pi)<graythresh(ICropB)*1.1*255,strel('disk',5));
IRotMask = imrotate(ICropMask,data.rot*180/pi,'bicubic');

IRotMask2=IRotMask==0|IRotB;
lowIn=quantile(IRot(~IRotMask2),0.01)/255;
highIn=quantile(IRot(~IRotMask2),0.99)/255;
IRot=imadjust(IRot/255,[lowIn highIn],[0 1]);
IRot(IRotMask2)=nan;



medValues=nanmedian(IRot)/nanmean(IRot(:));
firstValid=find(diff(isnan(medValues))==-1,1,'first')+1;
if isempty(firstValid)
    firstValid=1;
end
lastValid=find(diff(isnan(medValues))==1,1,'last');
if isempty(lastValid)
    lastValid=length(medValues);
end
medValues=medValues(firstValid:lastValid);
medValuesS=spline(1:length(medValues),medValues,linspace(1,length(medValues),1000));
[b,a] = butter(3,[0.006,0.03]);
medValuesF=filtfilt(b,a,medValuesS);

abdomenSex.abdomenBrightness=medValuesS;
%evaluate 100 points alongs the main axis of the abdomen taking fly
%rotation as rotational angle (might consider using abdomen rotation in the
%future
x=linspace(1,size(IBlurred,2),100);
%y=ax+b
a=tan(data.rot);
b=projectedCentroidCrop(2)-a*projectedCentroidCrop(1);
y=a*x+b;
brightnessValues=mirt2D_mexinterp(double(IBlurred),x,y);
if debug.plot>0
    figure
    subplot(121)
    imshow(IBlurred)
    hold on
    plot(projectedCentroidCrop(1),projectedCentroidCrop(2),'g*')
    plot(x,y,'r')
    subplot(122)
    plot(brightnessValues)
    figure(1000)
    if data.sex.known=='M'
        plotColor=[0 0 1];
    elseif data.sex.known=='F'
        plotColor=[1 0 0];
    else
        plotColor=[0 1 0];
    end
    subplot(311)
    hold on
    plot(brightnessValues/mean(brightnessValues),'color',plotColor,'linewidth',2)
    subplot(312)
    hold on
    plot(medValuesS,'color',plotColor,'linewidth',2);
    subplot(313)
    hold on
    plot(medValuesF,'color',plotColor,'linewidth',2);
end
abdomenSex.AbdMedValuesF=medValuesF;
if debug.plot>0
    figure(1002)
    plot(medValuesF,'color',plotColor,'linewidth',2);
    hold on
    plot(sexAbdTemplate.males);
    plot(sexAbdTemplate.females,'r');
    hold off
    figure(1001)
    plot(medValuesF,sexAbdTemplate.males,'*');
    hold on
    plot(medValuesF,sexAbdTemplate.females,'r*');
    hold off
end
startIx=100;
stopIx=300;
maleR=corrcoef(medValuesF(startIx:stopIx),sexAbdTemplate.males(startIx:stopIx));
femaleR=corrcoef(medValuesF(startIx:stopIx),sexAbdTemplate.females(startIx:stopIx));
abdomenSex.RM=maleR(2);
abdomenSex.RF=femaleR(2);
medianAssBrightness=median(abdomenSex.abdomenBrightness(50:300));
sexThres=0.7; %below male, above female
if medianAssBrightness<sexThres
    abdomenSex.sex='M';
    abdomenSex.confidence=50*(sexThres-medianAssBrightness)/0.25+50;
else
    abdomenSex.sex='F';
    abdomenSex.confidence=50*(medianAssBrightness-sexThres)/0.25+50;
end