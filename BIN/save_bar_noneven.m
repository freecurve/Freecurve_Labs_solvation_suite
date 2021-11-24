%pth - folder with .bar files
%reduceZ - obsolete option for bar calculation every n point (n probably
%not more than 2)
%pointsToRemove - variable that containts points that must be removed
%it is assumed that jumps between their appropriate neighbours must be
%present
function [errMsg,barC,timeC,stpoint]=save_bar_noneven(pth,reduceZ,pointsToRemove)
dbstop if error
if nargin<=2
    pointsToRemove=[];
%     pointsToRemove=[0.0500 0.7500 0.8500 0.9500];
end
if nargin<=1
    %parameter for 
    reduceZ=1;
end
if nargin==0
    pth='.\ene-temp-2\';
end
% pth - path to dir with *.ene files; the path must have right trailing "\"
% AddZeroCol - boolian flag for adding a column of zeroes for the last Lambda (needed in Annihilation TI)
% AddLR - boolian flag for adding LR correction column 'dHdL_LRCor' to 'dHdL' (needed for Arbalest ver before r.959)
errMsg='';
% AddZeroCol = ~isempty(strmatch('AddZeroCol', varargin, 'exact'));
% AddLRCol   = ~isempty(strmatch('AddLRCol',   varargin, 'exact'));
cFileListInFolder = findAllBarFilesInDir(pth);
if isempty(cFileListInFolder)
    return
end

%find common begin string (after that assume that nPoints coming)
cFileNamesDecomposedByUnderscore = getDecomposedNamesByUnderscore(cFileListInFolder);
stpoint=getPointProperties(cFileNamesDecomposedByUnderscore,reduceZ);

%collecting bar EnergyPotential with central one and writing it in the cell (X*3)
deltaChk=1e-5;
sEnergyProperty=[{'Time'};{'EnrgPot'}];
%columns for previous, current and next point
[LamVecExtended,stpoint] = getMatrixOfJumps(stpoint,pointsToRemove,deltaChk);
% allPointsVec=stpoint.allPointsVec(:);
% LamVecExtended=[];
% LamVecExtended(:,1)=[0.0-stpoint.lambdaStep; allPointsVec(1:end-1);];
% LamVecExtended(:,2)=[allPointsVec(1:end);];
% LamVecExtended(:,3)=[allPointsVec(2:end); 1.0+stpoint.lambdaStep];
barC=cell(stpoint.nPointsZ,3);
timeC=cell(stpoint.nPointsZ,3);

for iiPoint=1:size(LamVecExtended,1)
%    iPoint=stpoint.allPointsVec(iiPoint);
    iPoint=LamVecExtended(iiPoint,2);
    for iShift=1:3
        %iNeighbor=(iShift-2)*lambdaStep+iPoint;
        iNeighbor=LamVecExtended(iiPoint,iShift);
        bNeighborChk=abs(stpoint.lambdaPointNeighbor-iNeighbor)<deltaChk;
        bPointChk=abs(stpoint.lambdaPointActual-iPoint)<deltaChk;
        iiFile=find((bNeighborChk)&(bPointChk));
        if (iNeighbor<0)|(iNeighbor>1)
            continue;
        end
        if numel(iiFile)==1
            disp(sprintf('found lambda: %4f with neighbor: %4f file: %s\n',iPoint,iNeighbor,cFileListInFolder{iiFile}));
            result=readEnergyColFromEneFile(pth,cFileListInFolder{iiFile},sEnergyProperty);
            barC{iiPoint,iShift}=result{2};
            timeC{iiPoint,iShift}=result{1};
        elseif numel(iiFile)>1
            disp('!!!found several files with the same lambda and the same lambda neighbor');     
            for iiiFile=1:numel(iiFile)
                disp(sprintf('found lambda: %4f with neighbor: %4f file: %s\n',iPoint,iNeighbor,cFileListInFolder{iiFile(iiiFile)}));            
            end
            resultC=cell(0,0);
            nBig=[0 0];
            for iiiFile=1:numel(iiFile)            
                [resultC{iiiFile,1},errMsg]=readEnergyColFromEneFile(pth,cFileListInFolder{iiFile(iiiFile)},sEnergyProperty);
                if (~isempty(errMsg)) 
                  return;
                end
                nBar=numel(resultC{iiiFile,1}{1});
                if nBig(2)<nBar
                    nBig=[iiiFile nBar];
                end
                disp(['file: ' cFileListInFolder{iiFile(iiiFile)} ' contains nStrings: ' num2str(nBar)]);
            end            
            iChosen=nBig(1);
            [iCh,jCh]=sortrows(cFileNamesDecomposedByUnderscore(iiFile,:));
            iChosen=jCh(end);
            disp('!!!taking the latest available file:' );
            disp([' ' cFileListInFolder{iiFile(iChosen)}] );
            barC{iiPoint,iShift}=resultC{iChosen}{2};    
            timeC{iiPoint,iShift}=resultC{iChosen}{1};    
        else
            errMsg=sprintf('not able to find calculation with lambda: %4f and lambda neighbor: %4f',iPoint,iNeighbor);
            disp(errMsg);
            bPointChk
            lambdaPointNeighbor
            lambdaPointActual
            %for j=1:numel(allPointsVec)
            %  disp(sprintf('iiFile=%2i, bNeighborChk=%1i, bPointChk=%1i, lambdaPointNeighbor=%8f\n',iiFile,bNeighborChk,bPointChk(j),lambdaPointNeighbor(j)));
            %end
            keyboard;
            return;
        end
    end
end
%save('barC.mat','barC','timeC','nPoints','-mat');
nPoints = stpoint.nPoints;
save(fullfile(pth,'barC.mat'),'barC','timeC','nPoints','stpoint','-mat');

function [resultC,errMsg]=readEnergyColFromEneFile(path,filename,datastring)
    resultC=cell(0,0);
    errMsg='';
    nm=filename;
    filename=fullfile(path,filename);
    if ~iscell(datastring)
        datastring={datastring};
    end
    %disp(filename)
	%TABLE = readtable(filename,'FileType','text','Delimiter','\t'); % 'readtable' available in R2013b and later
    bSuccess=1;
    try
        TABLE = readTextFile(filename,'Delimiter','\t'); % 'readtable' available in R2013b and later
        for iC=1:numel(datastring)
           if (isfield(TABLE, datastring{iC}))
              eval(['resultC{' num2str(iC) ',1}=TABLE.' datastring{iC} ';']);
              if iscell(resultC{iC,1})
                  warning(['file:' filename 'is bad!' ]);
                  bSuccess=0;
              end
              errMsg='';
           else
              resultC='';
              errMsg=sprintf('Field %s is not found in input files',datastring{iC});
           end
        end
    catch errM
%         rethrow(errM);
%        disp(['!!!Issues with file: ' filename,errM.message '\nDo classical reading']);
        WarnMsg=sprintf('!!!Issues with file \"%s\"\nWARRNING: %s\nDo classical reading\n',nm,errM.message);
        disp(WarnMsg);
        bSuccess=0;
    end
    
if ~bSuccess
    resultC=cell(0,0);
    iCountC=0;
    [resNamesC,tableC]=readTableFileM(filename);
    for iC=1:numel(datastring)
        iZ=find(strcmp(datastring{iC},resNamesC));
        if ~isempty(iZ)
            iCountC=iCountC+1;    
            %for bad endings
            dChk=str2double(tableC(:,iZ));
            dChkNan=isnan(dChk);
            if any(dChkNan)
                idEnd=find(dChkNan,1);
                dChk=dChk(1:(idEnd-1));
            end
            resultC{iCountC,1}=dChk;
%             resultC{iCountC,1}=vertcat(tableC{:,iZ});
        end
    end
%     keyboard;
end

function [resNamesC,tableC]=readTableFileM(filename)
    tableC=cell(0,0);
    [fileZ]=out2mat(filename,'');
    resNamesC=textscan(fileZ{1},'%s');
    resNamesC=resNamesC{1}';
    nCols=numel(resNamesC);
    iCounter=0;
    for iString=2:numel(fileZ)
        resC=textscan(fileZ{iString},'%s');
        resC=resC{1}';
        if numel(resC)==nCols
            iCounter=iCounter+1;
            tableC(iCounter,:)=resC;
        end
    end
    
function cFileListInFolder = findAllBarFilesInDir(pth,mask)
if nargin==1
    mask='*_SYSTEM_L_*.bar';
end
list=dir([pth mask]);
nFilesTotal=numel(list);
if (nFilesTotal == 0)
   errMsg=sprintf('No %s files in dir %s',mask,pth);
   disp(errMsg);
   cFileListInFolder=cell(0,0);
   return;
end
filenameC=struct2cell(list)';
cFileListInFolder=filenameC(:,1);

function cFileNamesDecomposedByUnderscore = getDecomposedNamesByUnderscore(cFileListInFolder)
cFileNamesDecomposedByUnderscore=cell(0,0);
for iFile=numel(cFileListInFolder):-1:1
    ts=textscan(cFileListInFolder{iFile},'%s','Delimiter','_'); 
    cFileNamesDecomposedByUnderscore(iFile,:)=ts{1}';
end    


function st=getPointProperties(cFileNamesDecomposedByUnderscore,reduceZ)
st=struct([]);
cTestFirst = repmat(cFileNamesDecomposedByUnderscore(1,:),size(cFileNamesDecomposedByUnderscore,1),1);
iColsThatAreDifferentInFiles=find(all(strcmp(cFileNamesDecomposedByUnderscore,cTestFirst),1)==0);
%first different must be lambda point
st(1).iColLambda=iColsThatAreDifferentInFiles(1);
st(1).iColLambdaCalc=iColsThatAreDifferentInFiles(end);
st(1).lambdaPoint=str2num(strvcat(cFileNamesDecomposedByUnderscore{:,st(1).iColLambda}));

st(1).allPoints=unique(st(1).lambdaPoint);
st(1).nPoints=numel(st(1).allPoints);
if (st(1).nPoints < 2)
    errMsg=sprintf('too few (%1i) lambda files recognized, lambda assumed to be first variable token in filename',st(1).nPoints);
    return;
end
if ~all(st(1).allPoints==(0:(st(1).nPoints-1))')
    errMsg=sprintf('not all consequtive lambda points are on the place');
    return;
end

%disp(sprintf('Total number of TI points are: %03d\n We assume equidistance calculation:',nPoints));
st(1).nPointsZ=(st(1).nPoints-1)/reduceZ+1;
%allPointsVec=linspace(0,1,nPointsZ)';
%the last + ".bar" must be 
st(1).lambdaPointNeighbor=str2num(strvcat(strrep(cFileNamesDecomposedByUnderscore(:,st(1).iColLambdaCalc),'.bar','')));
%allPointsVec=unique(str2num(strvcat(regexprep(regexprep(cFileListInFolder,'.*_SYSTEM_L_',''),'\.bar','')))); % extract LamValuse from FileNames
st(1).allPointsVec=unique(st(1).lambdaPointNeighbor);
disp('Lambda points extracted as bar neighbors from filenames:');
disp(st(1).allPointsVec);
if (st(1).nPoints ~= numel(st(1).allPointsVec))
    errMsg=sprintf('Number of lambdas extracted as bar neighbors from filenames (%i2) differs from nPoints=%i2',numel(st(1).allPointsVec),st(1).nPoints);
    return;
end
%lambdaPointActual=lambdaPoint/(nPoints-1)
for iiFile=1:numel(st(1).lambdaPoint)
  st(1).lambdaPointActual(iiFile,1)=st(1).allPointsVec(st(1).lambdaPoint(iiFile)+1);
end
%lambdaPointActual
st(1).lambdaStep=reduceZ/(st(1).nPoints-1);

function [LamVecExtended,stpoint]= getMatrixOfJumps(stpoint,pointsToRemove,deltaChk)
if nargin<=2
    deltaChk=1e-5;
end
allPointsVec=stpoint.allPointsVec(:);
LamVecExtended=[];
LamVecExtended(:,1)=[0.0-stpoint.lambdaStep; allPointsVec(1:end-1);];
LamVecExtended(:,2)=[allPointsVec(1:end);];
LamVecExtended(:,3)=[allPointsVec(2:end); 1.0+stpoint.lambdaStep];

%assuming before removal everything was fine
for iiPoint=1:numel(pointsToRemove)
    onePointToRemove=pointsToRemove(iiPoint);
    iLine=find(abs(LamVecExtended(:,2)-onePointToRemove)<deltaChk);
    if isempty(iLine)
        disp(['there is no point to remove: ' num2str(onePointToRemove)]);
    end
    if numel(iLine)>1
        disp(['found in Matrix of Jumps more than 1 point to remove: ' num2str(onePointToRemove)]);
        disp(['IGNORING!!!']);
        continue;
    end
    if ((iLine==1) || (iLine==size(LamVecExtended,1)))
        disp(['removed point must be inside, not on the edge: ' num2str(onePointToRemove)]);
        disp(['IGNORING!!!']);
        continue;
    end        
    vLine=LamVecExtended(iLine,:);
    %FIXME check on previous conditions
    LamVecExtended(iLine-1,3)=vLine(:,3);
    LamVecExtended(iLine+1,1)=vLine(:,1);
    LamVecExtended(iLine,:)=[];    
    allPointsVec(allPointsVec==onePointToRemove)=[];
%    0.7500    0.8000    0.8500
%    0.8000    0.8500    0.9000
%    0.8500    0.9000    0.9500    
end
disp('Final Matrix of Jumps:');
disp(LamVecExtended);
stpoint.nPoints=size(LamVecExtended,1);
stpoint.nPointsZ=size(LamVecExtended,1);
stpoint.allPointsVec = allPointsVec;