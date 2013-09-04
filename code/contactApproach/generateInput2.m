
function [xx, meanL, meanR, meanC]=generateInput2(em,fm,bbox,segments,contacts,res)
sxx=diff(bbox)+1;
fprintf('loading rawdata...\n');tic;
x=single(em.readRoi(bbox.'+[-fm.maxSiz;fm.maxSiz].'));
if all(~x)
    error('nothing red! ls %s: %s',em.dataPath,system(sprintf('ls %s',em.dataPath)));
end
toc
fprintf('remoove noise\n');tic;
x=removeSaltAndPepper(x,3);
toc;

%% compute feature map
fprintf('computing fm...\n');tic
fm.compute(x);
toc

%% compute mean Pos
fprintf('computing mean positions...\n');tic
meanC=cellfun(@(contact)mean(ind2suba(sxx,contact),1),contacts,'UniformOutput',false);
meanS=cellfun(@(segment)mean(ind2suba(sxx,segment),1),segments,'UniformOutput',false);
meanL=meanS(:,1);
meanR=meanS(:,2);

meanC=cat(1,meanC{:});
meanL=cat(1,meanL{:});
meanR=cat(1,meanR{:});

meanC=bsxfun(@plus,meanC,bbox(1,:)-1);
meanL=bsxfun(@plus,meanL,bbox(1,:)-1);
meanR=bsxfun(@plus,meanR,bbox(1,:)-1);
toc
%%
debug=false;

if debug
    for i=1:numel(contacts) 
        tmp=bbox2subc(1+bbox-[bbox(1,:)-fm.maxSiz;bbox(1,:)-fm.maxSiz]);
        y=x(tmp{:})/255;
        y=shiftdimsright(y);
        y=repmat(y,[3 1 1 1]);
        y(1,segments{i,1})=max(y(1,segments{i,1})-0.125,0);
        y(2,segments{i,2})=max(y(2,segments{i,2})-0.125,0);
        y(3,contacts{i}  )=min(y(3,contacts{i}  )+0.125,1);
        y=permute(y,[2 3 1 4]);
        implay(y);
        if ~debug
            break;
        end
    end
end

x=permute(fm.X,[4,1,2,3]);

    function xx=pooledfeatures(contact)
        xx=x(:,contact);
        xx=sort(xx,2);
        n=size(xx,2);
        raster=0:1/res:1;
        raster=1+raster*(n-1);
        left=floor(raster);   
        right=min(left+1,n);
        xx=bsxfun(@times,xx(:,left),left-raster+1)+bsxfun(@times,xx(:,right),raster-left);
    end
fprintf('computing pooled features for contacts...\n');tic
xC=cellfun(@(contact)pooledfeatures(contact),contacts,'UniformOutput',false);
toc

fprintf('computing pooled features for segments...\n');tic
xS=cellfun(@(segment)pooledfeatures(segment),segments,'UniformOutput',false);
toc

    function xx=shapefeaturesC(contact)
        xx=numel(contact);
    end
fprintf('computing shape features for contacts...\n');tic
xC2=cellfun(@(contact)shapefeaturesC(contact),contacts,'UniformOutput',false);
toc

fprintf('computing shape features for segments...\n');tic
xS2=cellfun(@(segment)shapefeaturesC(segment),segments,'UniformOutput',false);
toc


xC=cellfun(@(x1,x2)[x1(:);x2(:)].',xC,xC2,'UniformOutput',false);
xS=cellfun(@(x1,x2)[x1(:);x2(:)].',xS,xS2,'UniformOutput',false);

xx=cell2mat([xC, xS]);
end














