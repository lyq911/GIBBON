function [P]=tesSmooth_LAP(TES,V,IND_V,cPar)

%% CONTROL PARAMETERS

if isfield(cPar,'LambdaSmooth')
    LambdaSmooth=cPar.LambdaSmooth;
else
    LambdaSmooth=0.5; %DEFAULT
end

if isfield(cPar,'n')
    nMax=cPar.n;
else
    nMax=1; %DEFAULT
end

if isfield(cPar,'RigidConstraints')
    indRigid=cPar.RigidConstraints;
else
    indRigid=[]; %DEFAULT
end

if isfield(cPar,'Tolerance')
    SSQD_Tol=cPar.Tolerance;
else
    SSQD_Tol=[]; %DEFAULT
end

%%

if ~isempty(SSQD_Tol)
    SSQD_old=[];
    SSQD_ratio=0;
end

if isempty(IND_V)
    [~,IND_V]=patchIND(TES,V,2);
end
logicValid=IND_V>0;

%%

nDims=size(V,2); %Number of dimensions

VP=NaN(size(IND_V,1),size(IND_V,2),nDims);
P=V;
PP=V; 
Q=V;
for qIter=1:nMax;   
        
    %% SIMPLE LAPLACIAN SMOOTHENING
    
    %Loop for all dimensions
    for qDim=1:1:nDims
        Xp=VP(:,:,qDim);
        Xp(logicValid)=P(IND_V(logicValid),qDim);
        Xp=nanmean(Xp,2);       
        PP(:,qDim)=Xp;
    end
    P=P+LambdaSmooth.*(PP-P);
    
    %%
        
    %Put back constrained points
    if ~isempty(indRigid)
       P(indRigid,:)=V(indRigid,:);
    end
    
    if ~isempty(SSQD_Tol)
        %Compute sum of squared differences with respect to previous iteration
        SSQD_new=nansum((P(:)-Q(:)).^2);
        if ~isempty(SSQD_old)
            SSQD_ratio=SSQD_new./SSQD_old;            
        end
        
        %Store current metrics
        Q=P;
        SSQD_old=SSQD_new;        
        if abs(1-SSQD_ratio)<=SSQD_Tol
           break %STOP SMOOTHING LOOP IF TOLERANCE IS REACHED 
        end
    end
    
end
