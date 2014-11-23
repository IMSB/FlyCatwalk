function plotWingManuallyCorrected(saveData)

% hold off
% imshow(saveData.bright)
% hold on
plot(saveData.wings.wingMeas.manualCorrection.left.outlinePoints(1,:),saveData.wings.wingMeas.manualCorrection.left.outlinePoints(2,:),'linewidth',4)
plot(saveData.wings.wingMeas.manualCorrection.left.lengthPoints(1,:),saveData.wings.wingMeas.manualCorrection.left.lengthPoints(2,:),'y')
plot(saveData.wings.wingMeas.manualCorrection.left.widthPoints(1,:),saveData.wings.wingMeas.manualCorrection.left.widthPoints(2,:),'y')
hold off