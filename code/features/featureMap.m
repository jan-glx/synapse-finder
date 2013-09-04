classdef featureMap < handle
    %FEATUREMAP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public)
        maxSiz;
        f;
        X;
        X2;
        Y;
        Y2;
        sx;
        sy;
        fR;
        RotM;
    end
    
    methods
        function obj=featureMap(f)
            obj=obj@handle();
            obj.f=f;
            obj.updateMaxSiz();
        end
        
        function updateMaxSiz(obj,f)
            if(~exist('f','var')||isempty(f))
                obj.maxSiz=max(cell2mat(cellfun((@(ff)ff.getSiz()),obj.f,'UniformOutput',false)),[],1);
                if(~isempty(obj.fR))
                    obj.updateMaxSiz(obj.fR);
                end
            else
                obj.maxSiz=max(obj.maxSiz,f.getSiz());
            end
        end
        
        function addFeature(obj,f)
            obj.f{length(obj.f)+1}=f;
            obj.updateMaxSiz(f);
        end
        function setRotationFeature(obj,fR)
            obj.fR=fR;
            obj.updateMaxSiz(fR);
        end
        
        function names=getNames(obj)
            names=cellfun(@getNames,obj.f,'UniformOutput',false);
            names=cat(2,names{:});
        end
        
        function compute(obj,x)%,y)
            obj.sx=size(x);
            obj.sy=obj.sx-2*obj.maxSiz;
            %if(~all(obj.sx-obj.sy>=obj.maxSiz*2))
            %    tmp=num2cell(2*obj.maxSiz);
            %    error('x is not big enough, it has to be at least %i %i %i bigger than y',tmp{:});
            %end
            
            helper=@(f)f.computeFeature(subIdx(x,obj.idx(f.getSiz())));
            XX=cellfun(@(f)helper(f),obj.f,'UniformOutput',false);
            XX=cellfun(@flat,XX,'UniformOutput',false);
            XX=cat(1,XX{:});
            XX=cellfun(@real,XX,'UniformOutput',false);
            obj.X=cell2mat(shiftdimsright(XX,3));            
           % obj.Y=y;            
        end
        function idx=idx(obj,siz)
            idx=arrayfun(@(shift,sX)(shift+1:sX-shift).',(obj.maxSiz*2)/2-siz,obj.sx,'UniformOutput',false);
        end
        function computeR(obj,x)   
            obj.sx=size(x);
            obj.sy=obj.sx-2*obj.maxSiz;
            obj.RotM=obj.fR.computeFeature(subIdx(x,obj.idx(obj.fR.getSiz())));
        end
        
        function nf=nf(obj)
            nf=sum(cellfun(@(f)prod(f.getDim),obj.f));
        end
        
        function poseIdx2 = poseIdx(obj,idx,poseIdx,em)
            R=obj.RotM;
            R=permute(R,[3,1,4,2]);
            R=cellfun(@(r)r(idx),R,'UniformOutput',false);
            R=cell2mat(R);
            idxyz=cell(3,1);
            [idxyz{:}]=ind2sub(obj.sy,idx);
            idxyz=cat(2,idxyz{:});
            poseIdx2=bsxfun(@plus,round(em.nm2voxel(sum(bsxfun(@times,R,shiftdimsright(poseIdx,2)),4))),idxyz);
        end
        
        function computeFeaturesOnStack(obj,emIn,cubesize,outPath,jm,ppath,startidx,nCubesPerTask)
            if ~exist('cubesize','var')||isempty(cubesize)
                cubesize=[512 512 256];
            end
            if ~exist('startidx','var')||isempty(startidx)
                startidx=0;
            end     
            if ~exist('nCubesPerTask','var')||isempty(nCubesPerTask)
                nCubesPerTask=10;
            end  
            
            ff=obj.f;
            function emOut=makeEm(f,i)
                emOut=emIn.copy();
                emOut.classT='single';
                emOut.dim=f.getDim;
                emOut.dataPath=fullfile(outPath,sprintf('feature%03u',startidx+i));
                emOut.expName=sprintf('feature%03u',startidx+i);
                emOut.writeKNOSSOSconf();
                cell2csv(fullfile(outPath,'all.csv'), {startidx+i,f.getName, f.getDim,emOut.classT}, true,',');
            end
            
            if exist('jm','var')&&~isempty(jm)
                job=cell(numel(obj.f),1);
                emOut=cell(numel(obj.f),1);
                
                for i=1:numel(obj.f)
                    job{i}=createJob(jm);
                    emOut{i}=makeEm(ff{i},i);
                    job{i}.PathDependencies= regexp(genpath(ppath),':','split');
                    ff{i}.computeFeatureOnStack(emIn,emOut{i},cubesize,nCubesPerTask,job{i});
                    fprintf('chmodding...\n');
                    fprintf('%s',system(['chmod -Rf 770 ' emOut{i}.dataPath]));
                    fprintf('starting Job...\n');
                    %job{i}.RestartWorker=true;
                    submit(job{i});
                end
%                 running=true(numel(obj.f),1);
%                
%                 while(any(running))
%                     for i=subIdx(1:numel(obj.f),running)
%                         [p, r, c]=job{i}.findTask();
%                         p=numel(p);r=numel(r);c=numel(c);
%                         fprintf('Job %4u not finished:  p.: %4u, r.: %4u, f.: %4u runtime: %s est. time remaining: %s\n', startidx+i, p,r,c,secs2hms(job{i}.pGetRunningDuration),secs2hms(job{i}.pGetRunningDuration*((p+r+c)/(c)-1)));
%                         if p+r==0
%                             running(i)=false;                    
%                         end
%                     end
%                     fprintf('\n');
%                     pause(10);
%                 end
                for i=1:numel(job)
                    
                    job{i}.waitForState('finished');
                    fprintf('job %u finished\n chmoding...\n',startidx+i);
                    ownyourownfiles(emOut{i}.dataPath);
                    X = job{i}.getAllOutputArguments();
                    hasError=~arrayfun(@(task)isempty(task.Error),job{i}.tasks);
                    if any(hasError)
                        msg=arrayfun(@(task)task.Error.getReport(),job{i}.tasks(hasError),'UniformOutput',false);
                        job{i}.destroy();
                        error(cat(2,msg{:}));
                    end
                end                             
            else
                for i=1:numel(obj.f)
                    emOut=makeEm(ff{i},i);
                    ff{i}.computeFeatureOnStack(emIn,emOut,cubesize);
                end
            end
        end
        
    end
end
