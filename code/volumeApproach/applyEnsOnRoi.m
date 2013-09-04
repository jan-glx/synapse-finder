function applyEnsOnRoi(ens,f,bbox,mbbox,outPath,em,jm,ppath)
nD=numel(mbbox);
nboxes=ceil((diff(bbox)+1)./mbbox);
nB=prod(nboxes);
if exist('jm','var') && ~isempty(jm)
    job=jm.createJob();
    job.PathDependencies= regexp(genpath(ppath),':','split');
    tasks=cell(1,nB);
end

for i = 1:prod(nboxes)
    idx=cell(1,nD);
    [idx{:}]=ind2sub(nboxes,i);
    idx=cell2mat(idx);
    newbb=[bbox(1,:)+(idx-1).*mbbox; bbox(2,:)+idx.*mbbox-1];
    if exist('job','var')
        tasks{i}=createTask(job,@applyEnsOnBlock,0,{ens,f,newbb,outPath,em});
    else
        applyEnsOnBlock(ens,f,newbb,outPath,em);
    end
end
if exist('job','var')
    job.submit();job.wait();
    for i=1:length(nB)
        if(~isempty(tasks{i}.Error))
            error(tasks{i}.Error.getReport());
        end
        %tmp = tasks{i}.pGetOutputArguments();
    end
    job.destroy();
end
end






