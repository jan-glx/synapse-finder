classdef F_Grad < Feature
    %F Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private)
        name='Gaussian Der. Mag.';
        sigma;
    end
    
    methods
        function obj=F_Grad(sigma)
            obj=obj@Feature();
            obj.sigma=sigma;
        end
        function y=computeFeature(obj,x)
            y=F_Grad.computeDerivation(x,obj.sigma);
            y=cellfun(@(x)x.^2,y,'UniformOutput',false);
            y={sqrt(cellsum(y))};
        end
        function name=getName(obj)
            name=[obj.name sprintf(' [%.2f,%.2f,%.2f]',obj.sigma)];
        end
        function siz=getSiz(obj)
            siz=Feature.compSiz(obj.sigma,3);
        end
    end
    methods (Static)
        function [ y,shift ] = computeDerivation( x,sigmaD )
            %COMPUTEDERIVATION Summary of this function goes here
            %   Detailed explanation goes here
            nD=ndims(x);
            dims=1:nD;
            
            siz1=ceil(3*sigmaD);
            sigmaCell1=num2cell(sigmaD);
            idx=arrayfun(@(siz)(-siz:siz).',siz1,'UniformOutput',false);
            idx=cellfun(@(idx,dim)permute(idx,[2:(dim) 1 (dim+1):nD]),idx,num2cell(dims),'UniformOutput',false);
            gauss1=cellfun(@(idx,sigma)exp(-(idx./sigma).^2./2),idx,sigmaCell1,'UniformOutput',false);
            gauss1=cellfun(@(gauss,sigma)gauss./sum(gauss),gauss1,'UniformOutput',false);
            gaussD=cellfun(@(idx,gauss,sigma)-gauss.*idx./sigma.^2,idx,gauss1,sigmaCell1,'UniformOutput',false);
            
            y=cellfun(@(gaussD)convn(x,gaussD,'valid'),gaussD,'UniformOutput',false);
            for dim1=dims
                for dim=setdiff(dims,dim1)
                    y{dim1}=convn(y{dim1},gauss1{dim},'valid');
                end
            end
            shift=sizeDiff(x,y{1})/2;
        end
        
        
    end
end

