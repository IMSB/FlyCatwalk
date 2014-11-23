function [success,handles]=plotResults(handles)
debugSkeleton=0;
dataDir=fullfile(handles.preferences.expDataDir,handles.dataFolders(handles.currentIx).name);
dataFile=fullfile(dataDir,'FitResults.mat');
if exist(dataFile,'file')
    try
        load(dataFile);
        %is this fly discarded?
        if ~saveData.checked;
            saveData.checked=true;
            if saveData.sex.sex=='M'
                if saveData.useFly
                    handles.stats.numMales=handles.stats.numMales+1;
                end
                handles.stats.numMalesUnchecked=handles.stats.numMalesUnchecked-1;
            elseif saveData.sex.sex=='F'
                if saveData.useFly
                    handles.stats.numFemales=handles.stats.numFemales+1;
                end
                handles.stats.numFemalesUnchecked=handles.stats.numFemalesUnchecked-1;
            end
            updateSex(handles);
            save(dataFile,'saveData');
        end
        set(handles.discardCB,'Value',~saveData.useFly);
        if debugSkeleton
            IPlot=saveData.bright;
            IPlotR=IPlot(:,:,1);
            IPlotG=IPlot(:,:,2);
            IPlotB=IPlot(:,:,3);
            IPlotR(saveData.wings.BWWing==1)=255;
            IPlotG(saveData.wings.BWWing==1)=255;
            IPlotB(saveData.wings.BWWing==1)=255;
            IPlot(:,:,1)=IPlotR;
            IPlot(:,:,2)=IPlotG;
            IPlot(:,:,3)=IPlotB;
            imshow(IPlot)
        else
            if handles.preferences.plot.IOD
                if isfield(saveData.IOD,'fixedFromSequence')
                    if saveData.IOD.fixedFromSequence
                        saveData.bright(end-size(saveData.IOD.ICrop,1)+1:end,end-size(saveData.IOD.ICrop,2)+1:end,:)=saveData.IOD.ICrop;
                    end
                end
            end
            imshow(saveData.bright)
        end
        hold on
        if handles.preferences.plot.body
            %here comes the body fit plot
            plot(saveData.fit.abdomen(1,:),saveData.fit.abdomen(2,:),'g','linewidth',3);
            plot(saveData.fit.thorax.fit(1,1:size(saveData.fit.thorax.fit,2)/2),saveData.fit.thorax.fit(2,1:size(saveData.fit.thorax.fit,2)/2),'g','linewidth',1);
            plot(saveData.fit.thorax.fit(1,size(saveData.fit.thorax.fit,2)/2+1:end),saveData.fit.thorax.fit(2,size(saveData.fit.thorax.fit,2)/2+1:end),'g','linewidth',1);
            plot(saveData.fit.thorax.show(1,:),saveData.fit.thorax.show(2,:),'g','linewidth',3);
            plot(saveData.fit.head(1,:),saveData.fit.head(2,:),'g','linewidth',3);
        end
        if handles.preferences.plot.IOD
            %here comes the head fit plot
            if isfield(saveData.IOD,'fixedFromSequence')
                if saveData.IOD.fixedFromSequence
                    offsetY=size(saveData.bright,1)-size(saveData.IOD.ICrop,1);
                    offsetX=size(saveData.bright,2)-size(saveData.IOD.ICrop,2);
                    plot(saveData.IOD.headSectionLine(1,:)+offsetX,saveData.IOD.headSectionLine(2,:)+offsetY,'g');
                    plot(saveData.IOD.headSectionLine(1,saveData.IOD.start)+offsetX,saveData.IOD.headSectionLine(2,saveData.IOD.start)+offsetY,'.y','markersize',15);
                    plot(saveData.IOD.headSectionLine(1,saveData.IOD.stop)+offsetX,saveData.IOD.headSectionLine(2,saveData.IOD.stop)+offsetY,'.y','markersize',15);
                else
                    plot(saveData.centroids.ocelli(1),saveData.centroids.ocelli(2),'*r');
                    plot(saveData.IOD.headSectionLine(1,:),saveData.IOD.headSectionLine(2,:),'g');
                    plot(saveData.IOD.headSectionLine(1,saveData.IOD.start),saveData.IOD.headSectionLine(2,saveData.IOD.start),'.y','markersize',15);
                    plot(saveData.IOD.headSectionLine(1,saveData.IOD.stop),saveData.IOD.headSectionLine(2,saveData.IOD.stop),'.y','markersize',15);
                end
            else
                plot(saveData.centroids.ocelli(1),saveData.centroids.ocelli(2),'*r');
                plot(saveData.IOD.headSectionLine(1,:),saveData.IOD.headSectionLine(2,:),'g');
                plot(saveData.IOD.headSectionLine(1,saveData.IOD.start),saveData.IOD.headSectionLine(2,saveData.IOD.start),'.y','markersize',15);
                plot(saveData.IOD.headSectionLine(1,saveData.IOD.stop),saveData.IOD.headSectionLine(2,saveData.IOD.stop),'.y','markersize',15);
            end
        end
        
        if handles.preferences.plot.wings
            %here come the wings
            if saveData.wings.wingMeas.manualCorrection.isCorrected==false
                plotWingFittingResult(saveData);
            else
                plotWingManuallyCorrected(saveData);
            end
            plotAreas=0;
            if plotAreas
                hold on
                fill(saveData.wings.wingMeas.fullO.wings.left.plot.area(1,:),saveData.wings.wingMeas.fullO.wings.left.plot.area(2,:),'w','facealpha',.2,'LineStyle','none')
                fill(saveData.wings.wingMeas.fullO.wings.right.plot.area(1,:),saveData.wings.wingMeas.fullO.wings.right.plot.area(2,:),'w','facealpha',.2,'LineStyle','none')
                hold off
            end
        end
        %update the GUI
        %         text(50,50,sprintf('Fly %d, sex %c, IOD=%.3fmm\n',q, dataAll(p).sex.sexCombs.sex, dataAll(p).meas.body.head.IOD*pixel2mm),'fontsize',20,'color',[1 1 1]);
        standardBGColor=get(handles.fitResultsPanel,'BackgroundColor');
        changeSexPanelBGColor(handles,standardBGColor)
        if saveData.sex.sex=='M'
            set(handles.sexMRadioButton,'Value',1);
        elseif saveData.sex.sex=='F'
            set(handles.sexFRadioButton,'Value',1);
        else
            set(handles.sexXRadioButton,'Value',1);
            changeSexPanelBGColor(handles,[1 0 0]);
        end
        set(handles.messageText,'String',sprintf('%d/%d\n(%s)',handles.currentIx,handles.numData,saveData.dataDir));
        
        %         resultsMessage=sprintf('Fly %d/%d\nIOD=%.0fum\nWL=%.0fum\nWA=%.0fum^2',handles.currentIx,...
        %         handles.numData,...
        %         saveData.meas.body.head.IOD*saveData.meas.pixel2mm*1000,...
        %         saveData.wings.wingMeas.fullO.wings.left.length.val*1000,...
        %         saveData.wings.wingMeas.fullO.wings.left.area.val*1e6);
        
        %         set(handles.resultsText,'String',resultsMessage);
        set(handles.messageText,'String',sprintf('%d/%d\n(%s)',handles.currentIx,handles.numData,saveData.dataDir));
        
        axes(handles.resultsTextAxes)
        set(handles.resultsTextAxes,'visible','off')
        resultsMessage={sprintf('Fly %d/%d',handles.currentIx,handles.numData),...
            sprintf('IOD=%.3f mm',saveData.meas.body.head.IOD.val),...
            sprintf('WL=%.3f mm',saveData.wings.wingMeas.fullO.wings.left.length.val),...
            sprintf('WW=%.3f mm',saveData.wings.wingMeas.fullO.wings.left.width.val),...
            sprintf('WA=%.3f mm$^2$',saveData.wings.wingMeas.fullO.wings.left.area.val)};
            %sprintf('WL=%.3f mm (%.3f)',saveData.wings.wingMeas.fullO.wings.left.length.val,saveData.wings.wingMeas.light.wings.left.length.val),...
            %sprintf('WW=%.3f mm (%.3f)',saveData.wings.wingMeas.fullO.wings.left.width.val,saveData.wings.wingMeas.light.wings.left.width.val),...
            %sprintf('WA=%.3f mm$^2$ (%.3f)',saveData.wings.wingMeas.fullO.wings.left.area.val,saveData.wings.wingMeas.light.wings.left.area.val)};
            %sprintf('WL=%.3f mm (%.3f %.3f)',saveData.wings.wingMeas.fullO.wings.left.length.val,saveData.wings.wingMeas.light.wings.left.length.val,saveData.wings.wingMeas.full.wings.left.length.val),...
            %sprintf('WW=%.3f mm (%.3f %.3f)',saveData.wings.wingMeas.fullO.wings.left.width.val,saveData.wings.wingMeas.light.wings.left.width.val,saveData.wings.wingMeas.full.wings.left.width.val),...
            %sprintf('WA=%.3f mm$^2$ (%.3f %.3f)',saveData.wings.wingMeas.fullO.wings.left.area.val,saveData.wings.wingMeas.light.wings.left.area.val,saveData.wings.wingMeas.full.wings.left.area.val)};
        cla
        text(0, 0.5, resultsMessage,'interpreter', 'latex','vert','bottom');
        %         text(0,0.5,txt,'interpreter','latex',...
        %             'horiz','left','vert','middle')
        axes(handles.resultsFigure)
        %
        success=true;
    catch
        success=false;
    end
else
    success=false;
end
hold off