function [  ] = applyEnsOnBlock(ens,f,bbox,outPath,em)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    fprintf('starting...\n');startt=tic();
    fprintf('loading...\n');tic
    fm=featureMap(f);maxSiz=fm.maxSiz;
    x=single(readKnossosRoi(em.dataPath, em.dataName, (bbox+bsxfun(@times,maxSiz,[-1; 1])).', 'uint8' ));toc
    if all(~x)
        error('nothing red! ls %s: %s',em.dataPath,system(sprintf('ls %s',em.dataPath)));
    end
    fprintf('cleaning...\n');tic
    x=removeSaltAndPepper(x,3);toc
    [Yfit, Sfit]=applyEnsOnCube( ens,f,x);toc()
    
    
    %shift=(size(x)-size(Yfit))/2;
    %x=x(shift(1)+1:end-shift(1),shift(2)+1:end-shift(2),shift(3)+1:end-shift(3));
    
    
    fprintf('writing Knossos...\n');tic,
    outEm=em.copy();
    outEm.dataPath=outPath;
    outEm.expName=[outEm.expName '_ves'];
    outEm.writeKNOSSOSconf();
    writeKnossosRoi(outEm.dataPath,outEm.expName,bbox(1,:),uint8(Sfit*256));
    toc;
    ttime=toc(startt);
    fprintf('finished\n');toc(startt)
    
    fprintf('rate %d\n',numel(x)/ttime);
end

