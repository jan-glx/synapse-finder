function [ nodeshere ] = nodes2nodesincube( nodes,boundary,overlap )
%NODES2NODESINCUBE Summary of this function goes here
%   Detailed explanation goes here
nNodes=size(nodes,1);
nD=size(nodes,2);
maxCube=floor((boundary-1 )/ 128);
firstCubes=max(floor(( nodes - overlap  - 1) / 128 ),0);firstCubes=num2cell(firstCubes,1);
lastCubes=arrayfun(@(dim)floor(( min(nodes(:,dim) + overlap,boundary(dim))  - 1) / 128 ),1:nD,'UniformOutput',false); 
1;
    function out=linidx(varargin)
        out1=cellfun(@(from,to)from:to,varargin(1:end/2),varargin(end/2+1:end),'UniformOutput',false);
        out=cell(1,nargin/2);
        [out{:}]=ndgrid(out1{:});
        out=cellfun(@flat,out,'UniformOutput',false);
        out=cell2mat(out);
    end
cubesofnodes=arrayfun(@(varargin)linidx(varargin{:}),firstCubes{:},lastCubes{:},'UniformOutput',false);
nodeId=arrayfun(@(i,n)repmat(i,n,1),(1:nNodes).',cellfun(@(x)size(x,1),cubesofnodes),'UniformOutput',false);
cubesofnodes=cell2mat(cubesofnodes);
nodeId=cell2mat(nodeId);
nodeshere=accumarray(cubesofnodes+1,nodeId,maxCube+1,@(x){x},{zeros(0,3)});
nodeshere=cellfun(@(nodehere)nodes(nodehere,:),nodeshere,'UniformOutput',false);
end

