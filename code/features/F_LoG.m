classdef F_LoG < Feature
    %F Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private)
        name='Lapl. of Gaussian';
        sigma;
    end
    
    methods
        function obj=F_LoG(sigma)
            obj=obj@Feature();
            obj.sigma=sigma;
        end
        function y=computeFeature(obj,x)
            y={F_LoG.computeLoG(x,obj.sigma)};
        end
        function name=getName(obj)
            name=[obj.name ' ' sprintf('[%.2f,%.2f,%.2f]',obj.sigma)];
        end
        function siz=getSiz(obj)
            siz=Feature.compSiz(obj.sigma,4);
        end
    end
    methods (Static)
        function [ y,shift ] = computeLoG( x,sigma )
            %COMPUTEHESSIAN inefficient
            nD=ndims(x);
            dims=1:nD;
            siz=ceil(4*sigma);
            idx=arrayfun(@(siz)(-siz:siz).',siz,'UniformOutput',false);
            idx=cellfun(@(idx,dim)permute(idx,[2:(dim) 1 (dim+1):nD]),idx,num2cell(dims),'UniformOutput',false);
            sigmaCell=num2cell(sigma);
            gauss=cellfun(@(idx,sigma)exp(-(idx./sigma).^2./2),idx,sigmaCell,'UniformOutput',false);
            gauss=cellfun(@(gauss)gauss./sum(gauss),gauss,'UniformOutput',false);
            gaussD2=cellfun(@(idx,gauss,sigma)gauss.*(idx.^2./sigma.^2-1)./sigma.^2,idx,gauss,sigmaCell,'UniformOutput',false);
            y=zeros(size(x)-(siz*2+1)+1);
                        
            for dim1=dims
                tmp=convn(x,gaussD2{dim1},'valid');
                
                for dim=setdiff(dims,dim1)
                    tmp=convn(tmp,gauss{dim},'valid');
                end
                y=y+tmp;
            end
            shift=sizeDiff(x,y)/2;
        end
    end
end

