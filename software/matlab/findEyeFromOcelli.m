function [headSectionLine,start,stop]=findEyeFromOcelli(IOD,debug)


headSectionEvalPoints=linspace(-IOD.headRPE.BoundingBox(4)/2.4,IOD.headRPE.BoundingBox(4)/2.4,1000);
headSectionLine=[IOD.OX-sin(IOD.headRot)*headSectionEvalPoints;IOD.OY+cos(IOD.headRot)*headSectionEvalPoints];
% headSectionLine=headSectionLine;%+repmat(IOD.headBB(1:2)',1,size(headSectionLine,2));
val=mirt2D_mexinterp(double(IOD.IRAdj),headSectionLine(1,:),headSectionLine(2,:));

[start,stop]=getEyeEdge(val,3,[0.0025 0.01],debug);
% [start,stop]=getEyeEdge(val,3,[0.0025 0.05],debug);
% [af,bf] = butter(5,0.2,'low');
% % % [af,bf] = butter(5,[0.001 0.05],'bandpass');
% % % valFilt = filtfilt(af,bf,val);
% % % growingFilt=diff(valFilt)>0;
% % % maxPeaks=[false diff(growingFilt)==-1 false];
% % % minPeaks=[false diff(growingFilt)==1 false];
% % % % thres=0.5*(quantile(val,0.1)+quantile(val,0.6));
% % % thres=0.5*(quantile(valFilt,0.1)+quantile(valFilt,0.6));
% % % maxPeaks=maxPeaks&valFilt>thres;
% % % minPeaks=minPeaks&valFilt<thres;
% % % 
% % % minPeaksIx=find(minPeaks);
% % % maxPeaksIx=find(maxPeaks);
% % % 
% % % while(maxPeaksIx(1)<minPeaksIx(1))
% % %     maxPeaksIx(1)=[];
% % % end
% % % 
% % % while(maxPeaksIx(end)>minPeaksIx(end))
% % %     maxPeaksIx(end)=[];
% % % end
% % % 
% % % start=round((maxPeaksIx(1)+minPeaksIx(1))/2);
% % % stop=round((minPeaksIx(end)+maxPeaksIx(end))/2);

% quantile(val,0.6)
% dval=diff(smooth(val,5)');
% valS=smooth(val,30);
% dValS=diff(valS);
% [~,startS]=max(dValS);
% [~, stopS]=min(dValS);
% growingFilt=diff(dval)>0;
% maxPeaks=[false diff(growingFilt)==-1 false];
% minPeaks=[false diff(growingFilt)==1 false];
% x=1:length(dval);
% startWindowFilter=x>startS-10 & x<startS+10;
% maxPeaksIx=find(maxPeaks&startWindowFilter);
% [~,ix]=max(dval(maxPeaksIx));
% start=maxPeaksIx(ix);
% 
% stopWindowFilter=x>stopS-10 & x<stopS+10;
% minPeaksIx=find(minPeaks&stopWindowFilter);
% [~,ix]=min(dval(minPeaksIx));
% stop=minPeaksIx(ix);

if debug.plot>0
    figure;
%     subplot(211)
    plot(val)
    hold on
%     plot(valFilt,'r')
%     plot(startS,valS(startS),'*k')
%     plot(stopS,valS(stopS),'*k')
    plot(start,val(start),'*g')
    plot(stop,val(stop),'*g')
%     subplot(212)
%     plot(x,dval)
%     hold on
%     plot(x,dValS)
end