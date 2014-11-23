function runSelection(handles)
debug.plot=1;
robustFit=1;
% rng(1);

testDirs=uigetdirn(handles.preferences.mainDataDir,'Select the test director(y/ies)');
%new code

for q=1:length(testDirs)
    expDirContent=listDirectories(testDirs{q});
    %this will only be used for the preliminary data, the rest of the data will
    %be in alphabetical order anyway
    testedIndividuals=1:length(expDirContent);
    numData(q)=length(testedIndividuals);
    
    [~,alphabeticallySorted]=sort(expDirContent);
    for p=1:numData(q)
        try
            toSort(p)=str2num(expDirContent{p}(find(expDirContent{p}=='_',1,'last')+1:end));
        catch
            toSort(p)=alphabeticallySorted(p);
        end
    end
    [~,ix]=sort(toSort);
    for p=1:numData(q)
        if q>1
            dataFolders(p+numData(q-1)).name=expDirContent{ix(p)};
            dataFolders(p+numData(q-1)).baseDir=testDirs{q};
            dataFolders(p+numData(q-1)).holeNumber=toSort(ix(p));
        else
            dataFolders(p).name=expDirContent{ix(p)};
            dataFolders(p).baseDir=testDirs{q};
            dataFolders(p).holeNumber=toSort(ix(p));
        end
    end
    clear toSort;
end
%end of new code

numTotalAnalyzed=handles.preferences.sorting.numTotalAnalyzed;
numSelected=handles.preferences.sorting.numSelected;
r=0;

%try
%    matlabpool open
%end

ppm = ParforProgressStarter2('Loading data...', length(dataFolders), 0.1);
% expDataDir=handles.preferences.expDataDir;
% dataFolders=handles.dataFolders;
% parfor p=1:length(handles.dataFolders)
% parfor p=1:length(dataFolders)
parfor p=1:length(dataFolders)
    dataDir{p}=fullfile(dataFolders(p).baseDir,dataFolders(p).name);
    baseDir{p}=dataFolders(p).baseDir;
    IOD(p)=nan;
    IOD2(p)=nan;
    WL(p)=nan;
    WW(p)=nan;
    WA(p)=nan;
    sex(p)=nan;
    validData(p)=false;
    try
        dataFile=fullfile(dataDir{p},'FitResults.mat');
        saveData=load(dataFile);
        IOD(p)=saveData.saveData.meas.body.head.IOD.val;
        IOD2(p)=IOD(p).^2;
        WL(p)=saveData.saveData.wings.wingMeas.fullO.wings.left.length.val;
        WW(p)=saveData.saveData.wings.wingMeas.fullO.wings.left.width.val;
        WA(p)=saveData.saveData.wings.wingMeas.fullO.wings.left.area.val;
        if saveData.saveData.sex.sex=='M'
            sex(p)=0;
        elseif saveData.saveData.sex.sex=='F'
            sex(p)=1;
        else
            sex(p)=2;
        end
        validData(p)=saveData.saveData.useFly&sex(p)~=2;
    end
    ppm.increment();
end

delete(ppm);
% try
%     matlabpool close
% end

% if debug.plot
%     indexVector=1:length(validData);
%     figure(2)
%     plot(indexVector(validData),0,'b.')
%     hold on
% end
%pick control
% IOD=IOD(validData);
% WL=WL(validData);
% WW=WW(validData);
% WA=WA(validData);
% sex=sex(validData);
validDataIx=find(validData);
selectedSex=[0,1];
selectedColor={'b','r'};
selectedSymbol={'o','x'};
pickedSymbol={'s','d','+'};
sexLabels={'males','females'};

expName=testDirs{1}(find(testDirs{1}=='\',1,'last')+1:end);
if ~isempty(find(expName(1)=='H', 1))
    toSelect=1;
elseif ~isempty(find(expName(1)=='L', 1))
    toSelect=2;
elseif ~isempty(find(expName(1)=='C', 1))
    toSelect=3;
else
    toSelect=menu('Selection type:','High','Low','Control','Both (High and Low)');
end

debugFigure=figure;
plotFigure=figure;

hold off
lengendIx=0;
for p=1:2
    sameSex=sex==selectedSex(p)&validData;
    sameSexIx=find(sameSex);
    
    % if debug.plot
    %     figure(2)
    %     plot(indexVector(sameSex),1,'g.')
    % end
    
    if length(sameSexIx)<numTotalAnalyzed
%         close(plotFigure)
%         if(debug.plot)
%             close(debugFigure)
%         end
        errorMessage=sprintf('Not enough %s flies, Total number of flies available %d total needed %d',sexLabels{p},length(sameSexIx),numTotalAnalyzed);
        waitfor(msgbox(errorMessage,'Not enough flies for selection!','error'))
        continue;
    end
    
    if numSelected>numTotalAnalyzed
        close(plotFigure)
        if(debug.plot)
            close(debugFigure)
        end
        errorMessage=sprintf('Number of selected flies cannot be higher than the number of flies from which you pick!');
        waitfor(msgbox(errorMessage,'Error in selection numbers','error'))
        return;
    end
    
    if toSelect==4 && numSelected>numTotalAnalyzed/2
        close(plotFigure)
        if(debug.plot)
            close(debugFigure)
        end
        errorMessage=sprintf('If you select both high and low the number of selected flies must be <= totalFlies/2!');
        waitfor(msgbox(errorMessage,'Error in selection numbers','error'))
        return;
    end
    lengendIx=lengendIx+1;
    randomIx = randperm(length(sameSexIx));
    % control(p,selectedIx(randomIx(1:numControl)))=true;
    remainingIx=find(sameSex);
    pickIx=randperm(length(remainingIx));
    pickedIx=sort(remainingIx(pickIx(1:numTotalAnalyzed)));
    
    
    pool.(sexLabels{p}).ix=pickedIx;
    pool.(sexLabels{p}).IOD=IOD(pickedIx);
    pool.(sexLabels{p}).IOD2=IOD2(pickedIx);
    pool.(sexLabels{p}).WA=WA(pickedIx);
    pool.(sexLabels{p}).WL=WL(pickedIx);
    pool.(sexLabels{p}).WW=WW(pickedIx);
    pool.(sexLabels{p}).dataDir=dataDir(pickedIx);
    pool.(sexLabels{p}).baseDir=baseDir(pickedIx);
    
    % if debug.plot
    %     figure(2)
    %     plot(indexVector(pickedIx),1,'rs')
    % end
    
    % Fit: with robust regression
    [xData, yData] = prepareCurveData(IOD2(pickedIx),WA(pickedIx));
    
    
    % Set up fittype and options.
    ft = fittype( 'poly1' );
    opts = fitoptions( ft );
    opts.Lower = [-Inf -Inf];
    if robustFit
        opts.Robust = 'bisquare';
    else
        opts.Robust='off';
    end
    opts.Upper = [Inf Inf];
    
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    regrResult=fitresult(IOD2(pickedIx))';
    regrResultAll=fitresult(IOD2)';
    
    fitResults.(sexLabels{p}).fitresult=fitresult;
    fitResults.(sexLabels{p}).gof=gof;
    fitResults.(sexLabels{p}).regrResult=regrResult;
    
    if debug.plot
        figure(debugFigure);
        plot(IOD2(sameSex),WA(sameSex),'.','color',selectedColor{p});
        hold on
        plot(xData,yData,'o','color',selectedColor{p});
        plot(sort(xData),fitresult(sort(xData)),'-','color',selectedColor{p});
        xlabel('IOD^2 (mm^2)')
        ylabel('Wing area (mm^2)')
    end
    
    residuals=WA(pickedIx)-regrResult;
    residualsAll=WA-regrResultAll;
    % regr=polyfit(IOD(pickedIx),WA(pickedIx),1);
    % residuals=WA(pickedIx)-polyval(regr,IOD(pickedIx));
    [sortedResiduals,sortedIx]=sort(residuals);
    sortedIOD2=IOD2(pickedIx);
    sortedIOD2=sortedIOD2(sortedIx);
    sortedWA=WA(pickedIx);
    sortedWA=sortedWA(sortedIx);
    
    if toSelect==0 %High
        return;
    elseif toSelect==1 %High
        selectedIx(1).ix=pickedIx(sortedIx(end-numSelected+1:end));
        selectedIx(1).type='high';
        if debug.plot
            figure(debugFigure);
            plot(xData(sortedIx(end-numSelected+1:end)),yData(sortedIx(end-numSelected+1:end)),pickedSymbol{1},'color',selectedColor{p},'Markersize',15);
        end
    elseif toSelect==2 %Low
        selectedIx(1).ix=pickedIx(sortedIx(1:numSelected));
        selectedIx(1).type='low';
        if debug.plot
            figure(debugFigure);
            plot(xData(sortedIx(1:numSelected)),yData(sortedIx(1:numSelected)),pickedSymbol{2},'color',selectedColor{p},'Markersize',15);
        end
    elseif toSelect==3 %Control
        pickIx=randperm(length(sortedIx));
        selectedIx(1).ix=pickedIx(sortedIx(pickIx(1:numSelected)));
        selectedIx(1).type='control';
        if debug.plot
            figure(debugFigure);
            plot(xData(sortedIx(pickIx(1:numSelected))),yData(sortedIx(pickIx(1:numSelected))),pickedSymbol{3},'color',selectedColor{p},'Markersize',15);
        end
    elseif toSelect==4 %both
        selectedIx(1).ix=pickedIx(sortedIx(end-numSelected+1:end));
        selectedIx(1).type='high';
        selectedIx(2).ix=pickedIx(sortedIx(1:numSelected));
        selectedIx(2).type='low';
        if debug.plot
            figure(debugFigure);
            plot(xData(sortedIx(end-numSelected+1:end)),yData(sortedIx(end-numSelected+1:end)),pickedSymbol{1},'color',selectedColor{p},'Markersize',15);
            plot(xData(sortedIx(1:numSelected)),yData(sortedIx(1:numSelected)),pickedSymbol{2},'color',selectedColor{p},'Markersize',15);
        end
    end
    
    sameSexUnselected=sameSex;
    for q=1:length(selectedIx)
        sameSexUnselected(selectedIx(q).ix)=false;
    end
    unselectedIx=find(sameSexUnselected);
    
    
    figure(plotFigure);
    plot(ones(length(sortedResiduals),1)*p-1,sortedResiduals,'.','color',selectedColor{p})
    legendText{(lengendIx-1)*(length(selectedIx)+1)+1}=sexLabels{p};
    hold on
    for q=1:length(selectedIx)
        plot(ones(length(residualsAll(selectedIx(q).ix)),1)*p-1,residualsAll(selectedIx(q).ix),selectedSymbol{q},'color',selectedColor{p})
        legendText{(lengendIx-1)*(length(selectedIx)+1)+1+q}=[selectedIx(q).type,' ',sexLabels{p}];
    end
    % plot(plotXVector(1:numSelected),sortedResiduals(1:numSelected),'d','color',selectedColor{p})
    % plot(plotXVector(end-numSelected+1:end),sortedResiduals(end-numSelected+1:end),'s','color',selectedColor{p})
    
    for q=1:length(selectedIx)
        selectedIx(q).ix=sort(selectedIx(q).ix);
        selection.(sexLabels{p}).(genvarname(selectedIx(q).type)).ix=selectedIx(q).ix;
        selection.(sexLabels{p}).(genvarname(selectedIx(q).type)).IOD=IOD(selectedIx(q).ix);
        selection.(sexLabels{p}).(genvarname(selectedIx(q).type)).IOD2=IOD2(selectedIx(q).ix);
        selection.(sexLabels{p}).(genvarname(selectedIx(q).type)).WA=WA(selectedIx(q).ix);
        selection.(sexLabels{p}).(genvarname(selectedIx(q).type)).WL=WL(selectedIx(q).ix);
        selection.(sexLabels{p}).(genvarname(selectedIx(q).type)).WW=WW(selectedIx(q).ix);
        selection.(sexLabels{p}).(genvarname(selectedIx(q).type)).dataDir=dataDir(selectedIx(q).ix);
        selection.(sexLabels{p}).(genvarname(selectedIx(q).type)).baseDir=baseDir(selectedIx(q).ix);
    end
    unselectedIx=sort(unselectedIx);
    selection.(sexLabels{p}).notSelected.ix=unselectedIx;
    selection.(sexLabels{p}).notSelected.IOD=IOD(unselectedIx);
    selection.(sexLabels{p}).notSelected.IOD2=IOD2(unselectedIx);
    selection.(sexLabels{p}).notSelected.WA=WA(unselectedIx);
    selection.(sexLabels{p}).notSelected.WL=WL(unselectedIx);
    selection.(sexLabels{p}).notSelected.WW=WW(unselectedIx);
    selection.(sexLabels{p}).notSelected.dataDir=dataDir(unselectedIx);
    selection.(sexLabels{p}).notSelected.baseDir=baseDir(unselectedIx);
end

invalidDataIx=find(~validData);
selection.unknown.notSelected.ix=invalidDataIx;
selection.unknown.notSelected.baseDir=baseDir(invalidDataIx);
selection.unknown.notSelected.dataDir=dataDir(invalidDataIx);


legend(legendText);
ylabel('Residuals of the WA(IOD^2) linear regression');
xlim([-0.5;1.5])

generateAnalysisOutputFile(selection,testDirs,numData,handles.preferences.sorting.sortSeparately);
for p=1:length(testDirs)
    save(fullfile(testDirs{p},'selectionResult'),'selection','pool','fitResults');
    saveas(debugFigure,fullfile(testDirs{p},'fitResults.fig'));
end
hold off