function XRot=rotateAroundImageCenter(I,X,rotAngle)
R=[cos(rotAngle) -sin(rotAngle); sin(rotAngle) cos(rotAngle)];
T=repmat(flipud((size(I)/2)'),1,size(X,2));
XRot=R*(X-T)+T;