function generateAnalysisOutputFile(selection,dataDirs,numData,segregate)
if nargin<3
    segregate=0;
end
for p=1:length(dataDirs)
fileID(p) = fopen(fullfile(dataDirs{p},'AnalysisOutput.txt'),'w');
fileIDLabels(p) = fopen(fullfile(dataDirs{p},'AnalysisOutputLabels.txt'),'w');
posOut(p).ix{100}=[];
discarded(p).ix=[];
end
sexNames = fieldnames(selection);
bottle=0;
highestBottleNum=0;
% discarded.ix=[];
% discarded.baseDir={};
numData=[0 numData];


for p=1:length(sexNames)
    categoryNames = fieldnames(selection.(sexNames{p}));
    if  ~segregate
        bottle=0;
    end
    for q=1:length(categoryNames)
        if ~strcmp(categoryNames{q},'notSelected')
        bottle=bottle+1;
        if(bottle>highestBottleNum)
            highestBottleNum=bottle;
        end
        for i=1:length(fileIDLabels)
            if segregate
                fprintf(fileIDLabels(i),'%d, %s %s\n',bottle-1,sexNames{p},categoryNames{q});
            elseif p==1
                fprintf(fileIDLabels(i),'%d, %s\n',bottle-1,categoryNames{q});
            end
            dataDirsToSelect=selection.(sexNames{p}).(categoryNames{q}).dataDir(strcmp(selection.(sexNames{p}).(categoryNames{q}).baseDir,dataDirs{i}));
            holeNumbers=[];
            for j=1:length(dataDirsToSelect)
                holeNumbers(j)=str2num(dataDirsToSelect{j}(find(dataDirsToSelect{j}=='_',1,'last')+1:end));
            end
            posOut(i).ix{bottle}=[posOut(i).ix{bottle} holeNumbers];
%             posOut(i).ix{bottle}=[posOut(i).ix{bottle} selection.(sexNames{p}).(categoryNames{q}).ix(strcmp(selection.(sexNames{p}).(categoryNames{q}).baseDir,dataDirs{i}))];
%             pos=sort(selection.(sexNames{p}).(categoryNames{q}).ix(strcmp(selection.(sexNames{p}).(categoryNames{q}).baseDir,dataDirs{i})));
%             for r=1:length(pos)
%                 fprintf(fileID(i),'%d,%d\n',bottle-1,pos(r)-1-numData(i));
%             end
        end
        else
            for i=1:length(fileIDLabels)
                dataDirsNotSelected=selection.(sexNames{p}).(categoryNames{q}).dataDir(strcmp(selection.(sexNames{p}).(categoryNames{q}).baseDir,dataDirs{i}));
                holeNumbers=[];
                for j=1:length(dataDirsNotSelected)
                    holeNumbers(j)=str2num(dataDirsNotSelected{j}(find(dataDirsNotSelected{j}=='_',1,'last')+1:end));
                end
                discarded(i).ix=[discarded(i).ix holeNumbers];
                %             discarded.ix=[discarded.ix selection.(sexNames{p}).(categoryNames{q}).ix];
%                 discarded.baseDir=[discarded.baseDir selection.(sexNames{p}).(categoryNames{q}).baseDir];
            end
        end
    end
end

for p=1:highestBottleNum 
    for i=1:length(fileIDLabels)
        pos=sort(posOut(i).ix{p});
        for r=1:length(pos)
            fprintf(fileID(i),'%d,%d\n',p-1,pos(r));
%             fprintf(fileID(i),'%d,%d\n',p-1,pos(r)-1-numData(i));
        end
    end
end

for i=1:length(fileIDLabels)
    fprintf(fileIDLabels(i),'%d, not selected\n',highestBottleNum);
    pos=sort(discarded(i).ix);
    for r=1:length(pos)
        fprintf(fileID(i),'%d,%d\n',highestBottleNum,pos(r));
%         fprintf(fileID(i),'%d,%d\n',highestBottleNum,pos(r)-1-numData(i));
    end
end      

for p=1:length(dataDirs)
    fclose(fileID(p));
    fclose(fileIDLabels(p));
end