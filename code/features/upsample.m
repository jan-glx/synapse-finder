function [ output ] = upsample(input,outS)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
inS=size(input);
idx=arrayfun(@(inS)(0:inS-1)/(inS-1),inS,'UniformOutput', false);
    % create normalised plaid grids of current discretisation
		mat=cell(1,ndims(input));
    [mat{:}] = ndgrid(idx{:});       

    % create plaid grids of desired discretisation
		idx=arrayfun(@(outS)(0:outS-1)/(outS-1),outS,'UniformOutput', false);
		mat_interp=cell(1,ndims(input));
    [mat_interp{:}]= ndgrid(idx{:});

    % compute interpolation; for a matrix indexed as [M, N, P], the
    % axis variables must be given in the order N, M, P
    output = interpn(mat{:}, input, mat_interp{:}, 'spline');        
end

