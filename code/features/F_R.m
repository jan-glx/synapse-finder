classdef F_R < Feature
    %F Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        name='Orientation';
        sigmaD;
        sigma_mean;
        sigma_direction;
    end
    
    methods
        function obj=F_R(sigmaD,sigma_mean,sigma_direction )
            obj=obj@Feature();
            obj.sigmaD =sigmaD;
            obj.sigma_mean =sigma_mean;
            obj.sigma_direction=sigma_direction;
        end
        function R=computeFeature(obj,x)
            sd=Feature.compSiz(obj.sigmaD,3)+Feature.compSiz(obj.sigma_mean,3)-Feature.compSiz(obj.sigma_direction,3);
            sdEV=max(0,-sd);
            sdD=max(0,sd);
            E=F_EigVofStructureTensor.computeEigVofOfStructureTensor(x(1+sdEV(1):end-sdEV(1),1+sdEV(2):end-sdEV(2),1+sdEV(3):end-sdEV(3)),obj.sigmaD,obj.sigma_mean);
            D= F_Grad.computeDerivation( x(1+sdD(1):end-sdD(1),1+sdD(2):end-sdD(2),1+sdD(3):end-sdD(3)),obj.sigma_direction);
            sy=size(E{1});
            E=cellfun(@flat,E,'UniformOutput',false);
            E=permute(E,[3,1,2]);
            E=cell2mat(E);
            D=cellfun(@flat,D,'UniformOutput',false);
            D=cell2mat(D);
            R=zeros(size(E),class(E));
            R(:,:,1)=bsxfun(@times,E(:,:,3),sign(sum(D.*E(:,:,3),2)));
            R(:,:,2)=bsxfun(@times,E(:,:,2),sign(sum(D.*E(:,:,2),2)));
            R(:,:,3)= cross(R(:,:,1),R(:,:,2));
            R=num2cell(R,1);
            R=shiftdimsright(R,-1);
            R=cellfun(@(x)reshape(x,sy),R,'UniformOutput',false);
        end
        function name=getName(obj)
            name=[obj.name '' sprintf('-%8.2f',obj.sigmaD) sprintf('-%8.2f',obj.sigma_mean)];
        end
        function names=getNames(obj)
            names=arrayfun(@(i)[obj.getName() '-' num2str(i)],1:numel(obj.sigmaD),'UniformOutput',false);
        end
        function siz=getSiz(obj)
            siz=max(Feature.compSiz(obj.sigmaD,3)+Feature.compSiz(obj.sigma_mean,3),Feature.compSiz(obj.sigma_direction,3));
        end
        function dim=getDim(obj)
            dim=repmat(numel(obj.sigmaD),2,1);
        end
    end

end