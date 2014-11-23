function [IRD,IRDDebug]=angleDependentBWDist(I,debug)%,numOrientations)

% IRD=zeros(size(I,1),size(I,2),18);
averagingSpan=12;%12 %6 %make sure it's even
angles=-90-averagingSpan/2:90+averagingSpan/2;
subSampling=1;
% IRDArray=false(size(I,1),size(I,2),length(angles));
IRDAll=single(zeros(size(I,1),size(I,2),length(angles)));
IRD=single(zeros(size(I,1),size(I,2),181));
IRDDebug=false(size(I,1),size(I,2),180/subSampling+1);

%make image square for safe rotation
IBig=zeros(max(size(I)));
IBig((size(IBig,1)-size(I,1))/2+1:end-(size(IBig,1)-size(I,1))/2,(size(IBig,2)-size(I,2))/2+1:end-(size(IBig,2)-size(I,2))/2)=I;

if debug.plot>1
    figure
    IColor=uint8(zeros(size(IBig,1),size(IBig,2),3));
end

for p=1:length(angles)
    IR=imrotate(IBig,angles(p),'crop');
%     IRO=imopen(IR,[0 0 0; 1 1 1; 0 0 0]);
%     IRO=imopen(imdilate(I,strel('disk',3)),strel('line',10,angles(p)));
%     IRO=bwmorph(imopen(imdilate(IR,strel('disk',1)),strel('line',7,0)),'skel',Inf);
    IRO=imopen(IR,strel('line',3,0));
    IRO=imdilate(IRO,strel('disk',5));
    IRO=imerode(IRO,strel('disk',3));
    IRBack=imrotate(IRO,-angles(p),'crop');
    IRBack=IRBack&IBig;
    if debug.plot>1
        IColor(:,:,1)=255*IBig;
        IColor(:,:,2)=255*(IBig-IRBack);
        IColor(:,:,3)=255*(IBig-IRBack);
        imshow(IColor((size(IBig,1)-size(I,1))/2+1:end-(size(IBig,1)-size(I,1))/2,(size(IBig,2)-size(I,2))/2+1:end-(size(IBig,2)-size(I,2))/2,:))
        drawnow;
    end
%     IRDArray(:,:,p)=logical(IRBack((size(IBig,1)-size(I,1))/2+1:end-(size(IBig,1)-size(I,1))/2,(size(IBig,2)-size(I,2))/2+1:end-(size(IBig,2)-size(I,2))/2));
    IRDAll(:,:,p)=bwdist(logical(IRBack((size(IBig,1)-size(I,1))/2+1:end-(size(IBig,1)-size(I,1))/2,(size(IBig,2)-size(I,2))/2+1:end-(size(IBig,2)-size(I,2))/2)));
end

if debug.plot>1
    figure
end
% for p=1:180/subSampling+1
%     IRDDebug(:,:,p)=sum(IRDArray(:,:,(p-1)*subSampling+1:(p-1)*subSampling+averagingSpan),3)>0;
%     IRD(:,:,p)=bwdist(IRDDebug(:,:,p));
%     if debug.plot>1
%         subplot(211)
%         imshow(IRDDebug(:,:,p),[]);
%         subplot(212)
%         imshow(IRD(:,:,p),[]);
%         drawnow;
%     end
% end
% for p=1:180/subSampling+averagingSpan+1
%     IRDAll(:,:,p)=bwdist(IRDArray(:,:,p));
% end
% for p=1:180/subSampling+averagingSpan+1
%     IRDDebug(:,:,p)=sum(IRDArray(:,:,(p-1)*subSampling+1:(p-1)*subSampling+averagingSpan),3)>0;
%     IRD(:,:,p)=bwdist(IRDDebug(:,:,p));
%     if debug.plot>1
%         subplot(211)
%         imshow(IRDDebug(:,:,p),[]);
%         subplot(212)
%         imshow(IRD(:,:,p),[]);
%         drawnow;
%     end
% end

normalPDF=normpdf(-averagingSpan/2:averagingSpan/2,0,averagingSpan/5);
for p=1:180/subSampling+1
    temp=0;
%     temp2=0;
    for q=1:length(normalPDF)
        temp=temp+IRDAll(:,:,p+q-1)*normalPDF(q);
%         temp2=temp2+IRDArray(:,:,p+q-1)*normalPDF(q);
    end
IRD(:,:,p)=temp;
end

IRD=double(IRD);

% IRD=smooth(IRD,10,'rlowess');
% for p=1:18
%     IRDDebug(:,:,p)=sum(IRDArray(:,:,(p-1)*10+1:(p-1)*10+20),3)>0;
%     IRD(:,:,p)=bwdist(IRDDebug(:,:,p));
% %     imshow(IRD(:,:,p),[]);
% %     drawnow;
% end
% 
% [x,y,z]=meshgrid(1:size(IRDMeans,1),1:size(IRDMeans,2),1:size(IRDMeans,3));
% tic
% interp3(IRD,[100 100],[100 100],[9 10],'cubic')
% toc
% [x,y,z]=meshgrid(IRDMeans);
% fit(