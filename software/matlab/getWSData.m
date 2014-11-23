function data=getWSData(data,debug)
%get thorax
%center of mass of different labels
% WS=data.WS;

labels=unique(data.WS);
labels(labels==0)=[];
    
%check if there are too many of too few body parts
if length(labels)==3
    checkingWS=false;
    for p=1:length(labels)
        stats(p) = regionprops(data.WS==labels(p), 'centroid','majorAxisLength','minorAxisLength','Orientation');
    end
    centroids=[stats.Centroid];
    sizes=[stats.MajorAxisLength ; stats.MinorAxisLength];
    orientations=[stats.Orientation];
    centroids=[centroids(1:2:length(centroids)-1); centroids(2:2:length(centroids))];
    [centroidsX,ix]=sort(centroids(1,:));
else
    checkingWS=true;
    stdDist=5;
end
iter=0;
while checkingWS
    clear stats
    iter=iter+1;
    %get the properties of the detected body parts
    labels=unique(data.WS);
    labels(labels==0)=[];
    for p=1:length(labels)
        try
            stat=regionprops(data.WS==labels(p), 'centroid','majorAxisLength','minorAxisLength','Orientation','Area');
            stats(p) =stat(1);
        catch
            disp('error');
        end
    end
    areas=[stats.Area];
    toSmall=areas<100;
    centroids=[stats.Centroid];
    sizes=[stats.MajorAxisLength ; stats.MinorAxisLength];
    orientations=[stats.Orientation];
    centroids=[centroids(1:2:length(centroids)-1); centroids(2:2:length(centroids))];
    [centroidsX,ix]=sort(centroids(1,:));
    toSmall=toSmall(ix);
    ix(toSmall)=[];

    if length(ix)>3
        fprintf('fusing... (iteration %.0f)\n',iter)
        load('ExpectedIntersections');
        %required for normalization
        haveFly=sum(data.WS)~=0;
        flyStart=find(diff(haveFly)>0,1,'first');
        flyEnd=find(diff(haveFly)<0,1,'last');
        flyLength=flyEnd-flyStart;
        %look for intersections along the x axis
        toFuse=[];
        for p=1:length(ix)-1
            stats2=regionprops(imdilate(data.WS==labels(ix(p)),ones(3))&imdilate(data.WS==labels(ix(p+1)),ones(3)), 'centroid');
            if ~isempty(stats2)
                if ~sum((abs((flyEnd-stats2.Centroid(1))/flyLength-expectedIntersections.pos)>expectedIntersections.std*stdDist)==0)
                    %perform fusion
                    toFuse=[toFuse p];
                end
            end
        end
        WS2=data.WS;
        toDelete=false(1,length(ix));
        for p=1:length(toFuse)
            WS2(WS2==ix(toFuse(p)+1))=ix(toFuse(p));
            toDelete(toFuse(p)+1)=true;
        end
        ix(toDelete)=[];
        data.WS=WS2;
        clear('stats');
        stdDist=stdDist-0.1;
        %     data.intersections=nan;
    elseif length(ix)<3
        disp('rewatersheding...')
        %not implemented yet
        load('ExpectedIntersections');
        %required for normalization
        haveFly=sum(data.WS)~=0;
        flyStart=find(diff(haveFly)>0,1,'first');
        flyEnd=find(diff(haveFly)<0,1,'last');
        flyLength=flyEnd-flyStart;
        
        stats2=regionprops(imdilate(data.WS==labels(ix(1)),ones(3))&imdilate(data.WS==labels(ix(2)),ones(3)), 'centroid');
        [~,ix2]=max(abs((flyEnd-stats2(1).Centroid(1))/flyLength-expectedIntersections.pos)./expectedIntersections.std);
        expInt=round(flyEnd-expectedIntersections.pos(2)*flyLength);
        
        for p=1:length(labels)
            stats(p) = regionprops(data.WS==labels(p), 'centroid','majorAxisLength','minorAxisLength','Orientation','Area');
        end
    
        ICropped=data.WS==labels(ix(ix2));
        ICropped=ICropped(:,expInt-30:expInt+30);
        IDist=bwdist(~ICropped);
        IDist=-IDist;
        IDist(~ICropped)=-inf;
        watersheding=true;
        minDist=0;
        while watersheding
            IDist2=imhmin(IDist,minDist);
            IWS=watershed(IDist2);
            IWS(IWS==IWS(1,1))=0;
            IWS(IWS==IWS(end,1))=0;
            labelsFew=unique(IWS);
            if length(labelsFew)<4
                watersheding=false;
                labelsFew(labelsFew==0)=[];
            else
                minDist=minDist+1;
            end
        end
        for p=1:2    
            statsFew(p)=regionprops(IWS==labelsFew(p), 'centroid');
        end
        
        centroidsFew=[statsFew.Centroid];
        centroidsFew=[centroidsFew(1:2:length(centroidsFew)-1); centroidsFew(2:2:length(centroidsFew))];
        [~,ixFew]=sort(centroidsFew(1,:));
        IUncropped=false(size(data.WS));
        IUncropped(:,expInt-30:expInt+30)=IWS==labelsFew(ixFew(end));
        IUncropped=imdilate(IUncropped,strel('disk',1));
        labels(end+1)=labels(end)+1;
        WSTemp=data.WS;
        WSTemp(IUncropped)=labels(end);
        maskRight=false(size(data.WS));
        maskRight(:,expInt+31:end)=true;
        WSTemp(WSTemp~=0&maskRight)=labels(end);
        %get rid of small residuals
        WSTemp2=zeros(size(data.WS));
        for p=1:length(labels)    
            statsRes=regionprops(WSTemp==labels(p), 'Area','pixelIdxList');
            [~,ixRes]=max([statsRes.Area]);
            WSTemp2(statsRes(ixRes).PixelIdxList)=p;
        end
        data.WS=WSTemp2;
    else
        checkingWS=false;
    end
end
%done with check

data.centroids.abdomen=centroids(:,ix(1));
data.centroids.thorax=centroids(:,ix(2));
data.centroids.head=centroids(:,ix(3));
data.masks.abdomen=data.WS==labels(ix(1));
data.masks.thorax=data.WS==labels(ix(2));
data.masks.head=data.WS==labels(ix(3));
if abs(orientations(ix(1)))<=45
    data.sizes.abdomen=sizes(:,ix(1));
else
    data.sizes.abdomen=flipud(sizes(:,ix(1)));
end
if abs(orientations(ix(1)))<=45
    data.sizes.thorax=sizes(:,ix(2));
else
    data.sizes.thorax=flipud(sizes(:,ix(2)));
end
if abs(orientations(ix(3)))<=45
    data.sizes.head=sizes(:,ix(3));
else
    data.sizes.head=flipud(sizes(:,ix(3)));
end

if debug.plot>0
    figure
    subplot(311)
    imshow(data.masks.abdomen)
    title('abdomen')
    subplot(312)
    imshow(data.masks.thorax)
    title('thorax')
    subplot(313)
    imshow(data.masks.head)
    title('head')
end
WS=data.WS~=0;
% thoraxLine=WS(:,round(centroidsX(2)));
centroidsX(2)=centroidsX(2)-data.sizes.thorax(1)*0.1;
thoraxLine=WS(:,round(centroidsX(2)));

hinges=find(diff(thoraxLine)~=0);
if length(hinges)>2
    error('too may hinges!');
end
data.hinges=[centroidsX(2) centroidsX(2);hinges(1) hinges(2)];
R=[cos(data.rot) -sin(data.rot); sin(data.rot) cos(data.rot)];
data.rotHinges=(R*(data.hinges-repmat([size(WS,2)/2 size(WS,1)/2]',1,2))+repmat([size(WS,2)/2 size(WS,1)/2]',1,2))*data.scale+repmat([data.displacement(2);data.displacement(1)],1,2);
% data.rotHinges=(data.hinges*data.scale);%+repmat([data.center(2) data.center(1)],2,1);