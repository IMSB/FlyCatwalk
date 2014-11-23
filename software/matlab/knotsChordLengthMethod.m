function knots=knotsChordLengthMethod(points)

allNorms=0;
for p=2:length(points)
allNorms=allNorms+norm(points(p,:)-points(p-1,:));
end
knots=zeros(1,length(points));
for p=2:length(points)
knots(p)=knots(p-1)+norm(points(p,:)-points(p-1,:))/allNorms;
end