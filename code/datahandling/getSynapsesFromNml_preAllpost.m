function [pre,cleft,id,post, bbox] = getSynapsesFromNml_preAllpost( file,scndonly,fstisbbox )
%GETSYNAPSESFROMNML Summary of this function goes here
%   Detailed explanation goes here
if ~exist('scndonly','var')||isempty(scndonly)
    scndonly=false;
end
if ~exist('fstisbbox','var')||isempty(fstisbbox)
    fstisbbox=true;
end

tracing= NML.fromParsedFile( parseNml( which(file)) );
if fstisbbox
    bboxidxl=1==[tracing.trees.thingID];
    bbox=tracing.trees(bboxidxl);
    tracing.trees=tracing.trees(~bboxidxl);
    bbox=bbox.nodesNumDataAll(:,3:5);
    minpos=min(bbox);
    maxpos=max(bbox);
else
    all=arrayfun(@(tree)tree.nodesNumDataAll(:,3:5),tracing.trees,'Uniformoutput',false).';
    all=cell2mat(all);
    minpos=min(all);
    maxpos=max(all);
end
bbox=[minpos;maxpos];


pre=arrayfun(@(tree)tree.nodesNumDataAll(1,3:5),tracing.trees,'Uniformoutput',false).';
pre=cell2mat(pre);
if scndonly
    cleft=arrayfun(@(tree)tree.nodesNumDataAll(2,3:5),tracing.trees,'Uniformoutput',false).';
else
    cleft=arrayfun(@(tree)tree.nodesNumDataAll(2:end-1,3:5),tracing.trees,'Uniformoutput',false).';
end
cleft=cell2mat(cleft);
id=arrayfun(@(tree,id)repmat(id,size(tree.nodesNumDataAll,1)-2,1),tracing.trees,1:numel(tracing.trees),'Uniformoutput',false).';
id=cell2mat(id);
post=arrayfun(@(tree)tree.nodesNumDataAll(end,3:5),tracing.trees,'Uniformoutput',false).';
post=cell2mat(post);

outofbounds=any(bsxfun(@gt,cleft,maxpos),2)|any(bsxfun(@lt,cleft,minpos),2);
outofbounds=id(outofbounds);
outofbounds=unique(outofbounds);
if (~isempty(outofbounds))
    warning('%u of %u synapses out of bounds',numel(outofbounds),numel(tracing.trees));
end
end

