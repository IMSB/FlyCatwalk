function [ixStart,ixStop]=getEyeEdge(val,order,cutOff,debug)

% [af,bf] = butter(5,0.2,'low');
[af,bf] = butter(order,cutOff,'bandpass');
valFilt = filtfilt(af,bf,val);

growingFilt=diff(valFilt)>0;
maxPeaks=[false diff(growingFilt)==-1 false];
minPeaks=[false diff(growingFilt)==1 false];

x=1:length(val);

if debug.plot>1
    figure
    plot(x,val)
    hold on
    plot(x,valFilt,'r')
    plot(x(maxPeaks),valFilt(maxPeaks),'*k')
    plot(x(minPeaks),valFilt(minPeaks),'*y')
end
% thres=0.5*(quantile(valFilt,0.1)+quantile(valFilt,0.6));
% maxPeaks=maxPeaks&valFilt>thres;
% minPeaks=minPeaks&valFilt<thres;

minPeaksIx=find(minPeaks);
maxPeaksIx=find(maxPeaks);

while(maxPeaksIx(1)<minPeaksIx(1))
    maxPeaksIx(1)=[];
end

while(maxPeaksIx(end)>minPeaksIx(end))
    maxPeaksIx(end)=[];
end

if debug.plot>1
    plot(x(maxPeaks),valFilt(maxPeaks),'ok')
    plot(x(minPeaks),valFilt(minPeaks),'oy')
end
dValFilt=diff(valFilt);
dValFilt(end+1)=dValFilt(end);

[~, ixStart]=max(dValFilt(minPeaksIx(1):maxPeaksIx(1)));
[~, ixStop]=min(dValFilt(maxPeaksIx(end):minPeaksIx(end)));

ixStart=ixStart+minPeaksIx(1);
ixStop=ixStop+maxPeaksIx(end);
if debug.plot>1
    plot(x(ixStart),valFilt(ixStart),'dc')
    plot(x(ixStop),valFilt(ixStop),'dc')
    plot(dValFilt,'r')
end

%fine tuning
if cutOff(2)*5<1
    [af2,bf2] = butter(order,[cutOff(1) cutOff(2)*5],'bandpass');
    valFilt2 = filtfilt(af2,bf2,val);
    
    dValFilt2 = b_spline_smooth([1:1000]',valFilt2',[1:1000]', ones(size(valFilt2')), 2, 1,10);
    
    dValFilt2Cmp=diff(valFilt2);
    dValFilt2Cmp(end+1)=dValFilt2(end);
    
    [~, ixStart2]=max(dValFilt2(minPeaksIx(1):minPeaksIx(1)+100));
    [~, ixStop2]=min(dValFilt2(minPeaksIx(end)-100:minPeaksIx(end)));
    ixStart=minPeaksIx(1)+ixStart2;
    ixStop=minPeaksIx(end)-100+ixStop2;
    
%     [~, ixStart2]=max(dValFilt2(ixStart-50:ixStart+50));
%     [~, ixStop2]=min(dValFilt2(ixStop-50:ixStop+50));
    
%     ixStart=ixStart2+ixStart-50;
%     ixStop=ixStop2+ixStop-50;
    
    if debug.plot>1
        plot(x,valFilt2,'k')
        plot(x(ixStart),valFilt2(ixStart),'xr')
        plot(x(ixStop),valFilt2(ixStop),'xr')
        plot(dValFilt2,'k')
    end
    
    if debug.plot>1
        figure
        plot(dValFilt2)
        hold on
        plot(dValFilt2Cmp,'r')
    end
end