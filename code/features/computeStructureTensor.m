function [ y,shift] = computeStructureTensor( x,sigmaD,sigma_mean )
%COMPUTEHESSIAN inefficient
nD=ndims(x);
dims=1:nD;


siz2=ceil(3*sigma_mean);
sigmaCell2=num2cell(sigma_mean);
idx=arrayfun(@(siz)(-siz:siz).',siz2,'UniformOutput',false);
idx=cellfun(@(idx,dim)permute(idx,[2:(dim) 1 (dim+1):nD]),idx,num2cell(dims),'UniformOutput',false);
gauss=cellfun(@(idx,sigma)exp(-(idx./sigma).^2./2),idx,sigmaCell2,'UniformOutput',false);
gauss=cellfun(@(gauss)gauss./sum(gauss),gauss,'UniformOutput',false);

tmp=F_Grad.computeDerivation(x,sigmaD);

y=cell(nD,nD);
for dim1=dims
    for dim2=1:dim1
        y{dim1,dim2}=tmp{dim1}.*tmp{dim2};
        for dim3=dims
            y{dim1,dim2}=convn(y{dim1,dim2},gauss{dim3},'valid');
        end
        if (dim1~=dim2)
            y{dim2,dim1}=y{dim1,dim2};
        end
    end
end

shift=sizeDiff(x,y{1})/2;

end





