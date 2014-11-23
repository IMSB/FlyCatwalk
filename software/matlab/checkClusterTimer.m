function checkClusterTimer(obj,event,handles)

% [~,queued,running,~] = findJob(handles.cluster);
% numQueued=length(queued);
% numRunning=length(running);
states={handles.cluster.Jobs.State};
numRunning=sum(strcmp(states,'running'));
numQueued=sum(strcmp(states,'queued'));
set(handles.messageBox,'String',sprintf('Running jobs %.0f, queued jobs %.0f\n',numRunning,numQueued));
drawnow;