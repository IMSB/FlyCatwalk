function existing=existVasco(fileName,path)
existing=~isempty(dir(fullfile(path,fileName)));