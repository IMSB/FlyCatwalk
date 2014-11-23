function data=fitBodyParts(data,figNumber,debug)
optDisplay='off'; %off, iter, final, notify
useFmincon=0;
plotOpt=0;
maxFunEval=10000;
maxIter=1000;
tolX=1e-3;
TolFun=1e-3;

load('bodyTemplateStruct2');

%find intersections
ATInt=imdilate(imdilate(data.masks.thorax,strel('disk',1))+data.masks.abdomen==2,strel('disk',1)); %intersection between abdomen and thorax
THInt=imdilate(imdilate(data.masks.head,strel('disk',1))+data.masks.thorax==2,strel('disk',1)); %intersection between abdomen and thorax
%find borders of masks
contAbdomen=bwmorph(data.masks.abdomen==1,'remove');
contAbdomen(ATInt)=0;
contThorax=bwmorph(data.masks.thorax==1,'remove');
contThorax(ATInt)=0;
contThorax(THInt)=0;
contHead=bwmorph(data.masks.head==1,'remove');
contHead(THInt)=0;

BWD.abdomen=bwdist(contAbdomen);
BWD.thorax=bwdist(contThorax);
BWD.head=bwdist(contHead);
fitRes=nan(5,3);
for p=1:3
    if p==1;
        %fit abdomen
        tx=data.centroids.abdomen(1);
        ty=data.centroids.abdomen(2);
        lowLimits=[-5*pi/180 tx-0.1*size(BWD.abdomen,2) ty-0.1*size(BWD.abdomen,2) 0.9*data.sizes.abdomen(1) 0.9*data.sizes.abdomen(2)];
        highLimits=[5*pi/180 tx+0.1*size(BWD.abdomen,2) ty+0.1*size(BWD.abdomen,2) 1.1*data.sizes.abdomen(1) 1.1*data.sizes.abdomen(2)];
        startingValues=[0 tx ty data.sizes.abdomen(1) data.sizes.abdomen(2)];
        if useFmincon
            fitRes(:,p)=fmincon(@(par) optimFitBody(double(BWD.abdomen),data.WS,templateData.body.abdomen.fitModel,plotOpt,[],par),startingValues,[],[],[],[],lowLimits,highLimits,[],optimset('Algorithm','interior-point','MaxFunEvals',maxFunEval,'TolX',tolX,'TolFun',TolFun,'display',optDisplay,'MaxIter',maxIter));
        else
            fitRes(:,p)=fminsearchbnd(@(par) optimFitBody(double(BWD.abdomen),data.WS,templateData.body.abdomen.fitModel,plotOpt,[],par),startingValues,lowLimits,highLimits,optimset('display',optDisplay,'TolX',tolX,'TolFun',TolFun,'MaxFunEvals',maxFunEval,'MaxIter',maxIter));
        end
    end
    if p==2;
        %fit thorax
        tx=data.centroids.thorax(1);
        ty=data.centroids.thorax(2);
        lowLimits=[-10*pi/180 tx-0.2*size(BWD.thorax,2) ty-0.2*size(BWD.thorax,2) 0.5*data.sizes.thorax(1) 0.5*data.sizes.thorax(2)];
        highLimits=[10*pi/180 tx+0.2*size(BWD.thorax,2) ty+0.2*size(BWD.thorax,2) 2.0*data.sizes.thorax(1) 2.0*data.sizes.thorax(2)];
        startingValues=[0 tx ty data.sizes.thorax(1) data.sizes.thorax(2)];
        weights=ones(1,size(templateData.body.thorax.fitModel,2));
        weights(40:95)=2;
        weights(201-(40:95))=2;
        if useFmincon
            fitRes(:,p)=fmincon(@(par) optimFitBody(double(BWD.thorax),data.WS,templateData.body.thorax.fitModel,plotOpt,weights,par),startingValues,[],[],[],[],lowLimits,highLimits,[],optimset('Algorithm','interior-point','MaxFunEvals',maxFunEval,'TolX',tolX,'TolFun',TolFun,'display',optDisplay,'MaxIter',maxIter));
        else
            fitRes(:,p)=fminsearchbnd(@(par) optimFitBody(double(BWD.thorax),data.WS,templateData.body.thorax.fitModel,plotOpt,weights,par),startingValues,lowLimits,highLimits,optimset('display',optDisplay,'TolX',tolX,'TolFun',TolFun,'MaxFunEvals',maxFunEval,'MaxIter',maxIter));
        end
    end
    if p==3;
        %fit head
        tx=data.centroids.head(1);
        ty=data.centroids.head(2);
        lowLimits=[-5*pi/180 tx-0.1*size(BWD.head,2) ty-0.1*size(BWD.head,2) 0.9*data.sizes.head(1) 0.9*data.sizes.head(2)];
        highLimits=[5*pi/180 tx+0.1*size(BWD.head,2) ty+0.1*size(BWD.head,2) 1.1*data.sizes.head(1) 1.1*data.sizes.head(2)];
        startingValues=[0 tx ty data.sizes.head(1) data.sizes.head(2)];
        if useFmincon
            fitRes(:,p)=fmincon(@(par) optimFitBody(double(BWD.head),data.WS,templateData.body.head.fitModel,plotOpt,[],par),startingValues,[],[],[],[],lowLimits,highLimits,[],optimset('Algorithm','interior-point','MaxFunEvals',maxFunEval,'TolX',tolX,'TolFun',TolFun,'display',optDisplay,'MaxIter',maxIter));
        else
            fitRes(:,p)=fminsearchbnd(@(par) optimFitBody(double(BWD.head),data.WS,templateData.body.head.fitModel,plotOpt,[],par),startingValues,lowLimits,highLimits,optimset('display',optDisplay,'TolX',tolX,'TolFun',TolFun,'MaxFunEvals',maxFunEval,'MaxIter',maxIter));
        end
    end
end

data=plotBodyFitRes(templateData.body,fitRes,figNumber,data,debug);