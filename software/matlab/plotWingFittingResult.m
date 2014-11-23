function plotWingFittingResult(data,figNumber)
if nargin==2
    figure(figNumber)
end
% if data.wings.wingMeas.fitType.light&&~data.wings.wingMeas.fitType.fineTuning.fineTune
% if isfield(data.wings.wingMeas,'light')
%     optimFitWingMirrorStructLight(data.wings.wingMeas.light.distWing,data.bright,double(data.wings.blueMask),data.wings.wingMeas.light.wingsPlot,data.rotHinges,2,data.veinNames,[1 0 0],data.wings.wingMeas.light.fittedP);
% end
% else
% if isfield(data.wings.wingMeas,'full')
%     optimFitWingMirrorStructCoeff(data.wings.wingMeas.full.distWing,data.bright,double(data.wings.blueMask),data.wings.wingMeas.templateData,data.rotHinges,2,data.wings.wingMeas.upScaleFactor,data.veinNames,[0 0 1],data.wings.wingMeas.full.fittedP);
% end
if isfield(data.wings.wingMeas,'fullO')
    optimFitWingMirrorStructCoeff(zeros(size(data.bright)),data.bright,double(data.wings.blueMask),data.wings.wingMeas.templateData,data.rotHinges,2,data.wings.wingMeas.upScaleFactor,data.veinNames,[0 1 0],data.wings.wingMeas.fullO.fittedP);
end
% end