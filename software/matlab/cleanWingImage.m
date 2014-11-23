function ID=cleanWingImage(fitRes,I,wings,hinge,debug)

R1=[cos(fitRes(end-1)) -sin(fitRes(end-1)); sin(fitRes(end-1)) cos(fitRes(end-1))];
R2=[cos(fitRes(end)) -sin(fitRes(end)); sin(fitRes(end)) cos(fitRes(end))];
TAll1= fitRes(end-5:end-4)';
TAll2= fitRes(end-3:end-2)';
S=diag(fitRes(end-7:end-6));
%rotate and translate wings
wings.left.all=R1*S*wings.single;
wings.left.all=[wings.left.all(1,:)+TAll1(1,:)+hinge(1,1);wings.left.all(2,:)+TAll1(2,:)+hinge(2,1)];
wings.right.all=R2*S*[wings.single(1,:);-wings.single(2,:)];
wings.right.all=[wings.right.all(1,:)+TAll2(1,:)+hinge(1,2);wings.right.all(2,:)+TAll2(2,:)+hinge(2,2)];

wings.all=[wings.left.all wings.right.all];

mask=false(size(I));
yc=round(wings.all(2,:));
xc=round(wings.all(1,:));

ind = sub2ind( size(mask), yc, xc );
mask(ind)=true;
maskDil=imdilate(mask,strel('disk',15));
I2=I;
I2(~maskDil)=false;
if debug.plot==2
    figure
    subplot(311)
    imshow(maskDil)
    subplot(312)
    imshow(I)
    subplot(313)
    imshow(I2)
end
ID=double(bwdist(I2));