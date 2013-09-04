classdef F_Gaussian < Feature
    %F Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private)
        name='Gaussian';
        sigma;
    end
    
    methods
        function obj=F_Gaussian(sigma)
            obj=obj@Feature();
            obj.sigma=sigma;
        end
        function y=computeFeature(obj,x)
            y={F_Gaussian.computeGaussian(x,obj.sigma)};
        end
        function name=getName(obj)
            name=[obj.name sprintf(' [%.2f,%.2f,%.2f]',obj.sigma)];
        end
        function siz=getSiz(obj)
            siz=F_Gaussian.compSiz(obj.sigma,3);
        end
    end
    methods (Static)
        function  [ y,shift ] = computeGaussian( x,sigma )
            %COMPUTEGAUSSIAN Summary of this function goes here
            %   Detailed explanation goes here
            nD=ndims(x);
            dims=1:nD;
            siz=ceil(3*sigma);
            idx=arrayfun(@(siz)(-siz:siz).',siz,'UniformOutput',false);
            idx=cellfun(@(idx,dim)permute(idx,[2:(dim) 1 (dim+1):nD]),idx,num2cell(dims),'UniformOutput',false);
            sigmaCell=num2cell(sigma);
            gauss=cellfun(@(idx,sigma)exp(-(idx./sigma).^2./2),idx,sigmaCell,'UniformOutput',false);
            gauss=cellfun(@(gauss)gauss./sum(gauss),gauss,'UniformOutput',false);
            y=x;
            for dim1=dims
                y=convn(y,gauss{dim1},'valid');
            end
            shift=sizeDiff(x,y)/2;
        end
    end
end

