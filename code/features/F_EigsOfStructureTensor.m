classdef F_EigsOfStructureTensor < Feature
    %F Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private)
        name='EigsOfStructureTensor';
        sigmaD;
        sigma_mean;
    end
    
    methods
        function obj=F_EigsOfStructureTensor(sigmaD,sigma_mean )
            obj=obj@Feature();
            obj.sigmaD =sigmaD;
            obj.sigma_mean =sigma_mean;
        end
        function y=computeFeature(obj,x)
            y=F_EigsOfStructureTensor.computeEigsOfStructureTensor(x,obj.sigmaD,obj.sigma_mean);
        end
        function name=getName(obj)
            name=[obj.name '' sprintf('-%8.2f',obj.sigmaD) sprintf('-%8.2f',obj.sigma_mean)];
        end
        function names=getNames(obj)
            tname=sprintf('Structure tensor [%.2f,%.2f,%.2f; %.2f,%.2f,%.2f]',[obj.sigmaD obj.sigma_mean]);
            names={[tname ' - 3rd eigenvalue'] [tname ' - 2nd eigenvalue'] [tname ' - 1st eigenvalue']};
        end
        function siz=getSiz(obj)
            siz=Feature.compSiz(obj.sigmaD,3)+Feature.compSiz(obj.sigma_mean,3);
        end
        function dim=getDim(obj)
            dim=numel(obj.sigmaD);
        end
    end
    methods (Static)
        function [ y ] = computeEigsOfStructureTensor( x,sigmaD,sigma_mean )
            %COMPUTEEIGSOFSTRUCTURETENSOR Summary of this function goes here
            %   Detailed explanation goes here
            
            T=computeStructureTensor( x,sigmaD,sigma_mean );
            sY=size(T{1});
            T=cellfun(@flat,T,'UniformOutput',false);
            T=cellfun(@(x)permute(x,[3,2,1]),T,'UniformOutput',false);
            T=cell2mat(T);
            T=eig3(T);
            T=num2cell(T,1).';
            T=cellfun(@(x)real(reshape(x,sY)),T,'UniformOutput',false);
            y=T;
        end
    end
end