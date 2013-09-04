%%

trainingPath='2012-09-28_ex145_07x2__explorational__iyu__2ab83c (3).nml';
nmax=Inf;
minNodes=100;
validCubeBBox=[[7 5 1]+1;[66 43 25]-1];

cluster=true;
cubesPerTask=50;
res=5;% # quantiles 
rinclude=300;%nm
maxnCubes=3;
sigma_D=em.nm2voxel(12);%nm
sigma_mean=em.nm2voxel(12);%nm
sigma_mean2=em.nm2voxel(20);%nm
sigma_direction=em.nm2voxel(60);%nm
nD=numel(sigma_direction);
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
    F_H(sigma_mean)
    F_H(sigma_mean*2)
    F_H(sigma_mean*3)
    };
fm=featureMap(f);

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


%find synapses
synapses=cell(1,numel(nml.trees));
nodes=cell(1,numel(nml.trees));
for i=1:min(numel(nml.trees),nmax)
    tree=nml.trees(i);
    postSynapses=cellfun(@(key)strncmpi(tree.comments,{key},6),{'synexc','synEsc','syninh','synapse'},'UniformOutput',false);
    postSynapses=find(any(cat(1,postSynapses{:}),1));
    edges2=[tree.edges; tree.edges(:,[2,1])];
    synapses{i}=edges2(any(bsxfun(@eq,edges2(:,1),postSynapses),2),2);
    nodes{i}=tree.nodesNumDataAll(setdiff(1:size(tree.nodesNumDataAll,1),[synapses{i};postSynapses.']),3:nD+2); %only preasynaptic cell
    synapses{i}=tree.nodesNumDataAll(synapses{i},3:nD+2);    
end
synapses=cat(1,synapses{:});
synapses=synapses+1;%oxalis bug
nodes=cat(1,nodes{:});
nodes=nodes+1;%oxalis bug
%find cubes of synapses



fprintf('assinging nodes and synapses to cubes\n');tic;
[ nodeshere ] = nodes2nodesincube( nodes,em.boundary,overlap );
[ synapseshere ] = nodes2nodesincube( synapses,em.boundary,overlap );


notepmty=~cellfun(@isempty,nodeshere);
valid=false(size(nodeshere));
subc=bbox2subc(validCubeBBox);
valid(subc{:})=true;

nodesincube=nodeshere(valid&notepmty);
synapsesincube=synapseshere(valid&notepmty);
cubeCoords=subl2suba(valid&notepmty)-1;
clear nodeshere synapseshere;
nCubes=min(numel(nodesincube),maxnCubes);
toc

if cluster
    fprintf('preparing job\n');tic;
    jm=findResource();
    if exist('jm.UserName','var')
        jm.UserName='jgleixne';
    end
    job=jm.createJob();
    job.PathDependencies= regexp(genpath(ppath),':','split');
    toc
else
    xx=cell(nCubes,1);
    yy=cell(nCubes,1);
    meanL=cell(nCubes,1);
    meanR=cell(nCubes,1);
    meanC=cell(nCubes,1);
end

cubeCoordss=cell(1,min(cubesPerTask,nCubes));
synapsesincubes=cell(1,min(cubesPerTask,nCubes));
nodesincubes=cell(1,min(cubesPerTask,nCubes));
iTask=1;
for iCube=1:nCubes
    if cluster
        fprintf('adding Cube %i of %i to queque\n',iCube,nCubes);
        cubeCoordss{iTask}=cubeCoords(iCube,:);
        nodesincubes{iTask}=nodesincube{iCube};
        synapsesincubes{iTask}=synapsesincube{iCube};
        if(iTask==cubesPerTask||iCube==nCubes)
            job. createTask (@processCubes,5,{cubeCoordss,nodesincubes, synapsesincubes,segPath,segName,em,fm,res,rinclude});
            %processCubes(cubeCoordss,nodesincubes, synapsesincubes,segPath,segName,em,fm,res,rinclude);
            iTask=1;
            cubeCoordss=cell(1,min(cubesPerTask,nCubes-iCube));
            synapsesincubes=cell(1,min(cubesPerTask,nCubes-iCube));
            nodesincubes=cell(1,min(cubesPerTask,nCubes-iCube));
        else
            iTask=iTask+1;
        end
    else
        fprintf('processing Cube %i of %i\n',iCube,nCubes);
        [ xx{iCube},yy{iCube},meanL{iCube},meanR{iCube},meanC{iCube}] = processCube(cubeCoords(iCube,:),nodesincube{iCube}, synapsesincube{iCube},segPath,segName,em,fm,res,rinclude );
    end
end
if cluster
    job.submit();job.wait();
	
sendmail(myaddress, 'training data generation finished!', evalc('display(job)'));
    tasks=job.tasks;
    xx=cell(numel(tasks),1);
    yy=cell(numel(tasks),1);
    meanL=cell(numel(tasks),1);
    meanR=cell(numel(tasks),1);
    meanC=cell(numel(tasks),1);
    for i=1:numel(tasks)
        if(~isempty(tasks(i).Error))
            error(tasks(i).Error.getReport());
        end
        out = tasks(i).pGetOutputArguments();        
        [xx{i},yy{i},meanL{i},meanR{i},meanC{i}]=out{:};
    end
    xx=cat(1,xx{:});
    yy=cat(1,yy{:});
    meanL=cat(1,meanL{:});
    meanR=cat(1,meanR{:});
    meanC=cat(1,meanC{:});    
    job.destroy();
end

namesC=arrayfun(@(q)cellfun(@(name)sprintf('%s - %2.0f%% quantil',name,q*100),fm.getNames(),'UniformOutput',false),0:1/res:1,'UniformOutput',false);
namesC=cellocells2cell(namesC);
namesC=namesC(:);
namesC=[namesC;{'size'}];


namesL=cellfun(@(name)sprintf('left: %s ',name),namesC,'UniformOutput',false);
namesR=cellfun(@(name)sprintf('right: %s ',name),namesC,'UniformOutput',false);
namesC=cellfun(@(name)sprintf('contact: %s ',name),namesC,'UniformOutput',false);
names=[namesC; namesL; namesR];

good=cellfun(@(x)size(x,2)==651,xx);
xx=xx(good);
yy=yy(good);
synapsesincube=synapsesincube(good);
meanL=meanL(good);
meanR=meanR(good);
meanC=meanC(good);

xx=cell2mat(xx);
yy=cell2mat(yy);
synapsesincube=cell2mat(synapsesincube);
meanL=cell2mat(meanL);
meanR=cell2mat(meanR);
meanC=cell2mat(meanC);
outfilename=fullfile(outPath,'test');
save(outfilename,'xx','yy','synapsesincube','meanL','meanR','meanC','names','rinclude','f','res','-v7.3');
fprintf('sucessfully saved as %s\n',outfilename);
if matlabpool('size')
    matlabpool close ;
end








