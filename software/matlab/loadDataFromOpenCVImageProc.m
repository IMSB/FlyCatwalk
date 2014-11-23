function data=loadDataFromOpenCVImageProc(dataDir,debug)

    %get watershed image
    data.WS=imread(fullfile(dataDir,'ILabels.bmp'));
    %get rotation and crop parameters
    [~,rotCrop]=readBrightestData(dataDir);
    
    fileNames=dir(fullfile(dataDir,sprintf('temp*.bmp')));
    firstIx=str2double(fileNames(1).name(5:9));
    data.brightIx=find(strcmp({fileNames.name},sprintf('temp%05d.bmp',rotCrop(1))));
    % get brightest image from sequence
    data.bright=imread(fullfile(dataDir,sprintf('temp%05d.bmp',rotCrop(1))));
    % get quantile image
    %quant=calllib('flyImageProcDLL','getQuantile');
    % clean up memory
    %quant=calllib('flyImageProcDLL','cleanUp');
    BGName=dir(fullfile(dataDir,'background*.bmp'));
    data.background=imread(fullfile(dataDir,BGName.name));
    %get positions
    posFile=dir(fullfile(dataDir,'PositionData.txt'));
    posData=importdata(fullfile(dataDir,posFile.name));
    data.framePos.xPos=posData(:,2);
    data.framePos.yPos=posData(:,3);
    
    data.backgroundC=data.background(data.framePos.yPos(data.brightIx)+1:data.framePos.yPos(data.brightIx)+size(data.bright,1),...
    data.framePos.xPos(data.brightIx)+1:data.framePos.xPos(data.brightIx)+size(data.bright,2),:);

    data.WS(data.WS==-1)=0;
    %data.bright=uint8(bright);
    %data.quant=uint8(quant);
    data.center=[rotCrop(4);rotCrop(3)];
    data.scale=2.0;%1/rotCrop(4);
    data.rot=rotCrop(2)*pi/180;
    WSRot=imrotate(data.WS,-data.rot*180/pi,'crop');
    WSRotBig=imresize(WSRot,data.scale,'nearest');
    data.WSInFly=zeros(size(data.bright,1),size(data.bright,2));
    data.displacement=[data.center(1)-size(WSRotBig,1)/2; data.center(2)-size(WSRotBig,2)/2];
    data.WSInFly(round(data.displacement(1))+1:round(data.displacement(1))+size(WSRotBig,1),...
        round(data.displacement(2))+1:round(data.displacement(2))+size(WSRotBig,2))=WSRotBig;
    
    %extract wing hinge
    data=getWSData(data,debug);
    if debug.plot>0
        figure
        imshow(label2rgb(WSRot))
    end