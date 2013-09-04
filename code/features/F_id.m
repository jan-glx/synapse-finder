classdef F_id < Feature
    %F Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private)
        name='Identety';
        nD;
    end
    
    methods
        function obj=F_id(nD)
            obj=obj@Feature();
            obj.nD=nD;
        end
        function y=computeFeature(~,x)
            y={x};
        end
        function name=getName(obj)
            name=obj.name;
        end
        function siz=getSiz(obj)
            siz=zeros(1,obj.nD);
        end
    end
end

