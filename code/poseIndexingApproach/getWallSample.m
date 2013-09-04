function [ gsurfIdx, gsurfIdxi ] = getWallSample( walls,res,anisotropie )
%GETWALLSAMPLE Summary of this function goes here
%   Detailed explanation goes here
nD=max([stufe(walls) numel(res) numel(anisotropie)]);
sx=[size(walls) ones(1,nD-stufe(walls))];

nC1=numel(walls);
nW1=sum(walls(:));

%grid=true;
mask=0;
for i=1:nD
    %tmp=false([ones(1,i-1) sx(i) ones(1,nD-i+1)]);
    %tmp(1:res(i):sx(i))=true;
    %grid=bsxfun(@and,grid,tmp);%expand to grid
    mask=bsxfun(@plus,mask,permute((((-floor(res(i)/2):floor(res(i)/2))/(res(i)/2)).^2).',[2:i,1,i+1:nD]));
end
mask=mask<=1;

grid=round(bsxfun(@times,fcclattice(ceil(sx./(res*sqrt(2))))-1,res*sqrt(2)))+1;
grid=grid(all(bsxfun(@le, grid,sx),2),:);
grid=num2cell(grid,1);
gridIdxi=sub2ind(sx,grid{:});
grid=false(size(walls));
grid(gridIdxi)=true;

x=imdilate(walls,mask)&grid;%on grid&close to surface
nG1=sum(x(:));
gridIdxi=find(x);%good grid points
gridIdx=ind2suba(sx,gridIdxi);
surfIdxi=find(walls);%all surface points
surfIdx=ind2suba(sx,surfIdxi);
idx = knnsearch(bsxfun(@times,surfIdx,anisotropie),bsxfun(@times,gridIdx,anisotropie));
gsurfIdxi=surfIdxi(idx,:);
gsurfIdx=surfIdx(idx,:);
fprintf('%u - ',nG1,nW1,nC1);
fprintf(' reduction to %f %% \n',100*nG1/nC1);

end

