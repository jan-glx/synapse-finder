%load('F:\JanResults\Trainingsets\sampled walls context cues\sampled.mat')
if exist('ens','var')
    warning('variable ens already exists, skipping loading...\n');
    ensfile=fullfile(savepath,'ens.mat');
else
    ensfile='F:\JanResults\Trainingsets\voxelwise\2013-08-18-14-01-11-811276\ens.mat';%'F:\JanResults\Trainingsets\sampled walls no cues\2013-08-16-16-48-06-803883\ens.mat';
    load(fullfile(ensfile,'ens.mat'))
end
ens1=ens.Trainable{1};

fm=featureMap(f);

overlap=0;
bbox=[390, 966, 1352];
bbox=[bbox-overlap;bbox+[200,200,1]-1+overlap];
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

fprintf('computing input array =feature values at training locations...\n');tic
xSurf=reshape(fm.X,[],size(fm.X,4));
toc
fprintf('predicting...\n');tic;
[Yfit, Sfit] = predict(ens1,xSurf);
toc
%%
figure,hist(Sfit(:,1),30)
threshold=input('Specify threshold!\n');
%%
x=removeSaltAndPepper(single(em.readRoi(bbox.')))/255;
if all(~x)
    error('nothing red! ls %s: %s',em.dataPath,system(sprintf('ls %s',em.dataPath)));
end
sx=size(x);
p=reshape(Sfit(:,1).'<threshold,sx);
x=shiftdimsright(x);
x=repmat(x,[3 1 1 1]);
% llgsurfIdxi = suba2ind (sx,llgsurfIdx);
% x(:,llgsurfIdxi(p))=[p(p);~p(p);~p(p)];
% 
% x=permute(x,[2 3 1 4]);
% figure,imshow(x);
x(1,p)=1;
x(2,p)=0;
x(3,p)=0;
x=permute(x,[2 3 1 4]);
figure,imshow(x);
%%
imwrite(x,fullfile(fileparts(ensfile),'out.png'));





