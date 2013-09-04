
function [xx, yy,meanC]=generateInput(fm,bbox,surfIdx,synIdx,em,additionalborder,cues,cuesF,rexclude,rinclude,ninclude,rathernthanr,balance)

nD=size(bbox,2);
cubesize=diff(bbox)+1;
fprintf('loading rawdata...\n');tic;
x=single(em.readRoi(bbox.'+[-fm.maxSiz-additionalborder;fm.maxSiz+additionalborder].'));
if all(~x)
    error('nothing red! ls %s: %s',em.dataPath,system(sprintf('ls %s',em.dataPath)));
end
toc
fprintf('remoove noise\n');tic;
x=removeSaltAndPepper(x,3);
toc;


%%
surfIdx=unique(surfIdx,'rows');
synIdx=unique(synIdx,'rows');
fprintf('assinging syns to walls...\n');a=tic;
exclude = rangesearch(em.voxel2nm(surfIdx),em.voxel2nm(synIdx),rexclude);
if rathernthanr
    include = knnsearch(em.voxel2nm(surfIdx),em.voxel2nm(synIdx),'K',ninclude);
else
    include = rangesearch(em.voxel2nm(surfIdx),em.voxel2nm(synIdx),rinclude);
    include = [include{:}];
end
exclude = [exclude{:}];
notexclude= setdiff(1:size(surfIdx,1),unique(exclude));
include = unique(include);

synpidx = surfIdx(include,:);
nosynpidx = surfIdx(notexclude,:);
if (isempty(nosynpidx)||isempty(synpidx))
	xx=zeros(0,fm.nf+numel(cuesF));
	meanC=zeros(0,3);
    yy=false(0,1);
	return;
end

if balance
    fprintf('balancing...\n');tic    
    nosynpidx=nosynpidx(1+round((0:floor((size(synpidx,1)-1)*balance))*(size(nosynpidx,1)-1)/((size(synpidx,1)-1)*balance)),:);
    toc
end

lsynpidx = bsxfun(@minus,synpidx,bbox(1,:)-additionalborder-1);
lnosynpidx = bsxfun(@minus,nosynpidx,bbox(1,:)-additionalborder-1);
lsynpidxi = suba2ind (cubesize+2*additionalborder,lsynpidx);
lnosynpidxi = suba2ind(cubesize+2*additionalborder,lnosynpidx);
debug=true;
if debug
    wallem=emData.readKNOSSOSconf('F:\datasets\walls\',[],'uint16');
    wallem.overlap=10;
    fprintf('loading walls...\n');tic;
    walls=~wallem.readRoi(bbox.');
    toc
    raw=removeSaltAndPepper(single(em.readRoi(bbox.')))/255;
    llsynpidx = bsxfun(@minus,lsynpidx,additionalborder);
    llnosynpidx = bsxfun(@minus,lnosynpidx,additionalborder);
    %%
    l=92;
    
    markerInserter = vision.MarkerInserter('Shape','X-mark','BorderColor','Custom','CustomBorderColor',[0 1 0]);
    J = step(markerInserter, repmat(raw(:,:,l),[1 1 3]), llnosynpidx(llnosynpidx(:,3)==l,[2 1]));
    markerInserter = vision.MarkerInserter('Shape','X-mark','BorderColor','Custom','CustomBorderColor',[0 0 1]);
    J = step(markerInserter,J,  llsynpidx(llsynpidx(:,3)==l,[2 1]));
    figure,imshow(J)
    %%
    l1=400;
    l2=1;
    figure,imshow(raw(l1:l1+199,l2:l2+199,l));
    figure,imshow(J(l1:l1+199,l2:l2+199,:)); %fullfile(ppath,'figures','wallsampledtraining')
    figure,imshow(walls(l1:l1+199,l2:l2+199,l));
    %%
    ppath='P:\2013\';
    imwrite(raw(l1:l1+199,l2:l2+199,l),[fullfile(ppath,'figures','wallsampledtraining') '_raw.png']);
    imwrite(J(l1:l1+199,l2:l2+199,:),[fullfile(ppath,'figures','wallsampledtraining') '_lab.png']); %fullfile(ppath,'figures','wallsampledtraining')
    imwrite(walls(l1:l1+199,l2:l2+199,l),[fullfile(ppath,'figures','wallsampledtraining') '_wall.png']);
end
toc(a)
%% compute feature map
fprintf('computing fm...\n');tic
fm.compute(x);
toc
%% compute R
fprintf('computing R...\n');tic
fm.computeR(x);
toc

%% compute poseIdx
fprintf('computing poseIdx...\n');tic

nsynLoc=numel(lsynpidxi);
synPoseIdx2 = poseIdx(fm,lsynpidxi,cues,em);
nNosynLoc=numel(lnosynpidxi);
nosynPoseIdx2 = poseIdx(fm,lnosynpidxi,cues,em);


synPoseIdx2=[synPoseIdx2,repmat(cuesF,[nsynLoc,1,1])];
nosynPoseIdx2=[nosynPoseIdx2,repmat(cuesF,[nNosynLoc,1,1])];
synPoseIdxi2=suba2ind ([fm.sy fm.nf],synPoseIdx2);
nosynPoseIdxi2=suba2ind ([fm.sy fm.nf],nosynPoseIdx2);
toc

%%

fprintf('computing input array =feature values at training locations...\n');tic
synPoseIdxi2=synPoseIdxi2(~any(isnan(synPoseIdxi2),2),:);
nosynPoseIdxi2=nosynPoseIdxi2(~any(isnan(nosynPoseIdxi2),2),:);
xSyn=fm.X(synPoseIdxi2);
xNoSyn=fm.X(nosynPoseIdxi2);
xx=cat(1,xSyn,xNoSyn);
yy=[true(size(xSyn,1),1);false(size(xNoSyn,1),1)];
meanC=[synpidx;nosynpidx];
toc














