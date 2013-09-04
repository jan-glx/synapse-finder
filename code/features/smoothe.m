function [ smA ] = smoothe( smA, sigma )
%SMOOTHE Summary of this function goes here
%   Detailed explanation goes here
sigma=ceil(sigma/2)*2+1; %ensure oddness
normalizer=ones(size(smA));
for dim=1:ndims(smA)
    gauss1D=fspecial('gaussian',[3*sigma(dim) 1],sigma(dim)); %separabel
    gauss1D=gauss1D./sum(gauss1D);
    gauss1D=permute(gauss1D,[2:(dim) 1 (dim+1):ndims(smA)]);
    smA=convn(smA,gauss1D,'same');
    normalizer=convn(normalizer,gauss1D,'same');
end
smA=smA./normalizer;

end

