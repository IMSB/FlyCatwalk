function error=optimFitWingMirrorStructCoeff(D,I,mask,templateData,hinge,plotImage,upScaleFactor,veinNames,plotColor,par)
% global veinNames;
weighted=1;
weightInside=0.2;
weightInsideOutline=0.05;
satDistance=5;
%calculate indexes

[wings,ixUp]=getWingsFromParCoeff(par,templateData,upScaleFactor,hinge,veinNames);
%interpolate the bwdist image
val=mirt2D_mexinterp(D,wings.all(1,:),wings.all(2,:));
val(val>satDistance)=satDistance;
%compute body mask
maskedAll=mirt2D_mexinterp(mask,wings.all(1,:),wings.all(2,:))>0.5;
tokeep=isfinite(val);
if weighted
    masked=~maskedAll;
    weightOutlines=1.0;
    weightVeins=1.0;
    
    valOutline=val([wings.outline.up.startIx:wings.outline.up.endIx ixUp+wings.outline.up.startIx:ixUp+wings.outline.up.endIx]);
    maskedOutline=masked([wings.outline.up.startIx:wings.outline.up.endIx ixUp+wings.outline.up.startIx:ixUp+wings.outline.up.endIx]);
    tokeep2=isfinite(valOutline);
    maskedOutline=maskedOutline(tokeep2);
    maskedOutline=weightInsideOutline*(maskedOutline==0)+(1-weightInsideOutline)*(maskedOutline==1);
    valOutline=valOutline(tokeep2);
    
    valVeins=val([wings.L1.up.startIx:wings.L5.up.endIx ixUp+wings.L1.up.startIx:ixUp+wings.L5.up.endIx]);
    maskedVeins=masked([wings.L1.up.startIx:wings.L5.up.endIx ixUp+wings.L1.up.startIx:ixUp+wings.L5.up.endIx]);
    tokeep2=isfinite(valVeins);
    maskedVeins=maskedVeins(tokeep2);
    maskedVeins=weightInside*(maskedVeins==0)+(1-weightInside)*(maskedVeins==1);
    valVeins=valVeins(tokeep2);
    
    if plotImage==3
        [X,Y] = meshgrid(1:size(mask,2),1:size(mask,1));
        Z = griddata(wings.all(1,:),wings.all(2,:),val,X,Y,'cubic');
        subplot(211)
        contourf(X,Y,Z,20,'linestyle','none')
        axis equal
        drawnow;
        colormap('jet');
        colorbar;
    end
    
    error=weightOutlines*(sum((valOutline.*(maskedOutline)).^2)/sum(maskedOutline))+weightVeins*(sum((valVeins.*(maskedVeins)).^2)/sum(maskedVeins));
else
    val=val(tokeep);
    masked=~maskedAll(tokeep);
    % error=sum(val.^2)./sum(tokeep);
    error=sum((val.*(masked+1)).^2)/sum(masked+1);
end
if plotImage==1 || plotImage==2
    if plotImage==1
        imshow(I)
    end
    hold on
    colors=lines(length(veinNames));
    ixWings=[0 ixUp];
    for q=1:2
        for p=1:length(veinNames)
            wings.plot.(veinNames{p}).mask=maskedAll(:,ixWings(q)+wings.(veinNames{p}).up.startIx:ixWings(q)+wings.(veinNames{p}).up.endIx);
            wings.plot.(veinNames{p}).mask=wings.plot.(veinNames{p}).mask(:,tokeep(ixWings(q)+wings.(veinNames{p}).up.startIx:ixWings(q)+wings.(veinNames{p}).up.endIx));
            wings.plot.(veinNames{p}).data=wings.all(:,ixWings(q)+wings.(veinNames{p}).up.startIx:ixWings(q)+wings.(veinNames{p}).up.endIx);
            if isempty(plotColor)
                plot(wings.plot.(veinNames{p}).data(1,:),wings.plot.(veinNames{p}).data(2,:),'color',colors(p,:),'linewidth',3)
            else
                plot(wings.plot.(veinNames{p}).data(1,:),wings.plot.(veinNames{p}).data(2,:),'color',plotColor,'linewidth',2)
            end
        end
        plot([wings.all(1,ixWings(q)+wings.L2.up.startIx) wings.all(1,ixWings(q)+wings.L5.up.startIx)],[wings.all(2,ixWings(q)+wings.L2.up.startIx) wings.all(2,ixWings(q)+wings.L5.up.startIx)],'y')
        plot([wings.all(1,ixWings(q)+wings.L3.up.startIx) wings.all(1,ixWings(q)+wings.outline.up.startIx)],[wings.all(2,ixWings(q)+wings.L3.up.startIx) wings.all(2,ixWings(q)+wings.outline.up.startIx)],'y')
    end
    hold off
    drawnow
end