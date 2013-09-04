classdef Feature  < handle
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods  (Abstract)
        y=computeFeature(obj,x);
        siz=getSiz(obj);
        name=getName(obj);
    end
    methods
        function names=getNames(obj)
            names={obj.getName};
        end
        function dim=getDim(obj)
            dim=1;
        end
        function job=computeFeatureOnStack(obj,emIn,emOut,cubesize,nCubesPerTask,job)
            %cubeCoords=arrayfun(@(boundary,cubesize)[1:cubesize:boundary boundary+1],emIn.boundary,cubesize,'UniformOutput',false);
            %cubeCoords=cat(2,cubeCoords{:});
            %cubeCoords=num2cell(cubeCoords,1);
            %startCoords=
            NCubes=ceil((emIn.boundary-2*obj.getSiz)./cubesize);
            nCubes=prod(NCubes);
            nD=numel(NCubes);
            function bbox=i2coords(i)
                coords=cell(nD,1);
                [coords{:}]=ind2sub(NCubes,i);
                coords=cat(2,coords{:});
                first=1+(coords-1).*cubesize+obj.getSiz;
                last=coords.*cubesize+obj.getSiz;
                last(coords==NCubes)=subIdx(emIn.boundary-obj.getSiz,coords==NCubes);
                bbox=[first; last];
            end
            bboxes=arrayfun(@(i)i2coords(i),1:nCubes,'UniformOutput',false);
            if exist('job','var') && ~isempty(job)
                ntasks=ceil(nCubes/nCubesPerTask);
                params=cell(ntasks,1);
                for i=1:ntasks
                    params{i}={emIn,emOut,cell(1,0)};
                end
                for i=1:nCubes
                    j=ceil(i/nCubesPerTask);
                    params{j}{3}=[params{j}{3} bboxes(i)];
                end
                fprintf('adding Tasks...\n');
                createTask(job,@obj.computeFeatureOnRoi,0,params);
            else
                startt=tic;
                for i=1:nCubes
                    obj.computeFeatureOnRoi(emIn,emOut,bboxes{i});
                    fprintf('wrote cube %i of %i. estimated time remaining: %s \n',i,nCubes,  secs2hms(toc(startt)*(nCubes/i-1)));
                end
            end
        end
        function computeFeatureOnRoi(obj,emIn,emOut,bboxOut)
            siz=getSiz(obj);
            if ~iscell(bboxOut)
                bboxOut={bboxOut};
            end
            for i=1:numel(bboxOut)
                bboxIn=bboxOut{i}+[-siz; +siz];
                x=emIn.readRoi(bboxIn.');
                x=removeSaltAndPepper(single(x),3);
                x=obj.computeFeature(x);
                s1=size(x{1});
                s2=size(x);
                x=cat(4,x{:});
                x=reshape(x,[s1 s2]);
                emOut.writeRoi(x,bboxOut{i});
            end
        end
    end
    methods (Static)
        function siz = compSiz(sigma,n)
            siz=ceil(n*sigma);
        end
    end
    
end

