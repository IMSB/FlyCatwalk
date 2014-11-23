function res=onBorders(I,BB,borderType)
if nargin<3
    borderType=[1 1 1 1];
end
res=0;
if borderType(1)
res=res|BB(1)<=1;
end
if borderType(2)
res=res|BB(1)+BB(3)>=size(I,2)-1;
end
if borderType(3)
res=res|BB(2)<=1;
end
if borderType(4)
res=res|BB(2)+BB(4)>=size(I,1)-1;
end