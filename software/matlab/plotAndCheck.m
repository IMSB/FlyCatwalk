function handles=plotAndCheck(handles)
[success,handles]=plotResults(handles);
if ~success
%     button = questdlg('The analysis failed or there is a discrepancy in the analysis version within the same experiment folder. It is strongly suggested to re-run the analysis. Do you want to run the analysis?','Version discrepancy','Yes','No','Yes');
%     if strcmp(button,'Yes')
% %         handles
%           runAnalysis(handles);
%         return;
%     else
        dataDir=fullfile(handles.preferences.expDataDir,handles.dataFolders(handles.currentIx).name);
        set(handles.messageText,'String',sprintf('%d/%d\n(%s)',handles.currentIx,handles.numData,dataDir));
        axes(handles.resultsTextAxes)
        set(handles.resultsTextAxes,'visible','off')
        resultsMessage={sprintf('Fly %d/%d',handles.currentIx,handles.numData),...
            'FAILED or NOT YET ANALYZED'};
        cla
        text(0, 0.5, resultsMessage,'interpreter', 'latex','vert','bottom');
        %         text(0,0.5,txt,'interpreter','latex',...
        %             'horiz','left','vert','middle')
        axes(handles.resultsFigure)
        [~,rotCrop]=readBrightestData(dataDir);
        brightestI=imread(fullfile(dataDir,sprintf('temp%05d.bmp',rotCrop(1))));
        imshow(brightestI);
%     end
end