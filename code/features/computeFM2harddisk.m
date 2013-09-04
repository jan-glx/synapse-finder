
clear fm
clear f
sigma_D=em.nm2voxel(12);
sigma_mean=em.nm2voxel(28);
sigma_direction=em.nm2voxel(60);
nD=3;
f={...
    F_EigsOfStructureTensor(sigma_D,sigma_mean)
    F_EigsOfStructureTensor(sigma_D*2,sigma_mean)
    F_EigsOfStructureTensor(sigma_D,sigma_mean*2)
    F_EigsOfStructureTensor(sigma_D*2,sigma_mean*2)
    F_EigsOfStructureTensor(sigma_D*3,sigma_mean*3)
    };

fm=featureMap(f);



%ppath='/zdata/Jan/2013';
outPath=fullfile(savePath,[em.dataName '_features']);
allfile=fullfile(outPath,'all.csv');
if exist(allfile,'file')
    dd=csv2cell(allfile,'fromfile');
    startidx=size(dd,1);
else
    startidx=0;
end

jm=findResource();
if exist('jm.UserName','var')
    jm.UserName='jgleixne';
end

fm.computeFeaturesOnStack(em,[512 512 512],outPath,jm,ppath,startidx,10);



%% check
%em3=emData.readHDF5att(fullfile([path2hdf5(1:end-3) '_features'],'feature001.h5'));
dd=csv2cell(allfile,'fromfile');
for i=1:size(dd,1)
    em3=emData.readKNOSSOSconf(fullfile(outPath,sprintf('feature%03u',i)),'knossos.conf',dd{i,4});
    em3.dim=str2double(dd{i,3});
    block=em3.readRoi([1000 1300;1000 1300;1000 1000]);
    for j=1:prod(em3.dim)
        ppp(block(:,:,:,j));
    end
end

%pp(em.readRoi([200 1000;200 1000;150 450]))


