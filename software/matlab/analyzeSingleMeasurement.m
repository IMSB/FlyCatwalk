function analyzeSingleMeasurement(obj,event,handles)
% folderContent=dir(handles.experimentDirRemote);
disp(datestr(now))
folderNames=[];
r=0;
for q=1:length(handles.experimentDirs)
    folderContent=dir(handles.experimentDirs{q});
    
    toKeep=false(1,length(folderContent));
    for p =1:length(folderContent)
        if folderContent(p).isdir && ~strcmpi(folderContent(p).name, '.') && ~strcmpi(folderContent(p).name, '..')
            toKeep(p)=true;
            r=r+1;
            folderNames{r}=fullfile(handles.experimentDirs{q},folderContent(p).name);
        end
    end
end
debug.plot=-1;
found=0;

for p=1:length(folderNames)
    dataDir=folderNames{p};
    if ~existVasco('Saving',dataDir) && ~existVasco('Analyzing',dataDir) && ~existVasco('FitResults.mat',dataDir)
%     if ~exist(fullfile(dataDir,'Saving'),'file') && ~exist(fullfile(dataDir,'Analyzing'),'file') && ~exist(fullfile(dataDir,'FitResults.mat'),'file')
        found=found+1;
        fid = fopen( fullfile(dataDir,'Analyzing'), 'wt' );
        fprintf(fid,'%s\n',datestr(now));
        fclose(fid);
%         CatWalkPostProcessingSingle(dataDir,debug);
        batch(handles.cluster,@CatWalkPostProcessingSingle,0,{dataDir,debug});
        set(handles.messageBoxExperiment,'String',sprintf('job %s added to queue',dataDir));
        drawnow;
        if found>=5
            break;
        end
    end
end

% [~,queued,running,~] = findJob(handles.cluster);
% numQueued=length(queued);
% numRunning=length(running);
% set(handles.messageBox,'String',sprintf('Running jobs %.0f, queued jobs %.0f\n',numRunning,numQueued));