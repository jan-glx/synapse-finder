% synapsefile='F:\JanResults\fromFermat\iris\newapproach7.mat'
% load(fullfile(synapsefile));
% ens = fitensemble(xx,yy,'RUSBoost',300,'tree','LearnRate',1,'nprint',1);
%%
if exist('ens','var')
    warning('variable ens already exists, skipping loading...\n');
    ensfile=fullfile(savepath,'ens.mat');
else
    ensfile='F:\JanResults\Trainingsets\voxelwise\2013-08-18-14-01-11-811276\ens.mat';%'F:\JanResults\Trainingsets\sampled walls no cues\2013-08-16-16-48-06-803883\ens.mat';
    load(fullfile(ensfile,'ens.mat'))
end
ens1=ens.Trainable{3};

fm=featureMap(f);


wallem=emData.readKNOSSOSconf('F:\datasets\walls',[],'uint16');
wallem.overlap=10;
overlap=30;

bbox=[390, 966, 1352];
bbox=[bbox-overlap;bbox+[200,200,1]-1+overlap];


fprintf('loading walls...\n');tic;
walls=wallem.readRoi(bbox.');
toc
segments=bwlabeln(walls,26);
%%
[rlswallidxi, subsegidxis ] = getIdx( segments,~walls,em,rinclude );
[xx, meanL, meanR, meanC]=generateInput2(em,fm,bbox,subsegidxis,rlswallidxi,res);
fprintf('predicting...\n');tic;
[yy, syy] = predict(ens1,xx);
toc
%%
syy2=syy(:,2);
figure,hist(syy(:,2),30);
threshold=input('Specify threshold!\n');
%%
sigm=std(syy2)/sqrt(numel(syy2)-1);
syy2=arrayfun(@(syy2i)sum(0.5+0.5*erf((syy2-syy2i)/2/sigm^2),1),syy2)/numel(syy2);
syy2=syy(:,2)>threshold;

fprintf('loading rawdata...\n');tic;
x=removeSaltAndPepper(single(em.readRoi(bbox.')))/255;
toc
y=shiftdimsright(x);
y=repmat(y,[3 1 1 1]);
for iContact=1:numel(yy)
    sublabel=rand(1,numel(rlswallidxi{iContact}))<0.1;
    y(1,rlswallidxi{iContact})=syy2(iContact)+~syy2(iContact)*y(1,rlswallidxi{iContact});%./(1+syy2(iContact).*sublabel);
    y(3,rlswallidxi{iContact})=~syy2(iContact)*y(1,rlswallidxi{iContact});%1-syy2(iContact);%./(1+(1-syy2(iContact)).*sublabel);
    y(2,rlswallidxi{iContact})=~syy2(iContact)*y(1,rlswallidxi{iContact});%0;
end
y=permute(y,[2 3 1 4]);
y2=(y(overlap+1:end-overlap,overlap+1:end-overlap,:,overlap+1:end-overlap));
x2=(x(overlap+1:end-overlap,overlap+1:end-overlap,overlap+1:end-overlap));
x2=shiftdimsright(x2);
x2=repmat(x2,[3 1 1 1]);
x2=permute(x2,[2 3 1 4]);
y2=permute(y2,[1 2 3 5 4]);
x2=permute(x2,[1 2 3 5 4]);
y2=cat(4,y2,x2);
y2=reshape(y2,size(y2,1),size(y2,2),size(y2,3),[]);
figure,imshow(y2(:,:,:,1));
%%
figure,imshow(x2(:,:,:,1));
%%
imwrite(y2(:,:,:,1),fullfile(fileparts(ensfile),'out.png'))
imwrite(x2(:,:,:,1),fullfile(fileparts(ensfile),'in.png'))

if (false)
    %%
    load(fullfile('F:\JanResults\Trainingsets\groundtrouthKLEE.mat'));
    KLEE_savedTracing.bbox(1:2,2)=KLEE_savedTracing.bbox(1:2,2)-1;
    [a,~]=convertKleeTracingToLocalStack( KLEE_savedTracing ,autoKLEE_colormap,0);
    a=single(a);
    a=a>0;
    y3=permute(x2(:,:,:,1),[3 1 2]);
    y3(1,a)=0;
    y3(2,a)=0;
    y3(3,a)=1;
    y3=permute(y3,[2 3 1]);
    figure,imshow(y3);
    %%
    imwrite(y3,fullfile(fileparts(ensfile),'gold.png'));
end
