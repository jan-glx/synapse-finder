





threeSigmaCueDist=300; %nm
sigma_D=em.nm2voxel(12);%nm
sigma_mean=em.nm2voxel(12);%nm
sigma_mean2=em.nm2voxel(20);%nm
sigma_direction=em.nm2voxel(60);%nm
fm=featureMap({F_id(3)});
fm.setRotationFeature(F_R(sigma_D,sigma_mean,sigma_direction));


synapsefile='Synapses_training_for_jan_4f7724.nml';
%%
stime=tic;
fprintf('loading tracing...\n');tic;
[ bbox,~, synIdx] = getSynapsesFromNml( synapsefile );
toc,


cues=[0,0,0;400,0,0;0,200,0;0,0,200;0,141,141;0,70,171;0,171,71];
nCues=size(cues,1);

sy=diff(bbox)+1;


lsynpidx = bsxfun(@minus,synIdx,bbox(1,:)-1);
lsynpidxi = suba2ind (sy,lsynpidx);


fprintf('loading rawdata...\n');tic;
x=single(em.readRoi(bbox.'+[-fm.maxSiz;fm.maxSiz].'));
if all(~x)
    error('nothing red! ls %s: %s',em.dataPath,system(sprintf('ls %s',em.dataPath)));
end
toc
fprintf('remoove noise\n');tic;
x=removeSaltAndPepper(x,3);
toc;
%% compute R
fprintf('computing R...\n');tic
fm.computeR(x);
toc

%% compute poseIdx
fprintf('computing poseIdx...\n');tic

nsynLoc=numel(lsynpidxi);
synPoseIdx1 = poseIdx(fm,lsynpidxi,cues,em);
toc


fprintf('computing input array =feature values at training locations...\n');tic
synPoseIdx1=synPoseIdx1(~any(any(isnan(synPoseIdx1),3),2),:,:);
synPoseIdx1=bsxfun(@plus,synPoseIdx1,bbox(1,:)-1);

synPoseIdx1=num2cell(synPoseIdx1,[2,3]);
synPoseIdx1=cellfun(@(x)permute(x,[3,2,1]),synPoseIdx1,'UniformOutput',false);
edges=[ones(nCues-1,1),(2:nCues).'];

nml=parseNml(fullfile(synapsefile));
nml2=NML.fromParsedFile(nml);
nml2=nml2.copy();
nml2.deleteAllTrees();


trees=struct('nodes',synPoseIdx1,'edges',edges);

nml2.addTrees(trees);
nml2.write2File('poseTest.nml');






