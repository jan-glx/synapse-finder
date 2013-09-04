%load('F:\JanResults\Trainingsets\sampled walls context cues\sampled.mat')
if exist('ens','var')
    warning('variable ens already exists, skipping loading...\n');
    ensfile=fullfile(savepath,'ens.mat');
else
    ensfile='F:\JanResults\2013-08-20-07-45-48-455305\ens.mat';%'F:\JanResults\Trainingsets\sampled walls no cues\2013-08-16-16-48-06-803883\ens.mat';
    load(fullfile(ensfile));
end
ens=ens.Trainable{1};

fm=featureMap(f);
fm.setRotationFeature(fR);

wallem=emData.readKNOSSOSconf('F:\datasets\walls',[],'uint16');
wallem.overlap=10;

overlap=0;
bbox=[390, 966, 1352];
bbox=[bbox-overlap;bbox+[200,200,1]-1+overlap];

fprintf('loading walls...\n');tic;
x=wallem.readRoi(bbox.');
toc
%%
fprintf('sample walls...\n');tic;
[lsurfIdx, lsurfIdxi]= getWallSample( ~x,res,wallem.anisotropie );
gsurfIdx=bsxfun(@plus,lsurfIdx,bbox(1,:)-1);
toc

fprintf('loading rawdata...\n');tic;
x=single(em.readRoi(bbox.'+[-fm.maxSiz-additionalborder;fm.maxSiz+additionalborder].'));
if all(~x)
    error('nothing red! ls %s: %s',em.dataPath,system(sprintf('ls %s',em.dataPath)));
end
toc

fprintf('remoove noise\n');tic;
x=removeSaltAndPepper(x,3);
toc;

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


lgsurfIdx = bsxfun(@minus,gsurfIdx,bbox(1,:)-additionalborder-1);
lgsurfIdxi = suba2ind (fm.sy,lgsurfIdx);

nsurfLoc=numel(lgsurfIdxi);
surfPoseIdx2 = poseIdx(fm,lgsurfIdxi,cues,em);


surfPoseIdx2=[surfPoseIdx2,repmat(cuesF,[nsurfLoc,1,1])];
surfPoseIdxi2=suba2ind ([fm.sy fm.nf],surfPoseIdx2);
toc

%%

fprintf('computing input array =feature values at training locations...\n');tic
xSurf=fm.X(surfPoseIdxi2);
toc
fprintf('predict...\n');tic
if exist('selectedFeatures','var')&&~isempty(selectedFeatures)
    [Yfit, Sfit] = predict(ens,xSurf(:,selectedFeatures));
else
    [Yfit, Sfit] = predict(ens,xSurf);
end
toc
%%
figure,hist(Sfit(:,1),30)
threshold=input('Specify threshold!\n');
%%
p=Sfit(:,1).'<threshold;
x=removeSaltAndPepper(single(em.readRoi(bbox.')))/255;
if all(~x)
    error('nothing red! ls %s: %s',em.dataPath,system(sprintf('ls %s',em.dataPath)));
end
%sx=size(x);
% x=shiftdimsright(x);
% x=repmat(x,[3 1 1 1]);
llgsurfIdx=bsxfun(@minus,lgsurfIdx,additionalborder);
% llgsurfIdxi = suba2ind (sx,llgsurfIdx);
% x(:,llgsurfIdxi(p))=[p(p);~p(p);~p(p)];
% 
% x=permute(x,[2 3 1 4]);
% figure,imshow(x);
x=repmat(x,[1 1 3]);
markerInserter = vision.MarkerInserter('Shape','X-mark','BorderColor','Custom','CustomBorderColor',[1 0 0]);

J = step(markerInserter, x, llgsurfIdx(p,[2 1]));
figure,imshow(J);
imwrite(J,fullfile(fileparts(ensfile),'out.png'));





