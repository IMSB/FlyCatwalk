function wings=prepareWingNewLight(data,debug)
closeAdditionalHoles=true;
IR=data.bright(:,:,1);
IB=data.bright(:,:,3);
wings.red=IR;

IBG=data.background(:,:,3);
IBGC=IBG(data.framePos.yPos(data.brightIx)+1:data.framePos.yPos(data.brightIx)+size(IB,1),...
    data.framePos.xPos(data.brightIx)+1:data.framePos.xPos(data.brightIx)+size(IB,2));
IBGCF=medfilt2(IBGC,[15 15],'symmetric');
wings.blue=IB;

IB=imopen(imadjust(wiener2((255-(IBGCF-IB)),[5 5])),strel('disk',3));
H=imhist(IB);

% find threshold to detect wing overlap
[b,a] = butter(3,0.1);
medValuesH=filtfilt(b,a,H);
[~,ixOverlap]=max(medValuesH(100:150));
ixOverlap=ixOverlap+99+10;

%open to get body only mask
IBodyOnly=~im2bw(IB,graythresh(IB)*0.25);
IBodyOnly=imopen(IBodyOnly,strel('disk',6));
IBodyOnly = imdilate(IBodyOnly,strel('disk',9));

imcloseSize1=20;
IBodyWingMaskThres=(IBGCF-IB)>35;
IBodyWingMaskThresGrown=false(size(IBodyWingMaskThres,1)+imcloseSize1*4,size(IBodyWingMaskThres,2)+imcloseSize1*4);
IBodyWingMaskThresGrown(imcloseSize1*2+1:end-imcloseSize1*2,imcloseSize1*2+1:end-imcloseSize1*2)=IBodyWingMaskThres;
%get rid of the legs which tend to be very red
IWingsOnly=IBodyWingMaskThresGrown(imcloseSize1*2+1:end-imcloseSize1*2,imcloseSize1*2+1:end-imcloseSize1*2)&~IBodyOnly;
IWingsOnly=IWingsOnly&(IR>max(IR(IWingsOnly))*0.65);
IWingsOnlyGrown=false(size(IBodyWingMaskThres,1)+imcloseSize1*4,size(IBodyWingMaskThres,2)+imcloseSize1*4);
IWingsOnlyGrown(imcloseSize1*2+1:end-imcloseSize1*2,imcloseSize1*2+1:end-imcloseSize1*2)=IWingsOnly;

IWingsOnlyGrown=imclose(IWingsOnlyGrown,strel('disk',6));
IWingsOnlyGrown=imdilate(IWingsOnlyGrown,strel('disk',3));
IBodyWingMaskNoLegs=IBodyWingMaskThresGrown&~IWingsOnlyGrown;

if debug.plot>1
    figure; imshow(IBodyWingMaskNoLegs)
    title('get rid of legs');
end

IBodyWingMask=imclose(IBodyWingMaskNoLegs,strel('disk',imcloseSize1));
if debug.plot>1
    figure; imshow(IBodyWingMask)
    title('imclose');
end
IBodyWingMask = imfill(IBodyWingMask,'holes');
if debug.plot>1
    figure; imshow(IBodyWingMask)
    title('holes');
end

IBodyWingMask = bwareaopen(IBodyWingMask, round(size(IBodyWingMask,1)/3));
if debug.plot>1
    figure; imshow(IBodyWingMask)
    title('bwareaopen');
end
IBodyWingMask=IBodyWingMask(imcloseSize1*2+1:end-imcloseSize1*2,imcloseSize1*2+1:end-imcloseSize1*2);
%check if there are other non-closed holes in the wings
if closeAdditionalHoles
    IHoles=imdilate(IBodyWingMaskNoLegs,strel('disk',imcloseSize1*2));
    IHoles=imfill(IHoles,'holes');
    IHoles=imerode(IHoles,strel('disk',imcloseSize1*2));
    IHoles=IHoles(imcloseSize1*2+1:end-imcloseSize1*2,imcloseSize1*2+1:end-imcloseSize1*2);
    IDiff=IHoles&~IBodyWingMask&~imdilate(IBodyOnly,strel('disk',60));
    holesStats = regionprops(IDiff,'area','eccentricity','PixelList');
    ix=find([holesStats.Area]>2000 & [holesStats.Eccentricity]<0.98);
    IHoles=false(size(IHoles));
    for p=1:length(ix)
        pixelList=holesStats(ix(p)).PixelList;
        ix2=sub2ind(size(IHoles),pixelList(:,2),pixelList(:,1));
        IHoles(ix2)=true;
    end
    IBodyWingMask=IBodyWingMask|IHoles;
    IBodyWingMask = imfill(IBodyWingMask,'holes');
    if debug.plot>1
        figure; imshow(IBodyWingMask)
        title('filled holes');
    end
end

% round it up
IBodyWingMask=imopen(IBodyWingMask,strel('disk',30));

%select biggest object
L = bwlabel(IBodyWingMask);
stats = regionprops(L,'area'); % Selecting area of object
A = [stats.Area]; % Extracting area from regionprops
biggest = find(A==max(A)); % Selecting the biggest object
IBodyWingMask(L~=biggest) = 0; % Selecting the biggest object to image 
if debug.plot>1
    figure; imshow(IBodyWingMask)
    title('biggest object selected');
end
wings.BodyAndWingsMaskND=IBodyWingMask;
IBodyWingMask = imdilate(IBodyWingMask,strel('disk',4));

if debug.plot>1
    figure; imshow(IBodyWingMask)
    title('dilated');
end

wings.BodyAndWingsMask=IBodyWingMask;

% thres=0.025;
% ws=25;
% mIM=imfilter(IB,fspecial('disk',ws),'replicate');
IWingsThres=bwareaopen((imclose(adapthisteq(imtophat(wiener2(adapthisteq(IBGCF-IB,'NumTiles',[128 128]),[7 7]),strel('disk',5)))>70,strel('disk',3))),100);

IWingsThres=imclose(imdilate(edge(IB,'canny',0.1),strel('disk',1))|imdilate(IWingsThres,strel('disk',1)),strel('disk',5));
IWingsThres(~IBodyWingMask)=0;

%body and wings mask
%close to get wings and body
if debug.plot>1
    figure; imshow(IWingsThres)
    title('threshold');
end

wings.blueMask=IBodyOnly;

IWingsFilt=medfilt2(IWingsThres,[4 4]);
IWingsSub=(IWingsFilt-IBodyOnly)>0;

%add intersection between wings
IWingMask=imopen(IBodyWingMask-IBodyOnly,strel('disk',9));
%select biggest object
L = bwlabel(IWingMask);
stats = regionprops(L,'area'); % Selecting area of object
A = [stats.Area]; % Extracting area from regionprops
biggest = find(A==max(A)); % Selecting the biggest object
IWingMask(L~=biggest) = 0; % Selecting the biggest object to image 
if debug.plot>1
    figure; imshow(IWingMask)
    title('biggest object selected');
end
%endoff adding intersection

IWingsO = bwareaopen(IWingsSub, 100);
IWingsO(~IWingMask)=0;
IWings = bwmorph(skeleton(IWingsO)>15,'skel',Inf);

% toc
if debug.plot>1
    figure;
    ITemp=zeros(size(IWings,1),size(IWings,2),3);
    ITemp(:,:,2)=IWings;
    ITemp(:,:,1)=IWingsO;
    imshow(ITemp)
    title('new skeleton');
end

if debug.plot>=1
    figure
    ITempColor=uint8(zeros(size(IB,1),size(IB,2),3));
    ITempColor(:,:,1)=255*IBodyWingMask;
    ITempColor(:,:,3)=255*IBodyOnly;
    ITempColor(:,:,2)=255*IWings;
    imshow(IB)
    hold on
    h=imshow(ITempColor);
    alpha(h,0.8)
    title('body and wings mask');
end

se = strel('disk', 4);

lowI=double(quantile(IR(IBodyOnly),0.02))/255;
highI=double(quantile(IR(IBodyOnly),0.98))/255;
IWAdj=imadjust(IR,[lowI highI],[0 1]);

if debug.plot>1
    figure; imshow(IWAdj)
    title('imadjust');
end

IWFilt=medfilt2(IWAdj,[4,4]);
if debug.plot>1
    figure; imshow(IWFilt)
    title('noise removal');
end

IWTHD=imtophat(imcomplement(IWFilt),se);
IWTHB=imtophat(IWFilt,se);
if debug.plot>1
    figure;
    subplot(211)
    imshow(IWTHD)
    title('top hat dark');
    subplot(212)
    imshow(IWTHB)
    title('top hat bright');
end


IWTHAdjD=imadjust(IWTHD,[0.03 0.1],[0 1]);
IWTHAdjB=imadjust(IWTHB,[0.07 0.1],[0 1]);

IWTHAdjS=IWTHAdjD;
IWTHAdjS(IWTHAdjB>IWTHAdjD)=IWTHAdjB(IWTHAdjB>IWTHAdjD);

if debug.plot>1
    figure;
    subplot(311)
    imshow(IWTHAdjD)
    title('imadjust2 top hat dark');
    subplot(312)
    imshow(IWTHAdjB)
    title('imadjust2 top hat bright');
    subplot(313)
    imshow(IWTHAdjS)
    title('combined top hat');
end

IWTHAdjR=imrotate(IWTHAdjS,data.rot*180/pi,'bicubic','crop');
h = fspecial('sobel');
IWAdj2=imrotate(imfilter(IWTHAdjR,h,'replicate'),-data.rot*180/pi,'bicubic','crop');
IWAdj3=imrotate(imfilter(IWTHAdjR,h','replicate'),-data.rot*180/pi,'bicubic','crop');
if debug.plot>1
    figure; imshow(IWAdj2)
    title('sharpening filter');
end

IWAH=adapthisteq(IWAdj2);
IWAHV=adapthisteq(IWAdj3);

IWBW=im2bw(IWAH,graythresh(IR(IBodyOnly))*0.5);
IWBWV=im2bw(IWAHV,graythresh(IR(IBodyOnly))*0.5);
if debug.plot>1
    figure; 
    subplot(211)
    imshow(IWBW)
    subplot(212)
    imshow(IWBWV)
    title('binarization');
end

% for horizontal
IWAO = bwareaopen(IWBW, 3);
if debug.plot>1
    figure; imshow(IWAO)
    title('bwareaopen');
end

se = strel('disk', 1);
IWC=imclose(IWAO,se);
if debug.plot>1
    figure; imshow(IWC)
    title('imclose');
end
IWAO2 = bwareaopen(IWC, 20);
if debug.plot>1
    figure; imshow(IWAO2)
    title('bwareaopen');
end

%for vertical
IWAOV = bwareaopen(IWBWV, 3);
if debug.plot>1
    figure; imshow(IWAOV)
    title('bwareaopen vertical');
end

se = strel('disk', 1);
IWCV=imclose(IWAOV,se);
if debug.plot>1
    figure; imshow(IWCV)
    title('imclose vertical');
end
IWAO2V = bwareaopen(IWCV, 100);
if debug.plot>1
    figure; imshow(IWAO2V)
    title('bwareaopen vertical');
end

s=regionprops(IWAO2V,'eccentricity','pixelIdxList');
eccentricity=vertcat(s.Eccentricity);
toDelete=eccentricity<0.95; %not line enough
pixels=vertcat(s(toDelete).PixelIdxList);
IWAO2V(pixels)=false;

IWAO2=IWAO2|IWAO2V;
if debug.plot>1
    figure; imshow(IWAO2)
    title('combined');
end
BWFitHead = roipoly(IBodyOnly,data.fit.head(1,:),data.fit.head(2,:));
BWFitThorax = roipoly(IBodyOnly,data.fit.thorax.fit(1,:),data.fit.thorax.fit(2,:));
IBodyNoHeadNoThorax=IBodyOnly&~imdilate(BWFitHead,strel('disk',50))&~imerode(BWFitThorax,strel('disk',30));
IWAO2(~IBodyNoHeadNoThorax)=0;
IWAO2 = bwmorph(skeleton(imclose(IWAO2,strel('disk',1)))>15,'skel',Inf);

if debug.plot>=1
    figure
    ITempColor=uint8(zeros(size(IB,1),size(IB,2),3));
    ITempColor(:,:,1)=255*IWAO2;
    imshow(IWAdj)
    hold on
    h=imshow(ITempColor);
    alpha(h,0.5)
    title('wings in the body mask');
end

wings.BWWing=zeros(size(IB));
wings.BWWing(IBodyOnly)=IWAO2(IBodyOnly);
wings.BWWing(~IBodyOnly)=IWings(~IBodyOnly);

if debug.plot>=1
    figure
    ITempColor=uint8(zeros(size(IB,1),size(IB,2),3));
    ITempColor(:,:,1)=255*wings.BWWing;
    imshow(IWAdj)
    hold on
    h=imshow(ITempColor);
    alpha(h,0.5)
    title('all wings mask');
end