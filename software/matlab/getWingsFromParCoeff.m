function [wings,ixUp]=getWingsFromParCoeff(par,templateData,upScaleFactor,hinge,veinNames)

R1=[cos(par(end-1)) -sin(par(end-1)); sin(par(end-1)) cos(par(end-1))];
R2=[cos(par(end)) -sin(par(end)); sin(par(end)) cos(par(end))];
TAll1= par(end-5:end-4)';
TAll2= par(end-3:end-2)';
S=par(end-7:end-6);
T=[par(1:templateData.all.dataLength);par(templateData.all.dataLength+1:2*templateData.all.dataLength)];
wings.single=[];

%do outline first
bsOutline=templateData.outline.bs;
bsOutline.coefs=bsOutline.coefs+T(:,1:length(bsOutline.coefs));
wings.outline.up.data=fnval(bsOutline,linspace(0,1-1e-6,round(templateData.outline.segmentLength*upScaleFactor)));
wings.single=horzcat(wings.single,wings.outline.up.data);
% wings.(veinNames{1}).up.data=
ix=length(bsOutline.coefs);
ixUp=length(wings.outline.up.data);
wings.outline.up.startIx=1;
wings.outline.up.endIx=ixUp;
for p=2:length(veinNames)
    TVein=par((p-2)*5+2*templateData.all.dataLength+1:(p-2)*5+2*templateData.all.dataLength+2);
    RVein=[cos(par((p-2)*5+2*templateData.all.dataLength+3)) -sin(par((p-2)*5+2*templateData.all.dataLength+3)); sin(par((p-2)*5+2*templateData.all.dataLength+3)) cos(par((p-2)*5+2*templateData.all.dataLength+3))];
    SVein=par((p-2)*5+2*templateData.all.dataLength+4:(p-2)*5+2*templateData.all.dataLength+5);
    wings.(veinNames{p}).up.startIx=ixUp+1;
    bs=templateData.(veinNames{p}).bs;
    %     bs.coefs=RVein*(diag(SVein)*(bs.coefs+T(:,ix+1:ix+length(bs.coefs))+repmat(TVein',1,bs.number)));
    %     bs.coefs=RVein*((diag(SVein)*bs.coefs)+T(:,ix+1:ix+length(bs.coefs))+repmat(TVein',1,bs.number));
    centerPoint=repmat(templateData.(veinNames{p}).centerPoint',1,bs.number);
    bs.coefs=RVein*((diag(SVein)*bs.coefs-centerPoint)+repmat(TVein',1,bs.number))+centerPoint+T(:,ix+1:ix+length(bs.coefs));
    %dist=repmat(bs.coefs(:,1),1,length(wings.outline.up.data))-wings.outline.up.data;
    %[d,ixClosest]=min(dist(1,:).^2+dist(2,:).^2);
    %bs.coefs=[wings.outline.up.data(:,ixClosest) bs.coefs(:,2:end)];
    bs.coefs=bs.coefs-repmat(bs.coefs(:,1),1,size(bs.coefs,2))+repmat(fnval(bsOutline,templateData.(veinNames{p}).outlineIxBS),1,size(bs.coefs,2));
%     bs.coefs=[fnval(bsOutline,templateData.(veinNames{p}).outlineIxBS) bs.coefs(:,2:end)];
    wings.(veinNames{p}).up.data=fnval(bs,linspace(0,1,round(templateData.(veinNames{p}).segmentLength*upScaleFactor)));
    wings.(veinNames{p}).up.endIx=ixUp+length(wings.(veinNames{p}).up.data);
    ixUp=ixUp+length(wings.(veinNames{p}).up.data);
    ix=ix+length(bs.coefs); %! ix is also used later to add an offset to the left wing, do not reuse or delete
    wings.single=horzcat(wings.single,wings.(veinNames{p}).up.data);
end
% %rotate and translate wings
% wings.left.all=R1*wings.single+repmat(TAll1+hinge(:,1),1,length(wings.single));
% wings.right.all=R2*[wings.single(1,:);-wings.single(2,:)]+repmat(TAll2+hinge(:,2),1,length(wings.single));
%rotate and translate wings
wings.left.all=R1*diag(S)*wings.single;
wings.left.all=[wings.left.all(1,:)+TAll1(1,:)+hinge(1,1);wings.left.all(2,:)+TAll1(2,:)+hinge(2,1)];
wings.right.all=R2*diag(S)*[wings.single(1,:);-wings.single(2,:)];
wings.right.all=[wings.right.all(1,:)+TAll2(1,:)+hinge(1,2);wings.right.all(2,:)+TAll2(2,:)+hinge(2,2)];
wings.all=[wings.left.all wings.right.all];