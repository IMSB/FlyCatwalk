function data=fitHead(data,figNumber,debug)
% debug.plot=1;
IR=data.bright(:,:,1);
IRAdj=IR;
headRot=data.fit.headR+data.rot;
load('ocelliTemplateLargeNew.mat');
BWFit = roipoly(IRAdj,data.fit.head(1,:),data.fit.head(2,:));
if debug.plot>0
    figure; imshow(BWFit); title('head mask');
end
BW=imrotate(BWFit,headRot*180/pi,'crop');
if debug.plot>0
    figure; imshow(BW); title('head rotated');
end
headRPE=regionprops(BW,'BoundingBox','Image');

se = [0 0 0; 1 1 0; 0 0 0];
for p=1:30
    BW=imdilate(BW,se);
end

se = [0 0 0; 0 1 1; 0 0 0];
for p=1:10
    BW=imerode(BW,se);
end

if debug.plot>0
    figure; imshow(BW); title('grown to the left');
end

BW=imerode(BW,strel('line', headRPE.BoundingBox(4)*0.3, 90));
if debug.plot>0
    figure; imshow(BW); title('head eroded');
end

IRAdjRot=imrotate(IRAdj,headRot*180/pi,'bilinear','crop');
if debug.plot>0
    figure; imshow(IRAdjRot); title('fly rotated');
end

headRP=regionprops(BW,'BoundingBox','Image');
headBB=headRP.BoundingBox;
IH=imcrop(IRAdjRot,[headBB(1) headBB(2) headBB(3)-1 headBB(4)-1]);
IHAdj=imadjust(IH);

IHAdj=adapthisteq(IHAdj);
IOcelliTemplate=adapthisteq(IOcelliTemplate);
RectOcelli=[(size(IOcelliTemplate,2)-67)/2 (size(IOcelliTemplate,1)-67)/2 67 67];
IOcelliTemplateC=imcrop(IOcelliTemplate,RectOcelli);
if debug.plot>0
    figure;
    imshow(IOcelliTemplateC);
end
[S,OY,OX] = findOcelli(IHAdj,IOcelliTemplateC,debug,figNumber);
OAbs=[OX+headBB(1);OY+headBB(2)];
OAbsR=rotateAroundImageCenter(IRAdj,OAbs,headRot);
OX=OAbsR(1);
OY=OAbsR(2);
IOD.OX=OX;
IOD.OY=OY;
IOD.headRPE=headRPE;
IOD.IRAdj=IRAdj;
IOD.headRot=headRot;
IOD.headBB=headBB;

for p=0;%-5:1:5
    IOD.OX=OX+p;%*cos(headRot);
    IOD.OY=OY;%+p*sin(headRot);
    [headSectionLine,start,stop]=findEyeFromOcelli(IOD,debug);
    data.centroids.ocelli=[IOD.OX,IOD.OY];
    if debug.plot>0
        figure(figNumber)
        plot(data.centroids.ocelli(1),data.centroids.ocelli(2),'*r');
        plot(headSectionLine(1,:),headSectionLine(2,:),'g');
        plot(headSectionLine(1,start),headSectionLine(2,start),'.y','markersize',15);
        plot(headSectionLine(1,stop),headSectionLine(2,stop),'.y','markersize',15);
    end
end
data.meas.body.head.IOD.val=norm(headSectionLine(:,stop)-headSectionLine(:,start))*data.meas.pixel2mm;
data.meas.body.head.IOD.units='mm';
data.IOD.headSectionLine=headSectionLine;
data.IOD.start=start;
data.IOD.stop=stop;
if debug.plot>=0
    if debug.plot==1
        figure(figNumber)
    else
        figure
    imshow(data.bright)
    hold on
    end
    plot(data.centroids.ocelli(1),data.centroids.ocelli(2),'*r');
    plot(headSectionLine(1,:),headSectionLine(2,:),'g');
    plot(headSectionLine(1,start),headSectionLine(2,start),'.y','markersize',15);
    plot(headSectionLine(1,stop),headSectionLine(2,stop),'.y','markersize',15);
end