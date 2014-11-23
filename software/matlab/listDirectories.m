function nameFolds=listDirectories(pathFolder)
d = dir(pathFolder);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
%You can then remove . and ..
nameFolds(ismember(nameFolds,{'.','..'})) = [];