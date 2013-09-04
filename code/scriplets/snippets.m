

res=em.nm2voxel(100); %nm

embak=em;load('P:\2013\Training\synapseNatalia2.mat');em=embak; clear embak
bbox=bbox.';
synapses=x;



wallem=emData.readKNOSSOSconf('F:\datasets\walls',[],'uint16');
wallem.overlap=10;
fprintf('loading walls...\n');tic;
x=wallem.readRoi(bbox.');
toc

fprintf('sample walls...\n');tic;
[lsurfIdx, lsurfIdxi]= getWallSample( ~x,res,wallem.anisotropie );

toc
%%


y=removeSaltAndPepper(em.readRoi(bbox.'));
x3=false(size(y));x3(lsurfIdxi)=true;
 %myMiniMovieMaker(single(y)/255,single(x3),'surfacesampling.avi',0.5);
z=y;z(x3)=255;
implay(z)

%%
hh=synapses(gsurfIdxi);
fprintf('  synapse: %d\nnosynapse: %d\n',sum(hh(:)>0)/numel(hh),sum(hh(:)==0)/numel(hh));
% hh=hh(hh>0);
% hh=histc(hh,(1:max(hh)-0.5));
% figure,hist(hh,80)
%%
% 5
% z=y;
% z(xor(synapses==5,imdilate(synapses==5,ones(3,3,3))))=255;
% implay(z)

%% eigenvalues
%implay(permute(cat(2,bsxfun(@rdivide,fm.X(:,:,:,9:11),max(max(max(fm.X(:,:,:,9:11))))),repmat(fm.X(:,:,:,1),[1,1,1,3])/255),[1,2,4,3]))

%% Normal
% R=fm.RotM;
% R=R(:,1);
% R=shiftdimsright(R,2);
% R=shiftdimsright(R,1);
% R=cell2mat(R);
% max(R(:))
% min(R(:))
% R=(R+1)/2;
% implay(permute(cat(2,R,repmat(fm.X(:,:,:,1),[1,1,1,3])/255),[1,2,4,3]))










