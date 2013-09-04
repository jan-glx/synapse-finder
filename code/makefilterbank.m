function [fm,f,fR,cues,cuesF,additionalborder] = makefilterbank (em)
%PROCESSCUBE Summary of this function goes here
%   Detailed explanation goes here
ncues=500;
threeSigmaCueDist=500; %nm
sigma_D=em.nm2voxel(12);%nm
sigma_mean=em.nm2voxel(12);%nm
sigma_mean2=em.nm2voxel(20);%nm
sigma_direction=em.nm2voxel(60);%nm
nD=3;
f={...
    F_id(nD)
    F_Gaussian(sigma_mean)
    F_Gaussian(sigma_mean*2)
    F_Gaussian(sigma_mean*3)
    F_LoG(sigma_mean)
    F_LoG(sigma_mean*2)
    F_LoG(sigma_mean*3)
    F_LoG(sigma_mean*4)
    F_EigsOfStructureTensor(sigma_D,sigma_mean2)
    F_EigsOfStructureTensor(sigma_D*2,sigma_mean2)
    F_EigsOfStructureTensor(sigma_D,sigma_mean2*2)
    F_EigsOfStructureTensor(sigma_D*2,sigma_mean2*2)
    F_EigsOfStructureTensor(sigma_D*3,sigma_mean2*3)
    F_H(sigma_mean)
    F_H(sigma_mean*2)
    F_H(sigma_mean*3)
    F_Grad(sigma_direction)
    F_Grad(sigma_direction/2)
    F_Grad(sigma_direction*2)
    F_Grad(sigma_direction*3)
};
fm=featureMap(f);
fR=F_R(sigma_D,sigma_mean,sigma_direction);
fm.setRotationFeature(fR);

additionalborder=round(em.nm2voxel(threeSigmaCueDist));
threeSigmaCueDist=em.voxel2nm(additionalborder-1);
cues=randn(ceil(ncues/0.97.^3+10),3).*min(threeSigmaCueDist)/3;
cues=cues(sum(cues.^2,2)<min(threeSigmaCueDist).^2,:);
cues=cues(1:ncues,:);
cues=[zeros(fm.nf,3);cues];
cuesF=[(1:fm.nf).';randi(fm.nf,ncues,1)];
cuesF=shiftdimsright(cuesF,2);

end