function result=fermiBAR(dF,kT,dUij,dUji)
nF=numel(dUij);
nR=numel(dUji);
M=kT.*log(nF/nR);
beta=1/kT;
sumF=sum(1./(1+exp(beta.*(M+dUij-dF ))));
sumR=sum(1./(1+exp(-beta.*(M+dUji-dF))));
result=sumF-sumR;