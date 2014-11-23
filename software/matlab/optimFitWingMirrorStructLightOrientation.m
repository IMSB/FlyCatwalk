function error=optimFitWingMirrorStructLightOrientation(D,DDebug,I,mask,wings,hinge,plotImage,veinNames,plotColor,par)

weights.weighted=1;
weights.inside.weight=0.3;
weights.inside.outline=0.05;
weights.inside.L1=0.05;
weights.inside.L2=0.5;
weights.inside.L3=0.5;
weights.inside.L4=0.25;
weights.inside.L5=0.5;
weights.outside.weight=0.7;
weights.outside.outline=0.4;
weights.outside.L1=0.01;
weights.outside.L2=0.08;
weights.outside.L3=0.2;
weights.outside.L4=0.2;
weights.outside.L5=0.01;


R1=[cos(par(end-1)) -sin(par(end-1)); sin(par(end-1)) cos(par(end-1))];
R2=[cos(par(end)) -sin(par(end)); sin(par(end)) cos(par(end))];
TAll1= par(end-5:end-4)';
TAll2= par(end-3:end-2)';
S=diag(par(end-7:end-6));
%rotate and translate wings
wings.left.all=R1*S*wings.single;
wings.left.all=[wings.left.all(1,:)+TAll1(1,:)+hinge(1,1);wings.left.all(2,:)+TAll1(2,:)+hinge(2,1)];
wings.right.all=R2*S*[wings.single(1,:);-wings.single(2,:)];
wings.right.all=[wings.right.all(1,:)+TAll2(1,:)+hinge(1,2);wings.right.all(2,:)+TAll2(2,:)+hinge(2,2)];

wings.all=[wings.left.all wings.right.all];

wings=getWingsAngles(wings,wings.ix,veinNames);
valAll=mirt3D_mexinterp(D,wings.all(1,:),wings.all(2,:),wings.angles');
%compute body mask
maskedAll=mirt2D_mexinterp(mask,wings.all(1,:),wings.all(2,:))>0.5;
toKeepAll=isfinite(valAll);

%new code
if weights.weighted
    errorInside=0;
    errorOutside=0;
    ixWings=[0 wings.ix];
    for q=1:2
        for p=1:length(veinNames)
            range=ixWings(q)+wings.(veinNames{p}).up.startIx:ixWings(q)+wings.(veinNames{p}).up.endIx;
            toKeep=toKeepAll(range);
            val=valAll(range);
            val(~toKeep)=[];
            masked=~maskedAll(range);
            masked(~toKeep)=[];
            distInside=val(masked==0);
            distOutside=val(masked==1);
            if ~isempty(distInside)
                errorInside=errorInside+sum(distInside.^2)/length(distInside)*weights.inside.(veinNames{p});
            end
            if ~isempty(distOutside)
                errorOutside=errorOutside+sum(distOutside.^2)/length(distOutside)*weights.outside.(veinNames{p});
            end
        end
    end
    error=weights.inside.weight*errorInside/sum(maskedAll==0)+weights.outside.weight*errorOutside/sum(maskedAll==1);
else
    val=valAll(toKeepAll);
    masked=~maskedAll(toKeepAll);
    error=sum((val.*(masked+1)).^2)/sum(masked+1);
end
if plotImage>0
    if plotImage==1
        imshow(I)
    elseif plotImage==3
        subplot(212)
        imshow(I)
    end
    hold on
    colors=lines(length(veinNames));
    colors=circshift(colors,[1 0]);
    ixWings=[0 wings.ix];
    for q=1:2
        for p=1:length(veinNames)
            wings.plot.(veinNames{p}).mask=maskedAll(:,ixWings(q)+wings.(veinNames{p}).up.startIx:ixWings(q)+wings.(veinNames{p}).up.endIx);
            wings.plot.(veinNames{p}).mask=wings.plot.(veinNames{p}).mask(:,toKeepAll(ixWings(q)+wings.(veinNames{p}).up.startIx:ixWings(q)+wings.(veinNames{p}).up.endIx));
            wings.plot.(veinNames{p}).data=wings.all(:,ixWings(q)+wings.(veinNames{p}).up.startIx:ixWings(q)+wings.(veinNames{p}).up.endIx);
            if isempty(plotColor)
                plot(wings.plot.(veinNames{p}).data(1,:),wings.plot.(veinNames{p}).data(2,:),'color',colors(p,:),'linewidth',3)
            else
                plot(wings.plot.(veinNames{p}).data(1,:),wings.plot.(veinNames{p}).data(2,:),'color',plotColor,'linewidth',1)
            end
        end
    end
    hold off
    drawnow
end