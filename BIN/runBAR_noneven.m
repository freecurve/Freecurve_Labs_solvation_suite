function [dFSum,ddFSum,dF,dS]=runBAR_noneven(kT,iStart,iEnd,barC,timeC)
% iState=1; 
sDisp='none';
% if nargout>0
%     sDisp='none';
% end
dF=[]; dS=[];
if nargin<4
    load('barC.mat');
end
if nargin<3
    iEnd=timeC{1,2}(end);
end
if nargin<2
    iStart=1;
end
if nargin<1
    %assume 
    kT=0.59219;
end

nLambdaPoints=size(barC,1);
dFEP=[];
for iState=1:(nLambdaPoints-1)
%     [dUij,dUji]=getEnergyDifferences(iState,barC,timeC,iStart,iEnd);
    bar1=barC{iState,2};
    bar2=barC{iState,3}; 
    time1=timeC{iState,2};
    time2=timeC{iState,3};
    [bar11,bar22,time11,time22]=alignBarAndTime(bar1,bar2,time1,time2,iStart,iEnd);    
    dUij=-bar11+bar22; 
    disp(sprintf('mutation %i -> %i overlap time points: %i',iState,iState+1,numel(time11)));
    
    bar1=barC{iState+1,1};
    bar2=barC{iState+1,2}; 
    time1=timeC{iState+1,1};
    time2=timeC{iState+1,2};
    [bar11,bar22,time11,time22]=alignBarAndTime(bar1,bar2,time1,time2,iStart,iEnd);        
    disp(sprintf('mutation %i -> %i overlap time points: %i',iState+1,iState,numel(time11)));
    dUji=-bar11+bar22;   
    
%     dUij=-barC{iState,2}+barC{iState,3}; 
%     dUji=-barC{iState+1,1}+barC{iState+1,2};       
%     dUij=dUij(iStart:iEnd);
%     dUji=dUji(iStart:iEnd);
    mean1=mean(exp(-dUij/kT));
    var1=std(exp(-dUij/kT)).^2;
    var1L=var1*(mean1.^(-2));
    dFEP(iState,1)=-kT*log(mean1);
    dFEP(iState,2)=kT*sqrt(var1L);
%     dFEP(iState,3)=-kT*log(mean2);
%     dFEP(iState,4)=kT*sqrt(var2L);
    
    dF(iState,1)=fzero(@fermiBAR,[-100 100],optimset('Display',sDisp),kT,dUij,dUji);
    dF(iState,2)=calcBARvariance(dUij,dUji,kT,dF(iState,1));
    dS(iState,:)=[mean(dUij) std(dUij)  mean(dUji) std(dUji)];
end
dFSum=sum(dF(:,1));
ddFSum=sqrt(sum(dF(:,2).^2));
% if nargout==0
%     disp([dS])
disp('dF_Detail:');
disp([dF])
disp('dF_Sum:');
disp([dFSum ddFSum])
%     disp('FEP:');
%     disp(dFEP);
%     disp('FEP_sum:');
%     disp(sum(dFEP(:,[1]),1));
%     disp('FEP_err:');
%     dFEPvar=sqrt(sum(dFEP(:,[2]).^2,1));
%     disp(dFEPvar);
% end
% keyboard;

function ddF=calcBARvariance(wF,wR,kT,dF)
% "rewroted from PYMBAR of bar.py function"
%rescale it to kT as in PYMBAR
wF=wF/kT;
wR=wR/kT;
dF=dF/kT;

% Compute asymptotic variance estimate using Eq. 10a of Bennett, 1976 (except with n_1<f>_1^2 in
% the second denominator, it is an error in the original

T_F=numel(wF);
T_R=numel(wR);
M=kT*log(T_F/T_R);
%         # Determine number of forward and reverse work values provided.
%         T_F = float(w_F.size)  # number of forward work values
%         T_R = float(w_R.size)  # number of reverse work values
%         # Compute log ratio of forward and reverse counts.
%         M = np.log(T_F / T_R)
CBAR=M-dF;
%         if iterated_solution:
%             C = M - DeltaF
%         else:
%             C = M - DeltaF_initial

%         #fF = 1 / (1 + np.exp(w_F + C)), but we need to handle overflows
exp_arg_F = (wF + CBAR);
%         # use boolean logic to zero out the ones that are less than 0, but not if greater than zero.
        %max_arg_F = np.choose(np.less(0.0, exp_arg_F), (0.0, exp_arg_F))
        max_arg_F = max_arg(exp_arg_F); %np.choose(np.less(0.0, exp_arg_F), (0.0, exp_arg_F))
log_fF = - max_arg_F - log(exp(-max_arg_F) + exp(exp_arg_F - max_arg_F));
sum_fF = exp(logsumexp(log_fF));

%         #fF = 1 / (1 + np.exp(w_F - C)), but we need to handle overflows
exp_arg_R = (wR - CBAR);
%         # use boolean logic to zero out the ones that are less than 0, but not if greater than zero.
        %max_arg_R = np.choose(np.less(0.0, exp_arg_R), (0.0, exp_arg_R))
        max_arg_R = max_arg(exp_arg_R);
log_fR = - max_arg_R - log(exp(-max_arg_R) + exp(exp_arg_R - max_arg_R));
sum_fR = exp(logsumexp(log_fR));

%         # compute averages of f_f
afF2 = (sum_fF/T_F).^2;
afR2 = (sum_fR/T_R).^2;
%         #var(x) = <x^2> - <x>^2
vfF = exp(logsumexp(2*log_fF))/T_F - afF2;
vfR = exp(logsumexp(2*log_fR))/T_R - afR2;
%         # an alternate formula for the variance that works for guesses
%         # for the free energy that don't satisfy the BAR equation.
variance1 = (vfF/T_F) / afF2 + (vfR/T_R) / afR2;

%rescale it back with kT
ddF = sqrt(variance1)*kT;

function  res=logsumexp(vec)
res=log(sum(exp(vec)));

function res=max_arg(vec)
res=vec;
res(res<0)=0;

function [bar11,bar22,time11,time22]=alignBarAndTime(bar1,bar2,time1,time2,iStart,iEnd)
bchk=(numel(bar1)==numel(time1))&&(numel(bar2)==numel(time2));
if ~bchk
    warning('something wrong in sizes of bar vs time');
end
idel1=find((time1<iStart)|(time1>iEnd));
idel2=find((time2<iStart)|(time2>iEnd));
time1(idel1)=[]; bar1(idel1)=[];
time2(idel2)=[]; bar2(idel2)=[];
[timeS,itime1,itime2] = intersect(time1,time2,'stable');
bar11=bar1(itime1);
bar22=bar2(itime2);
time11=time1(itime1);
time22=time2(itime2);
