function sex=detectSex(data,debug)
%method 1 abdomen color
abdomenSex=sexFromAbdomen(data,debug);
sexCombs=findSexCombs(data.dataDir,debug,data.sex.known);
sex.abdomen=abdomenSex;
sex.sexCombs=sexCombs;
%use combination of sexCombs and abdomen to determine sex
sex.sex=sex.sexCombs.sex;
if sex.sexCombs.sex==sex.abdomen.sex
    sex.sex=sex.sexCombs.sex;
elseif sex.sexCombs.sex=='F'
    if sex.sexCombs.weightedArea<20 && sex.abdomen.confidence<75
        sex.sex='F';
    elseif sex.sexCombs.weightedArea>40 && sex.abdomen.confidence>75
        sex.sex='M';
    else
        sex.sex='X';
    end
else
    if sex.sexCombs.weightedArea<100 && sex.abdomen.confidence>75
        sex.sex='F';
    elseif sex.sexCombs.weightedArea>150 && sex.abdomen.confidence<75
        sex.sex='M';
    else
        sex.sex='X';
    end
end
fprintf('Abdomen: sex %c (confidence %f)\n',sex.abdomen.sex,sex.abdomen.confidence);
fprintf('SexCombs: sex %c (sexCombs area %.0f)\n',sex.sexCombs.sex,sex.sexCombs.weightedArea);
fprintf('Decided sex: %c\n',sex.sex);