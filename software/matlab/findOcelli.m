function [SCloseUp,cCloseUp,rCloseUp] = findOcelli(f,t,debug,figNumber)
%accelerated SSD using XCORR
% Initialization
t = double(t);
f = double(f);

% Complex template construction
tc = 2*t*1i-1;
fc = f.^2+f*1i;

% SSD using XCORR
tc = rot90(tc,2);
m = conv2(fc,conj(tc),'same');
S = real(m);

[v,ind] = max(S(:));
[c,r] = ind2sub([size(S,1),size(S,2)],ind);
[w,h] = size(t);

cropRect=[r-round(h/2), c-round(w/2), h, w];
% Result display
if debug.plot>0
    figure(figNumber+1000),imshow(uint8(f),[]),colormap(gray)
    hold on
    plot(r,c,'*r');
    rectangle('Position',cropRect,'EdgeColor','r','LineWidth',2);
end
cropRectT=[round(h/4), round(w/4), h/2, w/2];

% Initialization
tCloseUp = double(imcrop(t,cropRectT));
fCloseUp = double(imcrop(f,cropRect));

% Complex template construction
tcCloseUp = 2*tCloseUp*1i-1;
fcCloseUp = fCloseUp.^2+fCloseUp*1i;

% SSD using XCORR
tcCloseUp = rot90(tcCloseUp,2);
mCloseUp = conv2(fcCloseUp,conj(tcCloseUp),'same');
SCloseUp = real(mCloseUp);

[vCloseUp,indCloseUp] = max(SCloseUp(:));
[cCloseUp,rCloseUp] = ind2sub([size(SCloseUp,1),size(SCloseUp,2)],indCloseUp);
[wCloseUp,hCloseUp] = size(tCloseUp);

cCloseUp=cCloseUp+c-size(fCloseUp,1)/2;
rCloseUp=rCloseUp+r-size(fCloseUp,2)/2-6.5;

plotRectCloseUp=[rCloseUp-round(hCloseUp/2), cCloseUp-round(wCloseUp/2), hCloseUp, wCloseUp];

if debug.plot>0
plot(rCloseUp,cCloseUp,'*g');
rectangle('Position',plotRectCloseUp,'EdgeColor','g','LineWidth',2);
    figure(figNumber);
end