classdef F_EigVofStructureTensor < Feature
    %F Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private)
        name='StructureTensor';
        sigmaD;
        sigma_mean;
    end
    
    methods
        function obj=F_EigVofStructureTensor(sigmaD,sigma_mean )
            obj=obj@Feature();
            obj.sigmaD =sigmaD;
            obj.sigma_mean =sigma_mean;
        end
        function y=computeFeature(obj,x)
            y=F_EigVofStructureTensor.computeEigsOfStructureTensor(x,obj.sigmaD,obj.sigma_mean);
        end
        function name=getName(obj)
            name=[obj.name '' sprintf('-%8.2f',obj.sigmaD) sprintf('-%8.2f',obj.sigma_mean)];
        end
        function names=getNames(obj)
            names=arrayfun(@(i)[obj.getName() '-' num2str(i)],1:numel(obj.sigmaD),'UniformOutput',false);
        end
        function siz=getSiz(obj)
            siz=Feature.compSiz(obj.sigmaD,3)+Feature.compSiz(obj.sigma_mean,3);
        end
        function dim=getDim(obj)
            dim=repmat(numel(obj.sigmaD),2,1);
        end
    end
    methods (Static)
        function [ y ] = computeEigVofOfStructureTensor( x,sigmaD,sigma_mean )
            %COMPUTEEIGSOFSTRUCTURETENSOR Summary of this function goes here
            %   Detailed explanation goes here
            
            y=computeStructureTensor( x,sigmaD,sigma_mean );
            sY=size(y{1});
            y=cellfun(@flat,y,'UniformOutput',false);
            y=shiftdimsright(y);
            y=cell2mat(y);
            [y,~]=eig3v3(y);
            y=num2cell(real(y),1);
            y=shiftdimsright(y,-1);
            y=cellfun(@(x)reshape(x,sY),y,'UniformOutput',false);
        end
    end
end