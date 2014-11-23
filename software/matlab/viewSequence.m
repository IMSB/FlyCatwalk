function viewSequence(handles)
dataDir=fullfile(handles.preferences.expDataDir,handles.dataFolders(handles.currentIx).name);
fileNames=dir(fullfile(dataDir,'temp*.bmp'));
system(sprintf('%%SystemRoot%%\\System32\\rundll32.exe "%%ProgramFiles%%\\Windows Photo Viewer\\PhotoViewer.dll", ImageView_Fullscreen %s',fullfile(dataDir,fileNames(1).name)))