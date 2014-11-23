function error=optimFitWingMirrorStructLight(D,I,mask,wings,hinge,plotImage,veinNames,plotColor,par)
weighted=1;
weightInside=0.3;
%calculate indexes

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
%interpolate the bwdist image
val=mirt2D_mexinterp(D,wings.all(1,:),wings.all(2,:));
%compute body mask
maskedAll=mirt2D_mexinterp(mask,wings.all(1,:),wings.all(2,:))>0.5;
tokeep=isfinite(val);
if weighted
    masked=~maskedAll;
    weightOutlines=0.5;
    weightVeins=1;
    
    valOutline=val([wings.outline.up.startIx:wings.outline.up.endIx wings.ix+wings.outline.up.startIx:wings.ix+wings.outline.up.endIx]);
    maskedOutline=masked([wings.outline.up.startIx:wings.outline.up.endIx wings.ix+wings.outline.up.startIx:wings.ix+wings.outline.up.endIx]);
    tokeep2=isfinite(valOutline);
    maskedOutline=maskedOutline(tokeep2);
    maskedOutline=weightInside*(maskedOutline==0)+(1-weightInside)*(maskedOutline==1);
    valOutline=valOutline(tokeep2);
    
    valVeins=val([wings.L1.up.startIx:wings.L5.up.endIx wings.ix+wings.L1.up.startIx:wings.ix+wings.L5.up.endIx]);
    maskedVeins=masked([wings.L1.up.startIx:wings.L5.up.endIx wings.ix+wings.L1.up.startIx:wings.ix+wings.L5.up.endIx]);
    
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
            wings.plot.(veinNames{p}).mask=wings.plot.(veinNames{p}).mask(:,tokeep(ixWings(q)+wings.(veinNames{p}).up.startIx:ixWings(q)+wings.(veinNames{p}).up.endIx));
            wings.plot.(veinNames{p}).data=wings.all(:,ixWings(q)+wings.(veinNames{p}).up.startIx:ixWings(q)+wings.(veinNames{p}).up.endIx);
            if isempty(plotColor)
                plot(wings.plot.(veinNames{p}).data(1,:),wings.plot.(veinNames{p}).data(2,:),'color',colors(p,:),'linewidth',3)
            else
                plot(wings.plot.(veinNames{p}).data(1,:),wings.plot.(veinNames{p}).data(2,:),'color',plotColor,'linewidth',1);
            end
        end
    end
    hold off
    drawnow
end