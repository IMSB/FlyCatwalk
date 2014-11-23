function [wingMeas,data]=fitWingMirrorStruct3(data,prepWings,figNumber,sex,debug)
warning off
veinNames=data.veinNames;
fineTuning.fineTune=1;
fineTuning.divider=3;
orientationDependent=1;
optDisplay='off'; %off, iter, final, notify
% optDisplay='iter'; %off, iter, final, notify
useCsape=1;
useFmincon=1;
useGa=1;
maxGaGenerations=100;
gaPopulationSize=200;

useMultistart=1;
useCustomStartPoints=1;  
fminconAlgorithm='interior-point';
plotTrans=debug.plot>1;
maxFunEval=10000;
tolX=1e-3;
TolFun=1e-3;
upScaleFactor=50;
maxTH=5;% in percent of wing length (it was 5%)
maxTV=5;% in percent of wing length (it was 5%)
maxR=5; % in deg
limSX=[0.85 1.05];
limSY=[0.9 1.05];
maxJitterPoints.outline=1.0;
maxJitterPoints.L1=0.5;
maxJitterPoints.L2=0.5;
maxJitterPoints.L3=0.5;
maxJitterPoints.L4=0.5;
maxJitterPoints.L5=1.5;

%veins
maxTVein.L1.H=0.5;% in percent of wing length
maxTVein.L1.V=0.5;
maxTVein.L2.H=0.5;
maxTVein.L2.V=0.5;
maxTVein.L3.H=0.5;
maxTVein.L3.V=0.5;
maxTVein.L4.H=0.5;
maxTVein.L4.V=0.5;
maxTVein.L5.H=0.5;
maxTVein.L5.V=0.5;

maxRVein.L1=2; % in deg
maxRVein.L2=2; % in deg
maxRVein.L3=2; % in deg
maxRVein.L4=2; % in deg
maxRVein.L5=2; % in deg

limSVein.L1.H=[0.95 1.05];
limSVein.L1.V=[0.95 1.05];
limSVein.L2.H=[0.95 1.05];
limSVein.L2.V=[0.95 1.05];
limSVein.L3.H=[0.95 1.05];
limSVein.L3.V=[0.95 1.05];
limSVein.L4.H=[0.95 1.05];
limSVein.L4.V=[0.95 1.05];
limSVein.L5.H=[0.9 1.1];
limSVein.L5.V=[0.9 1.1];

maxHingeDistance=30; %max distance from hinge detected from the thorax and hinge detected from the wings
if sex.sex=='F'
    load('wingTemplateStruct2013F')
else
    load('wingTemplateStruct2013M')
end
%get approximate wing position from image analysis

%rotate the image
IRot=imrotate(prepWings.BodyAndWingsMaskND,data.rot*180/pi,'crop');
%rotate the hinges in the image
R=[cos(-data.rot) -sin(-data.rot); sin(-data.rot) cos(-data.rot)];
RHinges=R*(data.rotHinges-repmat(flipud(size(IRot)'),1,2)/2)+repmat(flipud(size(IRot)'),1,2)/2;
if debug.plot>1
    figure
    imshow(IRot)
    hold on
    plot(RHinges(1,:),RHinges(2,:),'*')
end
% get the left most point
leftMost=find(max(IRot),1);
initWL=mean((RHinges(1,1)-leftMost)+(RHinges(1,2)-leftMost))/2;
% find rotation of wings according to mask size
%center a circle around hinge
angularSpan1=5;
angularSpan2=30;
angularSpan1C=5;
angularSpan2C=35;

prepWings.BodyAndWingsMask=imerode(prepWings.BodyAndWingsMask,strel('disk',5));
evAngles=linspace(data.rot+pi-angularSpan1/180*pi,data.rot+pi+angularSpan2/180*pi,100);
rotAngles=zeros(1,2);
evCircle1=[0.75*initWL*cos(evAngles)+data.rotHinges(1,1);0.75*initWL*sin(evAngles)+data.rotHinges(2,1)];
if debug.plot>0
    figure
    imshow(prepWings.BodyAndWingsMask)
    hold on
    plot(evCircle1(1,:),evCircle1(2,:));
end
todelete=evCircle1(1,:)<0 | evCircle1(1,:)>size(prepWings.BodyAndWingsMask,2) | evCircle1(2,:)<0 | evCircle1(2,:)>size(prepWings.BodyAndWingsMask,1);
evCircle1(:,todelete)=[];

insideCheck=logical(interp2(uint8(prepWings.BodyAndWingsMask),evCircle1(1,:),evCircle1(2,:),'nearest'));
ix=find(diff(insideCheck)==-1);
if isempty(ix)
    warning('you have a very big angle for the wing, which could represent a thresholding problem')
    ix=length(evAngles);
end
if length(ix)>1
    warning('you have a hole in the mask, or there is a leg on the way')
    [~,tokeep]=min(abs((data.rot+pi)-evAngles(ix)));
    ix=ix(tokeep); %keep the closest to zero angle
end
if debug.plot>0
    plot([data.rotHinges(1,1) evCircle1(1,ix(1))],[data.rotHinges(2,1) evCircle1(2,ix(1))],'r-*','markersize',10);
    plot(evCircle1(1,1),evCircle1(2,1),'g*','markersize',10);
end

evAnglesC=linspace(evAngles(ix)-angularSpan1C*pi/180,evAngles(ix)+angularSpan2C*pi/180,100);
evCircle1C=[0.2*initWL*cos(evAnglesC)+data.rotHinges(1,1);0.2*initWL*sin(evAnglesC)+data.rotHinges(2,1)];
if debug.plot>0
    hold on
    plot(evCircle1C(1,:),evCircle1C(2,:));
end
todelete=evCircle1C(1,:)<0 | evCircle1C(1,:)>size(prepWings.BodyAndWingsMask,2) | evCircle1C(2,:)<0 | evCircle1C(2,:)>size(prepWings.BodyAndWingsMask,1);
evCircle1C(:,todelete)=[];
insideCheckC=logical(interp2(uint8(prepWings.BodyAndWingsMask),evCircle1C(1,:),evCircle1C(2,:),'nearest'));
ixC=find(diff(insideCheckC)==-1);
if length(ixC)>1
    warning('you have a hole in the mask, or there is a leg on the way')
    [~,tokeepC]=min(abs((data.rot+pi)-evAnglesC(ixC)));
    ixC=ixC(tokeepC); %keep the closest to zero angle
end
if isempty(ixC)
    warning('you have a very big angle for the wing (short)')
    ixC=length(evAnglesC);
end
[~,ixC2]=min(abs(evAnglesC-(evAnglesC(ixC(end))-templateData.tiltAngleHinge)));
[newHingeX,newHingeY]=lineintersect([evCircle1(:,ix)' evCircle1C(:,ixC2)'],[data.rotHinges(:,1)' data.rotHinges(:,2)']);

if debug.plot>0
    plot([evCircle1(1,ix) evCircle1C(1,ixC)],[evCircle1(2,ix) evCircle1C(2,ixC)],'r-*','markersize',10);
    plot(newHingeX,newHingeY,'b+','markersize',10);
end

dVector=evCircle1(:,ix)-[newHingeX;newHingeY];
if norm(data.rotHinges(:,1)-[newHingeX;newHingeY])<maxHingeDistance
    data.rotHinges(:,1)=[newHingeX;newHingeY];
    rotAngles(1)=pi+atan2(dVector(2),dVector(1));
else
    rotAngles(1)=evAngles(ix(end))-pi;
end
evAngles=linspace(data.rot+pi+angularSpan1/180*pi,data.rot+pi-angularSpan2/180*pi,100);
evCircle2=[0.75*initWL*cos(evAngles)+data.rotHinges(1,2);0.75*initWL*sin(evAngles)+data.rotHinges(2,2)];
todelete=evCircle2(1,:)<0 | evCircle2(1,:)>size(prepWings.BodyAndWingsMask,2) | evCircle2(2,:)<0 | evCircle2(2,:)>size(prepWings.BodyAndWingsMask,1);
evCircle2(:,todelete)=[];
if debug.plot>0
    plot(evCircle2(1,:),evCircle2(2,:));
end
insideCheck=logical(interp2(uint8(prepWings.BodyAndWingsMask),evCircle2(1,:),evCircle2(2,:),'nearest'));
ix=find(diff(insideCheck)==-1);
if isempty(ix)
    warning('you have a very big angle for the wing, which could represent a thresholding problem')
    ix=length(evAngles);
end
if length(ix)>1
    warning('you have a hole in the mask, or there is a leg on the way')
    [~,tokeep]=min(abs((data.rot+pi)-evAngles(ix)));
    ix=ix(tokeep); %keep the closest to zero angle
end
if debug.plot>0
    plot([data.rotHinges(1,2) evCircle2(1,ix(1))],[data.rotHinges(2,2) evCircle2(2,ix(1))],'r-*','markersize',10);
    plot(evCircle2(1,1),evCircle2(2,2),'g*','markersize',10);
end

evAnglesC=linspace(evAngles(ix)+angularSpan1C*pi/180,evAngles(ix)-angularSpan2C*pi/180,100);
evCircle2C=[0.2*initWL*cos(evAnglesC)+data.rotHinges(1,2);0.2*initWL*sin(evAnglesC)+data.rotHinges(2,2)];
if debug.plot>0
    hold on
    plot(evCircle2C(1,:),evCircle2C(2,:));
end
todelete=evCircle2C(1,:)<0 | evCircle2C(1,:)>size(prepWings.BodyAndWingsMask,2) | evCircle2C(2,:)<0 | evCircle2C(2,:)>size(prepWings.BodyAndWingsMask,1);
evCircle2C(:,todelete)=[];
insideCheckC=logical(interp2(uint8(prepWings.BodyAndWingsMask),evCircle2C(1,:),evCircle2C(2,:),'nearest'));
ixC=find(diff(insideCheckC)==-1);
if length(ixC)>1
    warning('you have a hole in the mask, or there is a leg on the way')
    [~,tokeepC]=min(abs((data.rot+pi)-evAnglesC(ixC)));
    ixC=ixC(tokeepC); %keep the closest to zero angle
end
if isempty(ixC)
    warning('you have a very big angle for the wing (short)')
    ixC=length(evAnglesC);
end
[~,ixC2]=min(abs(evAnglesC-(evAnglesC(ixC(end))+templateData.tiltAngleHinge)));
[newHingeX,newHingeY]=lineintersect([evCircle2(:,ix)' evCircle2C(:,ixC2)'],[data.rotHinges(:,1)' data.rotHinges(:,2)']);

if debug.plot>0
    plot([evCircle2(1,ix) evCircle2C(1,ixC)],[evCircle2(2,ix) evCircle2C(2,ixC)],'r-*','markersize',10);
    plot(newHingeX,newHingeY,'b+','markersize',10);
end

dVector=evCircle2(:,ix)-[newHingeX;newHingeY];
if norm(data.rotHinges(:,2)-[newHingeX;newHingeY])<maxHingeDistance
    rotAngles(2)=pi+atan2(dVector(2),dVector(1));
    data.rotHinges(:,2)=[newHingeX;newHingeY];
else
    rotAngles(2)=evAngles(ix(1))-pi;
end
%define starting conditions
%coefficients in common between the two wings
coeffsTStart=[];
coeffsTLow=[];
coeffsTHigh=[];
for p=1:length(veinNames)
    coeffsTStart=horzcat(coeffsTStart,zeros(1,templateData.(veinNames{p}).bs.number*2));
    coeffsTLow=horzcat(coeffsTLow,-maxJitterPoints.(veinNames{p})/200*ones(1,templateData.(veinNames{p}).bs.number*2));
    coeffsTHigh=horzcat(coeffsTHigh,maxJitterPoints.(veinNames{p})/200*ones(1,templateData.(veinNames{p}).bs.number*2));
end
templateData.all.dataLength=length(coeffsTStart)/2;
%add veins
for p=2:length(veinNames)
    coeffsTStart=horzcat(coeffsTStart,[0 0 0 1 1]);
    coeffsTLow=horzcat(coeffsTLow,[-maxTVein.(veinNames{p}).H/200 -maxTVein.(veinNames{p}).V/200 -maxRVein.(veinNames{p})*pi/180 limSVein.(veinNames{p}).H(1) limSVein.(veinNames{p}).V(1)]);
    coeffsTHigh=horzcat(coeffsTHigh,[maxTVein.(veinNames{p}).H/200 maxTVein.(veinNames{p}).V/200 maxRVein.(veinNames{p})*pi/180 limSVein.(veinNames{p}).H(2) limSVein.(veinNames{p}).V(2)]);
end
scaleXStart=initWL;
scaleXLow=limSX(1)*initWL;
scaleXHigh=limSX(2)*initWL;
scaleYStart=initWL;
scaleYLow=limSY(1)*initWL;
scaleYHigh=limSY(2)*initWL;

%coefficients not in common
% translation with respect to estimated wing hinge position
WTStart=[0 0];
WTXLow=[-maxTH/100*initWL -maxTH/100*initWL];
WTXHigh=[maxTH/100*initWL maxTH/100*initWL];

WTYLow=[-maxTV/100*initWL -maxTV/100*initWL];
WTYHigh=[maxTV/100*initWL maxTV/100*initWL];
% rotation
WRStart=rotAngles;
WRLow=rotAngles-maxR*pi/180;
WRHigh=rotAngles+maxR*pi/180;

startP=[coeffsTStart scaleXStart scaleYStart WTStart WTStart WRStart];
lowP=[coeffsTLow scaleXLow scaleYLow WTXLow WTYLow WRLow];
highP=[coeffsTHigh scaleXHigh scaleYHigh WTXHigh WTYHigh WRHigh];
[distWing,distIX]=bwdist(prepWings.BWWing);
distWing=double(distWing);

if orientationDependent
    [distWingAngle,distWingAngleDebug]=angleDependentBWDist(prepWings.BWWing,debug);
end

%prepare images for plotting
IPlot=data.bright;
IPlotR=IPlot(:,:,1);
IPlotG=IPlot(:,:,2);
IPlotB=IPlot(:,:,3);
IPlotR(prepWings.BWWing==1)=255;
IPlotG(prepWings.BWWing==1)=255;
IPlotB(prepWings.BWWing==1)=255;
IPlot(:,:,1)=IPlotR;
IPlot(:,:,2)=IPlotG;
IPlot(:,:,3)=IPlotB;


%start with light version
%compute spline just once
wings.single=[];
wings.ix=0;
for p=1:length(veinNames)
    wings.(veinNames{p}).up.startIx=wings.ix+1;
    if useCsape
        wings.(veinNames{p}).up.data=fnval(csape(templateData.(veinNames{p}).eqSpacedT,...
            [templateData.outline.eqSpaced(:,templateData.(veinNames{p}).outlineIx) templateData.(veinNames{p}).eqSpaced(:,2:end)],'clamped'),...
            linspace(0,1,round(templateData.(veinNames{p}).segmentLength*upScaleFactor)));
    else
        wings.(veinNames{p}).up.data=spline(templateData.(veinNames{p}).eqSpacedT,...
            [templateData.outline.eqSpaced(:,templateData.(veinNames{p}).outlineIx) templateData.(veinNames{p}).eqSpaced(:,2:end)],...
            linspace(0,1,round(templateData.(veinNames{p}).segmentLength*upScaleFactor)));
    end
    wings.(veinNames{p}).up.endIx=wings.ix+length(wings.(veinNames{p}).up.data);
    wings.ix=wings.(veinNames{p}).up.endIx; %! wings.ix is also used later to add an offset to the left wing, do not reuse or delete
    wings.single=horzcat(wings.single,wings.(veinNames{p}).up.data);
end


if useMultistart
    opts = optimset('Algorithm',fminconAlgorithm,'MaxFunEvals',maxFunEval,'display',optDisplay);
    if orientationDependent
    problem = createOptimProblem('fmincon','objective',...
        @(par) optimFitWingMirrorStructLightOrientation(distWingAngle,distWingAngleDebug,IPlot,double(prepWings.blueMask),wings,data.rotHinges,plotTrans,data.veinNames,[],par),...
        'x0',startP(end-7:end),'lb',lowP(end-7:end),'ub',highP(end-7:end),'options',opts);
    else
        problem = createOptimProblem('fmincon','objective',...
        @(par)  optimFitWingMirrorStructLight(distWing,IPlot,double(prepWings.blueMask),wings,data.rotHinges,plotTrans,data.veinNames,[],par),...
        'x0',startP(end-7:end),'lb',lowP(end-7:end),'ub',highP(end-7:end),'options',opts);
    end
    ms = MultiStart;
    if useCustomStartPoints
        numStartPoints=3;
        for p=1:numStartPoints
            startPoint=startP(end-7:end);
            startPoint(2)=startPoint(2)+(highP(end-6)-startPoint(2))*(p-1)/(numStartPoints-1);
            startPointMat(p,:)=startPoint;
        end
        startPoints = CustomStartPointSet(startPointMat);
        [fittedPLight,errLight] = run(ms,problem,startPoints);
    else
        numStartPoints=20;
        [fittedPLight,errLight] = run(ms,problem,numStartPoints);
    end
else
    if useFmincon
        if orientationDependent
            [fittedPLight,errLight]=fmincon(@(par) optimFitWingMirrorStructLightOrientation(distWingAngle,distWingAngleDebug,IPlot,double(prepWings.blueMask),wings,data.rotHinges,plotTrans,data.veinNames,[],par),startP(end-7:end),[],[],[],[],lowP(end-7:end),highP(end-7:end),[],optimset('Algorithm',fminconAlgorithm,'MaxFunEvals',maxFunEval,'display',optDisplay));
        else
            [fittedPLight,errLight]=fmincon(@(par) optimFitWingMirrorStructLight(distWing,IPlot,double(prepWings.blueMask),wings,data.rotHinges,plotTrans,data.veinNames,[],par),startP(end-7:end),[],[],[],[],lowP(end-7:end),highP(end-7:end),[],optimset('Algorithm',fminconAlgorithm,'MaxFunEvals',maxFunEval,'display',optDisplay));
        end
    else
        if orientationDependent
            [fittedPLight,errLight]=fminsearchbnd(@(par) optimFitWingMirrorStructLightOrientation(distWingAngle,distWingAngleDebug,IPlot,double(prepWings.blueMask),wings,data.rotHinges,plotTrans,data.veinNames,[],par),startP(end-7:end),lowP(end-7:end),highP(end-7:end),optimset('display',optDisplay,'TolX',tolX,'TolFun',TolFun,'MaxFunEvals',maxFunEval));
        else
            [fittedPLight,errLight]=fminsearchbnd(@(par) optimFitWingMirrorStructLight(distWing,IPlot,double(prepWings.blueMask),wings,data.rotHinges,plotTrans,data.veinNames,[],par),startP(end-7:end),lowP(end-7:end),highP(end-7:end),optimset('display',optDisplay,'TolX',tolX,'TolFun',TolFun,'MaxFunEvals',maxFunEval));
        end
    end
end
if debug.plot>0
    figure(figNumber)
    optimFitWingMirrorStructLight(distWing,IPlot,double(prepWings.blueMask),wings,data.rotHinges,2,data.veinNames,[],fittedPLight);
end
wingMeas.light=extractWingMeasurementsCoeff([startP(1:end-8) fittedPLight],data,templateData,1000,veinNames,debug);
wingMeas.light.fittedP=fittedPLight;
wingMeas.light.wingsPlot=wings;
wingMeas.light.distWing=distWing;
wingMeas.light.error=errLight;
distWing=cleanWingImage(fittedPLight,prepWings.BWWing,wings,data.rotHinges,debug);

if fineTuning.fineTune
    startP(end-7:end)=fittedPLight;
    if fineTuning.divider~=0
        lowP(end-7:end)=fittedPLight-[(1-scaleXLow/initWL)/fineTuning.divider*initWL ...
            (1-scaleYLow/initWL)/fineTuning.divider*initWL ...
            maxTH/100*initWL/fineTuning.divider ...
            maxTH/100*initWL/fineTuning.divider ...
            maxTV/100*initWL/fineTuning.divider ...
            maxTV/100*initWL/fineTuning.divider ...
            maxR*pi/180/fineTuning.divider ...
            maxR*pi/180/fineTuning.divider];
        highP(end-7:end)=fittedPLight+[(scaleXHigh/initWL-1)/fineTuning.divider*initWL ...
            (scaleYHigh/initWL-1)/fineTuning.divider*initWL ...
            maxTH/100*initWL/fineTuning.divider ...
            maxTH/100*initWL/fineTuning.divider ...
            maxTV/100*initWL/fineTuning.divider ...
            maxTV/100*initWL/fineTuning.divider ...
            maxR*pi/180/fineTuning.divider ...
            maxR*pi/180/fineTuning.divider];
    else
        lowP(end-7:end)=fittedPLight;
        highP(end-7:end)=fittedPLight;
    end
    if useFmincon
        if orientationDependent
            if useGa
            initPop=zeros(gaPopulationSize,length(lowP));
            rng(1);
            for pop=1:length(lowP)
                initPop(:,pop) =random('norm',startP(pop),(highP(pop)-lowP(pop))/2,1,gaPopulationSize);
            end
            optGA = gaoptimset('UseParallel','always','TolFun',1e-9,'InitialPopulation',initPop,'PopulationSize',gaPopulationSize,'display',optDisplay,'Generations',maxGaGenerations);
            [fittedPO,errO]=ga(@(par) optimFitWingMirrorStructCoeffOrientation(distWingAngle,IPlot,double(prepWings.blueMask),templateData,data.rotHinges,plotTrans,upScaleFactor,data.veinNames,[],par),length(lowP),[],[],[],[],lowP,highP,[],optGA);
            fprintf('Error ga=%.2f\n',errO)
            [fittedPO,errO]=fmincon(@(par) optimFitWingMirrorStructCoeffOrientation(distWingAngle,IPlot,double(prepWings.blueMask),templateData,data.rotHinges,plotTrans,upScaleFactor,data.veinNames,[],par),fittedPO,[],[],[],[],lowP,highP,[],optimset('Algorithm',fminconAlgorithm,'MaxFunEvals',maxFunEval,'display',optDisplay));
            fprintf('Error fmincon=%.2f\n',errO)
            else
                [fittedPO,errO]=fmincon(@(par) optimFitWingMirrorStructCoeffOrientation(distWingAngle,IPlot,double(prepWings.blueMask),templateData,data.rotHinges,plotTrans,upScaleFactor,data.veinNames,[],par),startP,[],[],[],[],lowP,highP,[],optimset('Algorithm',fminconAlgorithm,'MaxFunEvals',maxFunEval,'display',optDisplay));
            end
        else
            [fittedP,err]=fmincon(@(par) optimFitWingMirrorStructCoeff(distWing,IPlot,double(prepWings.blueMask),templateData,data.rotHinges,plotTrans,upScaleFactor,data.veinNames,[],par),startP,[],[],[],[],lowP,highP,[],optimset('Algorithm',fminconAlgorithm,'MaxFunEvals',maxFunEval,'display',optDisplay));
        end
    else
        if orientationDependent
            [fittedPO,errO]=fminsearchbnd(@(par) optimFitWingMirrorStructCoeffOrientation(distWingAngle,IPlot,double(prepWings.blueMask),templateData,data.rotHinges,plotTrans,upScaleFactor,data.veinNames,[],par),startP,lowP,highP,optimset('display',optDisplay,'MaxFunEvals',maxFunEval));
        else
            [fittedP,err]=fminsearchbnd(@(par) optimFitWingMirrorStructCoeff(distWing,IPlot,double(prepWings.blueMask),templateData,data.rotHinges,plotTrans,upScaleFactor,data.veinNames,[],par),startP,lowP,highP,optimset('display',optDisplay,'MaxFunEvals',maxFunEval));
        end
    end
    if exist('fittedP','var')
        wingMeas.full=extractWingMeasurementsCoeff(fittedP,data,templateData,1000,veinNames,debug);
        wingMeas.full.fittedP=fittedP;
        wingMeas.full.distWing=distWing;
        wingMeas.full.error=err;
    end
    if exist('fittedPO','var')
        wingMeas.fullO=extractWingMeasurementsCoeff(fittedPO,data,templateData,1000,veinNames,debug);
        wingMeas.fullO.fittedP=fittedPO;
        wingMeas.fullO.error=errO;
    end
    wingMeas.templateData=templateData;
end
wingMeas.fitType.light=1;
wingMeas.fitType.fineTuning=fineTuning;
wingMeas.fitType.orientationDependent=1;
wingMeas.upScaleFactor=upScaleFactor;
wingMeas.manualCorrection.isCorrected=false;
wingMeas.manualCorrection.left.outlinePoints=[];
wingMeas.manualCorrection.right.outlinePoints=[];
wingMeas.manualCorrection.left.lengthPoints=[];
wingMeas.manualCorrection.right.lengthPoints=[];
wingMeas.manualCorrection.left.widthPoints=[];
wingMeas.manualCorrection.right.widthPoints=[];

warning on