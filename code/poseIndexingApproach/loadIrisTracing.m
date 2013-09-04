%%
nWorkers=0;
balance=3;
 res=em.nm2voxel(100); %nm
rexclude=350;rinclude=150;ninclude=5;rathernthanr=true; %nm
threeSigmaCueDist=500; %nm
sigma_D=em.nm2voxel(12);%nm
sigma_mean=em.nm2voxel(12);%nm
sigma_mean2=em.nm2voxel(20);%nm
sigma_direction=em.nm2voxel(60);%nm
ncues=1000;
nD=3;
f={...
    F_id(nD)
    F_Gaussian(sigma_mean)
    F_Gaussian(sigma_mean*2)
    F_Gaussian(sigma_mean*3)
    F_LoG(sigma_mean)
    F_LoG(sigma_mean*2)
    F_LoG(sigma_mean*3)
    F_LoG(sigma_mean*4)
    F_EigsOfStructureTensor(sigma_D,sigma_mean2)
    F_EigsOfStructureTensor(sigma_D*2,sigma_mean2)
    F_EigsOfStructureTensor(sigma_D,sigma_mean2*2)
    F_EigsOfStructureTensor(sigma_D*2,sigma_mean2*2)
    F_EigsOfStructureTensor(sigma_D*3,sigma_mean2*3)
    F_Grad(sigma_direction)
    F_Grad(sigma_direction/2)
    F_Grad(sigma_direction*2)
    F_Grad(sigma_direction*3)
};
fm=featureMap(f);
fm.setRotationFeature(F_R(sigma_D,sigma_mean,sigma_direction));

additionalborder=round(em.nm2voxel(threeSigmaCueDist));
threeSigmaCueDist=em.voxel2nm(additionalborder-1);
cues=randn(ceil(ncues/0.97.^3+10),3).*min(threeSigmaCueDist)/3;
cues=cues(sum(cues.^2,2)<min(threeSigmaCueDist).^2,:);
cues=cues(1:ncues,:);
cues=[zeros(fm.nf,3);cues];
cuesF=[(1:fm.nf).';randi(fm.nf,ncues,1)];
cuesF=shiftdimsright(cuesF,2);




trainingPath='2012-09-28_ex145_07x2__explorational__iyu__2ab83c (3).nml';


nmax=Inf;
minNodes=100;
validCubeBBox=[[7 5 1]+1;[66 43 25]-1];


if (matlabpool('size')~=nWorkers)
    if(matlabpool('size')>0 )
        matlabpool('close');
    end
    jm=findResource();
    if exist('jm.UserName','var')
        jm.UserName='jgleixne';
    end
    matlabpool(jm,'open',nWorkers);
end

emSeg=emData.readKNOSSOSconf(wallempath,'knossos.conf');
segPath=emSeg.dataPath;
segName=emSeg.fullName;
overlap=10;
outPath=fullfile(savePath,'iris');
if ~exist(outPath,'dir')
    mkdir(outPath);
end
%gallery(skelFile,minNodes,validCubeBBox,red,overlap,outPath,segPath,segName,nmax);

skelFile='skeleton';
skelFile=[skelFile '.mat'];
if ~exist(skelFile,'file')
    skeleton=parseNml(trainingPath);
    save(skelFile,'skeleton');
else
    load(skelFile);
end



nml=NML.fromParsedFile(skeleton);
nml.trees=nml.trees(cellfun(@(nodes)size(nodes,1)>100,{nml.trees.nodesNumDataAll}));
nml.trees=nml.trees(1:min(nmax,numel(nml.trees)));

nodes=cat(1,nml.trees.nodesNumDataAll);
nodes=nodes(:,3:nD+2);
cubeCoords = floor(( nodes - 1) / 128 );
[sorted,oidx]=sortrows(cubeCoords);
new=[true; any(diff(sorted),2)];
new=[find(new); numel(new)+1];

woila=arrayfun(@(i)nodes(oidx(new(i):new(i+1)-1),:),1:numel(new)-1,'UniformOutput',false);
woilaCubeCoords=cubeCoords(oidx(new(1:end-1)),:);

%find synapses
synapses=cell(1,numel(nml.trees));
for i=1:min(numel(nml.trees),nmax)
    tree=nml.trees(i);
    postSynapses=cellfun(@(key)strncmpi(tree.comments,{key},6),{'synexc','synEsc','syninh','synapse'},'UniformOutput',false);
    postSynapses=find(any(cat(1,postSynapses{:}),1));
    edges2=[tree.edges; tree.edges(:,[2,1])];
    synapses{i}=edges2(any(bsxfun(@eq,tree.edges(:),postSynapses),2),2);
    synapses{i}=tree.nodesNumDataAll(synapses{i},3:nD+2);
end
synapses=cat(1,synapses{:});
%find cubes of synapses
synapsesCubeCoords = floor(( synapses - 1) / 128 );

surfIdx=cell(1,numel(woila));
synIdx=cell(1,numel(woila));
xSyn=cell(1,numel(woila));
xNoSyn=cell(1,numel(woila));
for iCube=1:numel(woila)
	xSyn{iCube}=zeros(0,fm.nf);
	xNoSyn{iCube}=zeros(0,fm.nf);
	
	synIdx{iCube}=zeros(0,3);
	surfidx{iCube}=zeros(0,3);
    fprintf('processing Cube %i of %i\n',iCube,numel(woila));
    cubeCoords=woilaCubeCoords(iCube,:);
    synIdxl=all(bsxfun(@eq,synapsesCubeCoords,cubeCoords),2);
    synIdx{iCube}=synapses(synIdxl,:);% = bsxfun(@minus,synapses(synIdxl,:),zeroOfCube-1);
    if(~any(synIdxl))
        fprintf('No Synapses in cube: %u %u %u\n',cubeCoords);
        continue;
    end
    cube = readKnossosCube(segPath,segName,cubeCoords, 'uint16', 128+2*overlap);
    cube=cube(1+overlap:end-overlap,1+overlap:end-overlap,1+overlap:end-overlap);
    zeroOfCube = cubeCoords * 128 + 1;
    relNodIdx = bsxfun(@minus,woila{iCube},zeroOfCube-1);
    colors=cube(suba2ind(size(cube),relNodIdx));
    colors(colors == 0) = []; %color==0 <==> node is on wall
    colors=unique(colors);
    if(numel(colors)==0)
        colors=ones(0,1); %cause ml sucks
    end
    cube2=any(bsxfun(@eq,cube,permute(colors,[2:nD+1,1])),nD+1);
    cube=~cube;%walls
    cube2=imdilate(cube2,ones(repmat(3,1,nD)));
    cube2=cube2&cube; %walls next to segment with node
    
    
    [lsurfIdx, ~]= getWallSample( cube2,res,em.anisotropie );
    surfIdx{iCube}=bsxfun(@plus,lsurfIdx,zeroOfCube-1);  
    bbox=[zeroOfCube;zeroOfCube+127];    
    [xSyn{iCube}, xNoSyn{iCube}]=generateInput(fm,bbox,surfIdx{iCube},synIdx{iCube},em,additionalborder,cues,cuesF,rexclude,rinclude,ninclude,rathernthanr,balance);

end
surfIdx=cat(1,surfIdx{~cellfun(@isempty,surfIdx)});
synIdx=cat(1,synIdx{~cellfun(@isempty,synIdx)});
xSyn=cat(1,xSyn{~cellfun(@isempty,xSyn)});
xNoSyn=cat(1,xNoSyn{~cellfun(@isempty,xNoSyn)});
fR=fm.fR;
save(fullfile(outPath,'input3to1mal5'),'surfIdx','synIdx','xSyn','xNoSyn','f','fR','cues','cuesF','-v7.3');

if matlabpool('size')
    matlabpool close ;
end








