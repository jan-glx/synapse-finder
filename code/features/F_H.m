classdef F_H < Feature
    %F Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private)
        name='Eigenvalues of Hessian';
        sigma;
    end
    
    methods
        function obj=F_H(sigma)
            obj=obj@Feature();
            obj.sigma=sigma;
        end
        function y=computeFeature(obj,x)
            y=F_H.computeEigsOfHessian(x,obj.sigma);
        end        
        function name=getName(obj)
            name=[obj.name '' sprintf('-%8.2f',obj.sigma)];
        end
        function names=getNames(obj)
            tname=sprintf('Hessian [%.2f,%.2f,%.2f]',obj.sigma);
            names={[tname ' - 3rd eigenvalue'] [tname ' - 2nd eigenvalue'] [tname ' - 1st eigenvalue']};
        end
        function siz=getSiz(obj)
            siz=Feature.compSiz(obj.sigma,4);
        end
    end
    methods (Static)
        function [ y ] = computeEigsOfHessian( x,sigma )
            %COMPUTEEIGSOFSTRUCTURETENSOR Summary of this function goes here
            %   Detailed explanation goes here
            
            T=F_H.computeHessian( x,sigma);
            sY=size(T{1});
            T=cellfun(@flat,T,'UniformOutput',false);
            T=cellfun(@(x)permute(x,[3,2,1]),T,'UniformOutput',false);
            T=cell2mat(T);
            T=eig3(T);
            T=num2cell(T,1).';
            T=cellfun(@(x)real(reshape(x,sY)),T,'UniformOutput',false);
            y=T;
        end
        function [ y,shift ] = computeHessian( x,sigma )
            %COMPUTEHESSIAN inefficient
            nD=ndims(x);
            dims=1:nD;
            siz=ceil(4*sigma);
            idx=arrayfun(@(siz)(-siz:siz).',siz,'UniformOutput',false);
            idx=cellfun(@(idx,dim)permute(idx,[2:(dim) 1 (dim+1):nD]),idx,num2cell(dims),'UniformOutput',false);
            sigmaCell=num2cell(sigma);
            gauss=cellfun(@(idx,sigma)exp(-(idx./sigma).^2./2),idx,sigmaCell,'UniformOutput',false);
            gauss=cellfun(@(gauss)gauss./sum(gauss),gauss,'UniformOutput',false);
            gaussD=cellfun(@(idx,gauss,sigma)-gauss.*idx./sigma.^2,idx,gauss,sigmaCell,'UniformOutput',false);
            gaussD2=cellfun(@(idx,gauss,sigma)gauss.*(idx.^2./sigma.^2-1)./sigma.^2,idx,gauss,sigmaCell,'UniformOutput',false);
            y=cell([nD nD]);
            
            
            for dim1=dims
                for dim2=1:dim1
                    if (dim1==dim2)
                        y{dim1,dim1}=convn(x,gaussD2{dim1},'valid');
                    else
                        y{dim1,dim2}=convn(x,gaussD{dim1},'valid');
                        y{dim1,dim2}=convn(y{dim1,dim2},gaussD{dim2},'valid');
                    end
                    for dim=setdiff(dims,[dim1,dim2])
                        y{dim1,dim2}=convn(y{dim1,dim2},gauss{dim},'valid');
                    end
                    if (dim1~=dim2)
                        y{dim2,dim1}=y{dim1,dim2};
                    end
                end
            end
            shift=sizeDiff(x,y{1})/2;
        end
    end
end

