%% config

sigma_D=12;
sigma_mean=40;28;
sigma_direction=60;
nSynapsesMax=100;
showrange=400;
calcRange=600;
trainingPath=which('natalia100.nml');
different= true;
klee=false;
if klee
    resultpath='results2.mat';
else
    resultpath='results.mat';
end
sigma_D=em.nm2voxel(sigma_D);
sigma_mean=em.nm2voxel(sigma_mean);
sigma_direction=em.nm2voxel(sigma_direction);


nD=3;aDims=(1:nD)';

%% KLEE
if klee
    load('synapseVolNatalia30.mat')
    
%     [~,bbox]=findBBoxKLEE(KLEE_savedTracing);
%     [a,~]=convertKleeTracingToLocalStack( KLEE_savedTracing ,autoKLEE_colormap,0);
    a=single(a);    
    a=a>0;
    a=bwlabeln(a);
    nD=ndims(a);
    sA=size(a);
    nSynapses=min(nSynapsesMax,max(a(:)));
    pos=cell(1,nSynapses);
    for i = 1:nSynapses
        newPos=cell(1,nD);
        [newPos{1:nD}]=ind2sub(sA,find(a==i));
        pos{i}=em.idx2nm(cellfun(@mean,newPos))+em.idx2nm(bbox(:,1).');
    end
else
    
    %% nml
    [~,cleft,~,~, bbox] = getSynapsesFromNml_preAllpost( trainingPath,true);
    
    nSynapses=min(nSynapsesMax,size(cleft,1));
    pos=cell(1,nSynapses);
    
    for i =1:nSynapses;
        pos{i}=em.idx2nm(cleft(i,:)+0.5);
    end
end
posM=cell2mat(pos.');
%% load raw

bbox=em.nm2idx([min(posM)-calcRange ;max(posM)+calcRange]).';
fprintf('Loading Cube ...',bbox);fprintf('%i',bbox);fprintf('...');
pos=cellfun(@(pos)(pos-em.idx2nm(bbox(:,1).')),pos,'UniformOutput',false);


b=single(em.readRoi(bbox));
if all(~b)
    warning('nothing red')
end

fprintf('finished. \n');

sA=size(b);
b=removeSaltAndPepper(b,3);

%% compute deratives


[smAStru, shift]=computeStructureTensor(b,sigma_D, sigma_mean);
if ~all(calcRange>=shift)
    warning('input cube to small. Synapse(s) out of range of Structure Tensor')
end
%[smAStru, shift]=computeHessian(b,sigma);
smAStru=permute(smAStru,[3:nD+2 1 2]);
ssmAStru=size(smAStru{1});
smAStru=cell2mat(smAStru);
smAStru=permute(smAStru,[nD+1 nD+2 aDims']);

[dA, shiftDA]=F_Grad.computeDerivation(b,sigma_direction);
if ~all(calcRange>=shiftDA)
    warning('input cube to small. Synapse(s) out of range of Derivation')
end
dA=permute(dA,[3:nD+2 2 1]);
sDA=size(dA{1});
dA=cell2mat(dA);
dA=permute(dA,[nD+1 aDims']);

%% compute eigenvalues

struEig=cell(1,nSynapses);
struEigV=cell(1,nSynapses);
R=cell(1,nSynapses);

for i = 1:nSynapses
    iPos=em.nm2idx(pos{i})-shift;
    iPosDA=em.nm2idx(pos{i})-shiftDA;
    iPos=num2cell(iPos);
    iPosDA=num2cell(iPosDA);
    [ struEigV{i}, struEig{i}]=eig(smAStru(:,:,iPos{:})) ;%
    %struEigV{i}=struEigV{i}(:,[1,2,3]);
    R{i}(:,1)=struEigV{i}(:,3)*sign(dA(:,iPosDA{:}).'*struEigV{i}(:,3));
    R{i}(:,2)=struEigV{i}(:,2)*sign(dA(:,iPosDA{:}).'*struEigV{i}(:,2));
    R{i}(:,3)= cross(R{i}(:,1),R{i}(:,2));
    
    dA(:,iPosDA{:})
    
    struEigV{i}
    R{i}
end

%%
coords=cell(1,nD);
helper=num2cell(zeros(1,nD-2));
rOut=round(max(em.nm2voxel(showrange)))*2;
[coords{:}]=meshgrid(-rOut:rOut,-rOut:rOut,helper{:});
coords=cellfun(@(x)x(:)*min(em.anisotropie)/2,coords,'UniformOutput',false);
coords=[coords{:}];

coords0=cell(1,nD);
helper=arrayfun(@(x,anisotropie)((1:x)-1)*anisotropie,sA,em.anisotropie,'UniformOutput',false);
[coords0{:}]=ndgrid(helper{:});

%coords0=cellfun(@(x)x(:),coords0,'UniformOutput',false);



rotCoordsxy=cellfun(@(R,pos)num2cell(bsxfun(@plus,R*coords.',pos.'),2),R,pos,'UniformOutput',false);
rotCoordsxz=cellfun(@(R,pos)num2cell(bsxfun(@plus,R*coords(:,[1 3 2]).',pos.'),2),R,pos,'UniformOutput',false);
rotCoordsyz=cellfun(@(R,pos)num2cell(bsxfun(@plus,R*coords(:,[3 1 2]).',pos.'),2),R,pos,'UniformOutput',false);
load(resultpath);wrong=[];wrongDirection=[];

for i = 1:nSynapses
    %%
    outxy=reshape(interpn(coords0{:},b,rotCoordsxy{i}{:}),repmat(rOut,[1 2])*2+1);
    outxz=reshape(interpn(coords0{:},b,rotCoordsxz{i}{:}),repmat(rOut,[1 2])*2+1);
    outyz=reshape(interpn(coords0{:},b,rotCoordsyz{i}{:}),repmat(rOut,[1 2])*2+1);
    
    %  if(~exist('result','var')||length(result)<i||isempty(result{i})||result{i}.'*R{i}(:,1)<cos(10*3.14/180))
    wrong=[wrong,i];
    figure('name',sprintf('Synapse: %i, Tree: %i,%d, ',i,struEig{i}([1,5,9])));
    
    subplot(3,3,1);
    imagesc(outxy(:,:,1));colormap gray;daspect([1 1 1]);
    subplot(3,3,2);
    imagesc(outxz(:,:,1));colormap gray;daspect([1 1 1]);
    subplot(3,3,3);
    imagesc(outyz(:,:,1));colormap gray;daspect([1 1 1]);
    
    subplot(3,3,4);
    from=max(em.nm2idx(pos{i}-showrange),1);
    to=min(em.nm2idx(pos{i}+showrange),sA);
    imagesc(b(from(1):to(1),from(2):to(2),i_(em.nm2idx(pos{i}),3)));colormap gray;daspect(em.anisotropie);
    subplot(3,3,5);
    from=max(em.nm2idx(pos{i}-showrange),1);
    to=min(em.nm2idx(pos{i}+showrange),sA);
    imagesc(squeeze(b(from(1):to(1),i_(em.nm2idx(pos{i}),2),from(3):to(3))));colormap gray;daspect(i_(em.anisotropie,[1,3,2]));
    subplot(3,3,6);
    from=max(em.nm2idx(pos{i}-showrange),1);
    to=min(em.nm2idx(pos{i}+showrange),sA);
    imagesc(squeeze(b(i_(em.nm2idx(pos{i}),1),from(2):to(2),from(3):to(3))));colormap gray;daspect(i_(em.anisotropie,[2,3,1]));
    
    subplot(3,3,7);
    from=max(em.nm2idx(pos{i}-showrange)-shiftDA,1);
    to=min(em.nm2idx(pos{i}+showrange)-shiftDA,sDA);
    dAdE=squeeze(sum(bsxfun(@times,dA,struEigV{i}(:,3)),1));
    imagesc(dAdE(from(1):to(1),from(2):to(2),i_(em.nm2idx(pos{i})-shiftDA,3)));colormap gray;daspect(em.anisotropie);
    drawnow;
    %end
end
if(false)
    %% save result
    wrong=[32,51,56,71];
    result=cell(1,nSynapses);
    
    for i=setdiff(1:nSynapses,wrong)
        if ismember(i,wrongDirection)
            result{i}=-R{i}(:,1);
        else
            result{i}=R{i}(:,1);
        end
    end
    save(resultpath,'result');
    
    
end

if(false)
    %% show all
    
    ratio=16/9;
    m=round(sqrt(nSynapses/ratio));
    n=ceil(nSynapses/m);
    
    allout=cellfun(@(rotCoordsxz)reshape(interpn(coords0{:},b,rotCoordsxz{:}),repmat(rOut,[1 2])*2+1),rotCoordsxz,'UniformOutput',false);
    %%
    figure('name',sprintf('Synapses'));
    for i = 1:nSynapses        
        subplot(m,n,i);
        imagesc(allout{i}(:,:,1));colormap gray;daspect([1 1 1]);
    end
    %%
    outwb=cell(nSynapses,1);
    ctrue=[1,1,1];
    cfalse=[1,0.1,0];
    border=5;
    correct=true(size(outwb));correct([38,71])=false;
    for i = 1:nSynapses
        outwb{i}=repmat(shiftdimsright(ite(correct(i),ctrue,cfalse)),[size(allout{i})+border*2 1]);
        outwb{i}(border+1:end-border,border+1:end-border,:)=repmat(allout{i},[1 1 3])/255;
    end
    outwb=reshape(outwb(1:99),[11 9])
    figure,imshow(cell2mat(outwb));
    imwrite(cell2mat(outwb),fullfile(ppath,'figures','100Synapses.png'))
    %%
    ppp(sum(cell2mat(shiftdimsright(allout,1)),3));
end

































