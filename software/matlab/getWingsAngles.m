function wings=getWingsAngles(wings,ixUp,veinNames)

wingDiffs=(wings.all(:,3:end)-wings.all(:,1:end-2))';
% wings.angles=(atan(wingDiffs(:,2)./wingDiffs(:,1))+pi/2)/pi*17+1;
wings.angles=(atan(wingDiffs(:,2)./wingDiffs(:,1))+pi/2)*180/pi+1;
wings.angles=[wings.angles(1);wings.angles;wings.angles(end)];
ixWings=[0 ixUp];
for q=1:2
    for p=1:length(veinNames)
        wings.angles(ixWings(q)+wings.(veinNames{p}).up.startIx)=wings.angles(ixWings(q)+wings.(veinNames{p}).up.startIx+1);
        wings.angles(ixWings(q)+wings.(veinNames{p}).up.endIx)=wings.angles(ixWings(q)+wings.(veinNames{p}).up.endIx-1);
    end
end