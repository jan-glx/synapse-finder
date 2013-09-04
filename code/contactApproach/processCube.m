function [ xx,yy,meanL,meanR,meanC] = processCube (cubeCoords, gnodeIdx,gsynIdx,segPath,segName,em,fm,res,rinclude )
%PROCESSCUBE Summary of this function goes here
%   Detailed explanation goes here

    nD=size(cubeCoords,2);
    nf=(fm.nf)*numel(0:1/res:1)*3+3;
    xx=zeros(0,nf,'single');
    yy=false(0,1);
    meanL=zeros(0,nD);
    meanR=zeros(0,nD);
    meanC=zeros(0,nD);    
    overlap=10;
    fprintf('load walls...\n');tic;
    cube = readKnossosCube(segPath,segName,cubeCoords, 'uint16', 128+2*overlap);
    if ~any(cube(:))
        warning('nuthing read');
        return;
    end
    toc
    fprintf('find walls of traced cells...\n');tic;
    zeroOfCube = cubeCoords * 128 + 1-overlap;
    cubesize=repmat(128,1,nD)+2*overlap;
     bbox=[zeroOfCube;zeroOfCube+cubesize-1];
     
   % synIdx = bsxfun(@minus,gsynIdx,zeroOfCube-1);
    nodeIdx = bsxfun(@minus,gnodeIdx,zeroOfCube-1);
    
    colors=cube(suba2ind(size(cube),nodeIdx));
    colors(colors == 0) = []; %color==0 <==> node is on wall
    colors=unique(colors);
    if(numel(colors)==0)
        colors=ones(0,1); %cause ml sucks
    end
    cube2=any(bsxfun(@eq,cube,permute(colors,[2:nD+1,1])),nD+1);
    cube2=imdilate(cube2,ones(repmat(3,1,nD)));
    cube2=cube2&~cube; %walls next to segment with node
    toc
    [rlswallidxi, subsegidxis ] = getIdx( cube,cube2,em,rinclude );
       
    if size(rlswallidxi,1)<=1
        fprintf('skipping cube %u %u %u - only one contact in here & ml sucks',cubeCoords);
        return;
    end
    [xx, meanL, meanR, meanC]=generateInput2(em,fm,bbox,subsegidxis,rlswallidxi,res);
    isSomeWhereElse=any(bsxfun(@lt,meanC,zeroOfCube+overlap),2)|any(bsxfun(@gt,meanC,zeroOfCube+cubesize-1-overlap),2);   
    yy=false(size(xx,1),1);
    [idx,dist]=knnsearch(meanC,gsynIdx);    
    yy(idx)=true;
    if ~isempty(dist)
    fprintf('                         ');
    fprintf('<%d>',dist);
    fprintf('\n');
    end
    xx=xx(~isSomeWhereElse,:);
    meanL=meanL(~isSomeWhereElse);
    meanR=meanR(~isSomeWhereElse);
    meanC=meanC(~isSomeWhereElse);
    yy=yy(~isSomeWhereElse);
end

