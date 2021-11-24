function [file,nn]=out2mat(fp,fn)
if nargin==0
    [fn,fp] = uigetfile;
end
fid = fopen([fp fn],'r');
if fid ==-1
    error(['I can not find file: ' fp fn]);
end
nn=0;
file =[];
NAD = 10000;
while 1
%     tline = fgetl(fid);
    [tline,lt] = fgets(fid);
    tline = tline(1:end-length(lt));
    if ~ischar(tline), break, end
    if round(nn/NAD) == (nn/NAD)
        file = [file; cell(NAD,1)];
    end
    nn=nn+1;    %number of strings in file
    file{nn,1} = tline;
end
fclose(fid);
file(nn+1:end)=[];
