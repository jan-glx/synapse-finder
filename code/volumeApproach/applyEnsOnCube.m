function [Yfit, Sfit]=applyEnsOnCube( ens,f,x,jm)
fm=featureMap(f);
fprintf('computing Cube...\n');tic
fm.computeX(x);toc,

    function [Yfit, Sfit] = applyEns( ens,X)
        %APPLYENS Summary of this function goes here
        %   Detailed explanation goes here
        [Yfit, Sfit] = predict(ens,X);
        if isa(ens,'TreeBagger')
            Yfit=cellfun(@(x)strcmp(x,'1'),Yfit);
        end
        sY=fm.sy;
        Yfit=reshape(Yfit,sY);
        Sfit=Sfit(:,2);
        Sfit=reshape(Sfit,sY);
    end
fprintf('classifying Cube...\n');tic
if exist('jm','var')
    job=jm.createJob();
    nmax=100000;
    nX=size(fm.X,1);
    from=1:nmax:nX;
    to=nX:-nmax:1;
    Yfit=false(fm.sy);
    Sfit=zeros(fm.sy);
    tasks=cell(1,length(from));
    for i=1:length(from)
        tasks{i} = job.createTask(@(x)applyEns( ens,x),2,{fm.X(from(i):to(i),:)});
    end
    job.submit();
    job.wait();
    for i=1:length(from)
        if(~isempty(tasks{i}.Error))
            error(tasks{i}.Error.getReport());
        end
        tmp = tasks{i}.pGetOutputArguments();
        Yfit(from(i):to(i))= tmp{1}.';
        Sfit(from(i):to(i))= tmp{2}(:,1).';
    end

    job.destroy();
else
    [Yfit, Sfit] = applyEns( ens,fm.X);
end
toc
end



