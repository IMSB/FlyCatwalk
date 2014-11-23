function error=optimFitBody(D,I,template,plotImage,weights,par)

satD=10;
R=[cos(par(1)) -sin(par(1)); sin(par(1)) cos(par(1))];
T= par(2:3)';
S=diag(par(4:5));

transTemplate=R*(S*template);
transTemplate=[transTemplate(1,:)+T(1);transTemplate(2,:)+T(2)];

val=mirt2D_mexinterp(D,transTemplate(1,:),transTemplate(2,:));
if ~isempty(weights)
    val=val.*weights;
end
tokeep=isfinite(val);
val(val>satD)=satD;
error=sum(val(tokeep).^2)/sum(tokeep);

if plotImage==3
    [X,Y] = meshgrid(1:size(D,2),1:size(D,1));
    Z = griddata(transTemplate(1,:),transTemplate(2,:),val,X,Y,'cubic');
    subplot(211)
    contourf(X,Y,Z,20,'linestyle','none')
    axis equal
    drawnow;
    colormap('jet');
    colorbar;
end

if plotImage>0
    if plotImage==1
        imshow(label2rgb(I))
    elseif plotImage==3
        subplot(212)
        imshow(label2rgb(I))
    elseif plotImage==4
        imshow(D)
    end
    hold on
    plot(transTemplate(1,:),transTemplate(2,:),'r.','linewidth',3)
    hold off
    if plotImage~=2
        drawnow;
    end
end