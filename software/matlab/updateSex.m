function updateSex(handles)
set(handles.numberOfMalesMB,'String',sprintf('Checked males %.0f (total %.0f)',handles.stats.numMales,handles.stats.numMales+handles.stats.numMalesUnchecked));
set(handles.numberOfFemalesMB,'String',sprintf('Checked females %.0f (total %.0f)',handles.stats.numFemales,handles.stats.numFemales+handles.stats.numFemalesUnchecked));


% if handles.preferences.sorting.numTotalAnalyzed>min(handles.stats.numMales,handles.stats.numFemales)
%     set(handles.numTotalAnalyzedET,'BackgroundColor',[1 0 0]);
% else
%     set(handles.numTotalAnalyzedET,'BackgroundColor',[1 1 1]);
% end