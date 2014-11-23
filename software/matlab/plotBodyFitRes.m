function data=plotBodyFitRes(template,fitRes,figNumber,data,debug)

%abdomen plot
R=[cos(fitRes(1,1)) -sin(fitRes(1,1)); sin(fitRes(1,1)) cos(fitRes(1,1))];
T= fitRes(2:3,1)';
S=diag(fitRes(4:5,1));
transTemplate=R*(S*template.abdomen.showModel);
transTemplate=[transTemplate(1,:)+T(1);transTemplate(2,:)+T(2)];
%now scale and translate to fit to onto the original image
R=[cos(data.rot) -sin(data.rot); sin(data.rot) cos(data.rot)];
abdomen=(R*(transTemplate-repmat([size(data.WS,2)/2 size(data.WS,1)/2]',1,length(transTemplate)))+repmat([size(data.WS,2)/2 size(data.WS,1)/2]',1,length(transTemplate)))*data.scale+repmat([data.displacement(2);data.displacement(1)],1,length(transTemplate));
if debug.plot>=0
    figure(figNumber)
    hold on
    plot(abdomen(1,:),abdomen(2,:),'g','linewidth',3);
end
data.fit.abdomen=abdomen;
data.fit.abdomenR=fitRes(1,1);
data.meas.body.abdomen.S=S;

%thorax fit plot
R=[cos(fitRes(1,2)) -sin(fitRes(1,2)); sin(fitRes(1,2)) cos(fitRes(1,2))];
T= fitRes(2:3,2)';
S=diag(fitRes(4:5,2));
transTemplate=R*(S*template.thorax.fitModel);
transTemplate=[transTemplate(1,:)+T(1);transTemplate(2,:)+T(2)];
%now scale and translate to fit to onto the original image
R=[cos(data.rot) -sin(data.rot); sin(data.rot) cos(data.rot)];
thorax=(R*(transTemplate-repmat([size(data.WS,2)/2 size(data.WS,1)/2]',1,length(transTemplate)))+repmat([size(data.WS,2)/2 size(data.WS,1)/2]',1,length(transTemplate)))*data.scale+repmat([data.displacement(2);data.displacement(1)],1,length(transTemplate));

hingeLineIx=29;
hingeLine=[thorax(1,hingeLineIx) thorax(1,size(thorax,2)-hingeLineIx+1);thorax(2,hingeLineIx) thorax(2,size(thorax,2)-hingeLineIx+1)];
hingeVector=diff(hingeLine')';
hinges=[hingeLine(:,1)+hingeVector*0.05 hingeLine(:,2)-hingeVector*0.05];
data.rotHinges=hinges;
if debug.plot>=0
%     plot(thorax(1,:),thorax(2,:),'g','linewidth',1);
    plot(thorax(1,1:size(thorax,2)/2),thorax(2,1:size(thorax,2)/2),'g','linewidth',1);
    plot(thorax(1,size(thorax,2)/2+1:end),thorax(2,size(thorax,2)/2+1:end),'g','linewidth',1);
    plot(hinges(1,:),hinges(2,:),'oy')
%     plot(hingeLine(1,:),hingeLine(2,:),'r','linewidth',1);
end

data.fit.thorax.fit=thorax;
data.fit.thoraxR=fitRes(1,2);
data.meas.body.thorax.S=S;
%thorax show plot
R=[cos(fitRes(1,2)) -sin(fitRes(1,2)); sin(fitRes(1,2)) cos(fitRes(1,2))];
T= fitRes(2:3,2)';
S=diag(fitRes(4:5,2));
transTemplate=R*(S*template.thorax.showModel);
transTemplate=[transTemplate(1,:)+T(1);transTemplate(2,:)+T(2)];
%now scale and translate to fit to onto the original image
R=[cos(data.rot) -sin(data.rot); sin(data.rot) cos(data.rot)];
thorax=(R*(transTemplate-repmat([size(data.WS,2)/2 size(data.WS,1)/2]',1,length(transTemplate)))+repmat([size(data.WS,2)/2 size(data.WS,1)/2]',1,length(transTemplate)))*data.scale+repmat([data.displacement(2);data.displacement(1)],1,length(transTemplate));
if debug.plot>=0
    plot(thorax(1,:),thorax(2,:),'g','linewidth',3);
end
data.fit.thorax.show=thorax;
data.fit.thoraxR=fitRes(1,2);
data.meas.body.thorax.S=S;

%head fit
R=[cos(fitRes(1,3)) -sin(fitRes(1,3)); sin(fitRes(1,3)) cos(fitRes(1,3))];
T= fitRes(2:3,3)';
S=diag(fitRes(4:5,3));
transTemplate=R*(S*template.head.showModel);
transTemplate=[transTemplate(1,:)+T(1);transTemplate(2,:)+T(2)];
%now scale and translate to fit to onto the original image
R=[cos(data.rot) -sin(data.rot); sin(data.rot) cos(data.rot)];
head=(R*(transTemplate-repmat([size(data.WS,2)/2 size(data.WS,1)/2]',1,length(transTemplate)))+repmat([size(data.WS,2)/2 size(data.WS,1)/2]',1,length(transTemplate)))*data.scale+repmat([data.displacement(2);data.displacement(1)],1,length(transTemplate));
if debug.plot>=0
    plot(head(1,:),head(2,:),'g','linewidth',3);
end
data.fit.head=head;
data.fit.headR=fitRes(1,3);
data.meas.body.head.S=S;