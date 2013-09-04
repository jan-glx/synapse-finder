%%
balance=false;
res=em.nm2voxel(100); %nm
rinclude=150;rexclude=350; %nm
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
walls=~wallem.readRoi(bbox.');
toc
fprintf('sample walls...\n');tic;
[lsurfIdx, ~]= getWallSample( walls,res,em.anisotropie );
surfIdx=bsxfun(@plus,lsurfIdx,zeroOfCube-1);

names=fm.getNames();
names=names(cuesF);
namespp=cellfun(@(cue,name)sprintf('%s\n[%6.1f %6.1f %6.1f]',name,cue),num2cell(cues,2),names.','UniformOutput',false);
names=namespp;
toc
%%

fprintf('generate Input...\n');tic;
[xx, yy,meanC]=generateInput(fm,bbox,surfIdx,synIdx,em,additionalborder,cues,cuesF,rexclude,rinclude,0,false,balance);
toc






fprintf('saving results...\n');tic;
outPath=fullfile(savePath,[trainingPath 'Out']);
if ~exist(outPath,'dir')
    mkdir(outPath);
end

outfilename=fullfile(outPath,'sampled.mat');

save(outfilename,'xx','yy','meanC','names','rinclude','rexclude','f','cues','cuesF','res','additionalborder','fR','-v7.3');
fprintf('sucessfully saved as %s\n',outfilename);
toc





















