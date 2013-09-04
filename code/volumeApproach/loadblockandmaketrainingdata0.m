%%

res=5; %# quantiles
rinclude=150; %nm
nD=3;
[fm,f,~,~,~,~] = makefilterbank (em);

trainingPath='P:\2013\data\vesicleB.mat';


load(fullfile(trainingPath));

synIdxl=x>0;
bbox=bbox.';
zeroOfCube=bbox(1,:);
cubesize=diff(bbox)+1;

%%
fprintf('loading rawdata...\n');tic;
x=single(em.readRoi(bbox.'+[-fm.maxSiz;fm.maxSiz].'));
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
%%
fprintf('generatin input from fm...\n');tic
x=permute(fm.X,[4,1,2,3]);
xx=[x(:,synIdxl),x(:,~synIdxl)].';
yy=[true(sum(synIdxl(:)),1);false(sum(~synIdxl(:)),1)];
toc;
meanC=[ind2suba(cubesize,find(synIdxl));ind2suba(cubesize,find(~synIdxl))];
meanC=bsxfun(@plus,meanC,zeroOfCube-1);
names=fm.getNames();
toc
%%

fprintf('saving results...\n');tic;
[~,tmp]=fileparts(trainingPath);
outPath=fullfile(savePath,[tmp 'Out']);
if ~exist(outPath,'dir')
    mkdir(outPath);
end

outfilename=fullfile(outPath,'volume.mat');

save(outfilename,'xx','yy','meanC','names','f','-v7.3');
fprintf('sucessfully saved as %s\n',outfilename);
toc





















