%%

res=5; %# quantiles
rinclude=150; %nm
nD=3;
[fm,f,fR,cues,cuesF,additionalborder] = makefilterbank (em);

trainingPath='irisnatalias100.nml';

nmax=Inf;
minNodes=100;
validCubeBBox=[[7 5 1]+1;[66 43 25]-1];

[ bbox, lsynIdx,synIdx]=getSynapsesFromNml2(trainingPath);
bbox=bsxfun(@plus,bbox,[30;-30]);
zeroOfCube=bbox(1,:);
cubesize=diff(bbox)+1;

wallem=emData.readKNOSSOSconf(wallempath,[],'uint16');
wallem.overlap=10;
overlap=wallem.overlap;
fprintf('loading walls...\n');tic;
walls=wallem.readRoi(bbox.');
toc
segments=bwlabeln(walls,26);
%%
[rlswallidxi, subsegidxis ] = getIdx( segments,~walls,em,rinclude );
[xx, meanL, meanR, meanC]=generateInput2(em,fm,bbox,subsegidxis,rlswallidxi,res);

yy=false(size(xx,1),1);
[idx,dist]=knnsearch(meanC,synIdx);    
yy(idx)=true;

namesC=arrayfun(@(q)cellfun(@(name)sprintf('%s - %2.0f%% quantil',name,q*100),fm.getNames(),'UniformOutput',false),0:1/res:1,'UniformOutput',false);
namesC=cellocells2cell(namesC);
namesC=namesC(:);
namesC=[namesC;{'size'}];

namesL=cellfun(@(name)sprintf('left: %s ',name),namesC,'UniformOutput',false);
namesR=cellfun(@(name)sprintf('right: %s ',name),namesC,'UniformOutput',false);
namesC=cellfun(@(name)sprintf('contact: %s ',name),namesC,'UniformOutput',false);
names=[namesC; namesL; namesR];
toc
%%
fprintf('saving results...\n');tic;
outPath=fullfile(savePath,[trainingPath 'Out']);
if ~exist(outPath,'dir')
    mkdir(outPath);
end

outfilename=fullfile(outPath,'contacts.mat');

save(outfilename,'xx','yy','meanL','meanC','meanR','names','rinclude','f','res','-v7.3');
fprintf('sucessfully saved as %s\n',outfilename);
toc





















