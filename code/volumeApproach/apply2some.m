

clear em;
startup
ensName='2013-07-04-16-42-10-477092';'2013-06-20-18-39-53-142509';
loadpath=fullfile(savePath,ensName);
load(fullfile(loadpath,'ens.mat'));
bbox=[1001 1300;1001 1300;1001 1200];

jm=findResource();
if exist('jm.UserName','var')
    jm.UserName='jgleixne';
end

fprintf('starting...\n');startt=tic();
applyEnsOnRoi(ens,f,bbox.',[100 100 50],fullfile(loadpath,'out'),em,jm,ppath);
ttime=toc(startt);
fprintf('finished\n');toc(startt)

fprintf('rate %d\n',prod(diff(bbox.'))/ttime);


%% video

outEm=emData();
outEm.readKNOSSOSconf(fullfile(savePath,ensName,'out'),'knossos.conf');
myMovieMaker(em,outEm,bbox.',fullfile(savePath,ensName,'big.avi'))




