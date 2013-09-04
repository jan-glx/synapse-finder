function [ wallidxi,uneighboursID] = getContactIdxi( segments,walls )
% GETCONTACTIDX finds all contact voxels that have exactly two neighboring
% segments and returns them together with the IDs of those segments.
cubesize = size(segments);
nD = stufe(segments); %like ndmis(segments), but returns 1 for n by 1 arrays and 0 for empty arrays, see http://abandonmatlab.wordpress.com/ for further information
 
fprintf('finding contacts & neighbouring cell IDs...\n');tic;
 
% clear all to close to border pixel
walls(1,:,:) = false;
walls(end,:,:) = false;
walls(:,1,:) = false;
walls(:,end,:) = false;
walls(:,:,1) = false;
walls(:,:,end) = false;
wallidxi = find(walls);
 
% generate indexshifters for 26 neighborhood
[x,y,z] = meshgrid([-1 0 1], [-1 0 1]*cubesize(1), [-1 0 1]*prod(cubesize(1:end-1)));
n26 = x+y+z;
n26 = n26([1:13, 15:end]);
 
neighboursidxi = bsxfun(@plus,wallidxi,n26); % calculate indices of neighbouring voxels for all wall voxels
neighboursID = sort(segments(neighboursidxi), 2); % sort neighboring  segments IDs for all wall wall voxels
uneighbours = [true(size(neighboursID,1),1), 0<diff(neighboursID,1,2)]; % and find the unique neighboring segments IDs for all wall voxels
leftout = sum(uneighbours,2) ~= 3; % find junctions (<10% )
wallidxi = wallidxi(~leftout);% forget junctions (<10% )
uneighbours = uneighbours(~leftout,:);
neighboursID = neighboursID(~leftout,:).';
uneighboursID = reshape(neighboursID(uneighbours.'), nD, []).';
 
uneighboursID = uneighboursID(:,2:3);% forget wall id
toc
end
 


