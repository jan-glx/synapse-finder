function [ xx,yy,meanL,meanR,meanC] = processCubes(cubesCoords, nodeIdxs,synIdxs,segPath,segName,em,fm,res,rinclude )
%PROCESSCUBES Summary of this function goes here
%   Detailed explanation goes here
nCubes=numel(cubesCoords);
xx=cell(nCubes,1);
yy=cell(nCubes,1);
meanL=cell(nCubes,1);
meanR=cell(nCubes,1);
meanC=cell(nCubes,1);
for iCube=1:nCubes
    [ xx{iCube},yy{iCube},meanL{iCube},meanR{iCube},meanC{iCube}] = processCube(cubesCoords{iCube}, nodeIdxs{iCube}, synIdxs{iCube},segPath,segName,em,fm,res,rinclude  );
end
end

