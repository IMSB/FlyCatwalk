function CatWalkPostProcessingSingle(dataDir,debug)
if nargin==0
    clear, close all
    clc
    debug.plot=0;
    dataDir='D:\Documents\wingX\temp\2014_02_05_09_31_17_000';
    debug.onlyBody=0;
else
    debug.onlyBody=0;
end
veinNames={'outline','L1','L2','L3','L4','L5'};
pixel2mm=3.190460e-03;

tic
fprintf('Analysing %s\n',dataDir);

data=loadDataFromOpenCVImageProc(dataDir,debug);

data.meas.pixel2mm=pixel2mm;
data.dataDir=dataDir;
data.veinNames=veinNames;
data.sex.known='X';
%Show the results of OpenCV computation
if debug.plot>0
    figure
    imshow(label2rgb(data.WS))
    hold on
    plot(data.hinges(1,:),data.hinges(2,:),'ro','markersize',10)
    title('wateshed')
    figure
    imshow(data.bright)
    title('brightest in red channel')
    figure
    imshow(data.bright)
    hold on
    h=imshow(label2rgb(data.WSInFly));
    alpha(h,0.2);
    plot(data.rotHinges(1,:),data.rotHinges(2,:),'ro','markersize',10)
    title('brightest in red channel')
elseif debug.plot==0
    figure(1)
    imshow(data.bright)
end
data=fitBodyParts(data,1000,debug);
%image preparation for wing fit
data=fitHead(data,1,debug);
dataAll=data;

if debug.onlyBody
    return;
end

flyNum=str2num(dataDir(end-2:end));
fprintf('Analysing %03f\n',flyNum);
sex=detectSex(dataAll,debug);
wings=prepareWingNewLight(dataAll,debug);
[wingMeas,dataAll]=fitWingMirrorStruct3(dataAll,wings,1,sex,debug);

dataAll.sex=sex;
dataAll.wings=wings;
dataAll.wings.wingMeas=wingMeas;
if debug.plot>=0
    plotWingFittingResult(dataAll,1);
    hold on
    plot(dataAll.rotHinges(1,:),dataAll.rotHinges(2,:),'go','markersize',10)
    text(50,50,sprintf('Fly %03f, sex %c, IOD=%.3fmm\n',flyNum, dataAll.sex.sexCombs.sex, dataAll.meas.body.head.IOD.val*pixel2mm),'fontsize',20,'color',[1 1 1]);
end
fprintf('Fly %03f, sex %c, IOD=%.3fmm\n',flyNum, dataAll.sex.sexCombs.sex, dataAll.meas.body.head.IOD.val);
saveData=dataAll;
saveData.useFly=true;
saveData.checked=false;
saveData.time=clock;
save(fullfile(dataAll.dataDir,'FitResults.mat'),'saveData');
totalExecTime=toc;
fprintf('time: %.2f s/fly\n',totalExecTime/length(dataAll))
delete(fullfile(dataDir,'Analyzing'));