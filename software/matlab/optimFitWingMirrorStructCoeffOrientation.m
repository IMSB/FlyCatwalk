function error=optimFitWingMirrorStructCoeffOrientation(D,I,mask,templateData,hinge,plotImage,upScaleFactor,veinNames,plotColor,par)
% global veinNames;
weights.weighted=1;
weights.inside.weight=0.3;
weights.inside.outline=0.05;
weights.inside.L1=0.05;
weights.inside.L2=0.5;
weights.inside.L3=0.5;
weights.inside.L4=0.5;
weights.inside.L5=0.5;
weights.outside.weight=0.7;
weights.outside.outline=0.75;
weights.outside.L1=0.05;
weights.outside.L2=0.05;
weights.outside.L3=0.5;
weights.outside.L4=0.05;
weights.outside.L5=0.01;
satDistance=10;
displacementPunisher=5.0;
%calculate indexes

[wings,ixUp]=getWingsFromParCoeff(par,templateData,upScaleFactor,hinge,veinNames);
wings=getWingsAngles(wings,ixUp,veinNames);
%interpolate the bwdist image
valAll=mirt3D_mexinterp(D,wings.all(1,:),wings.all(2,:),wings.angles');
colors=lines(length(veinNames));
ixWings=[0 ixUp];
if plotImage==1
    for q=1:2
        for p=1:length(veinNames)
            subplot(2,length(veinNames),p)
            plot(valAll(:,ixWings(q)+wings.(veinNames{p}).up.startIx:ixWings(q)+wings.(veinNames{p}).up.endIx),'color',colors(p,:)./q);
            if q==1
                hold on
            else
                hold off
            end
        end
    end
end

valAll=2*(1./(1+exp(-2*valAll/satDistance))-0.5);
maskedAll=mirt2D_mexinterp(mask,wings.all(1,:),wings.all(2,:))>0.5;
toKeepAll=isfinite(valAll);
%new code
if weights.weighted
    errorInside=0;
    errorOutside=0;
    ixWings=[0 ixUp];
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
    error=weights.inside.weight*errorInside+weights.outside.weight*errorOutside;
    T=[par(1:templateData.all.dataLength);par(templateData.all.dataLength+1:2*templateData.all.dataLength)];
    displacementPunishment=displacementPunisher*sum(T(1,:).^2+T(2,:).^2);
    error=error+displacementPunishment;

else
    val=valAll(toKeepAll);
    masked=~maskedAll(toKeepAll);
    error=sum((val.*(masked+1)).^2)/sum(masked+1);
end
if plotImage==1 || plotImage==2
    if plotImage==1
        subplot(2,length(veinNames),[length(veinNames)+1:2*length(veinNames)])
        imshow(I)
    end
    
    hold on
    colors=lines(length(veinNames));
    ixWings=[0 ixUp];
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
        plot([wings.all(1,ixWings(q)+wings.L2.up.startIx) wings.all(1,ixWings(q)+wings.L5.up.startIx)],[wings.all(2,ixWings(q)+wings.L2.up.startIx) wings.all(2,ixWings(q)+wings.L5.up.startIx)],'y')
        plot([wings.all(1,ixWings(q)+wings.L3.up.startIx) wings.all(1,ixWings(q)+wings.outline.up.startIx)],[wings.all(2,ixWings(q)+wings.L3.up.startIx) wings.all(2,ixWings(q)+wings.outline.up.startIx)],'y')
    end
    hold off
    drawnow
end