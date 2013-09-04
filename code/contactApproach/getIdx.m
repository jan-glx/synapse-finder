function [rlswallidxi, subsegidxis] = getIdx(segments, walls, em, rinclude)
% GETIDX Generates lists of indices of voxels from the contact surfaces and close pre and postsynaptic parts give a segmentation
% 
% INPUT segments: Image in which all segments have an unique integer ID counting 
%                from 1 to n, where n is the number of contacts, and all
%                contact surfaces have the value 0;
%      walls: Binary image of the same size as segments, in which the
%             contacts for which indices should be compute are marked 
%      em: EMData class object used to convert voxel indices to
%          coordinates in nm
%      rinclude: maximum distance in nm a voxel can have to be included in
%                the pre and post synaptic segment parts
% 
% OUTPUT rlswallidxi: Cell array of size n by 1, where n is the number of contacts. Each element is m_i by 1 array in which each element represents a linear index of a voxel of contact i
%       subsegidxis: (opt) some optional input parameter. Default: []
% 
% REMARKS 
% 
% SEE ALSO getContactIdxi, bwlabeln
% 
% created with MATLAB 8.1.0.604 (R2013a)
% 
% created by: Jan Gleixner (jan.gleixner@gmail.com)
% DATE: 28-Aug-2013
% (?) Free to be used and modified by everyone for every purpose. No warranties.
cubesize = size(segments); 
 
[ wallidxi, uneighboursID] = getContactIdxi(segments, walls); 
if isempty(wallidxi)
    rlswallidxi = cell(0,1); 
    subsegidxis = cell(0,1); 
    fprintf('cube empty'); 
    return; 
end
 
% generate list of wall indxi of contacts
% first: sorting all wall indxi from contacts according to cell 1 and split
left = uneighboursID(:,3); % forget wall id
right = uneighboursID(:,2); % forget wall id
[sleft, left2sleft] = sort(left); % should be bucket sort
usleftidxl = [true; diff(sleft)>0]; % first of occurrences of unique ids
usleft = sleft(usleftidxl); % get unique ids
usleftidxi = find(usleftidxl); % idxi of first of occurrences of unique ids
lswallidxi = wallidxi(left2sleft); % sort wallvoxelidxi in the same way as left
lswallidxi = mat2cell(lswallidxi, diff([usleftidxi; numel(usleftidxl)+1]), 1); % and separate
lsright = right(left2sleft); % sort rightids in the same way as left
lsright = mat2cell(lsright, diff([usleftidxi; numel(usleftidxl)+1]), 1); % and separate
 
% second: sorting all wall idxi from all contacts of each cell 1
% according to cell 2 and split
[sright, right2sright] = cellfunn(2, @(lsright)sort(lsright), lsright); 
usrightidxl = cellfun(@(sright)[true; diff(sright)>0], sright, 'UniformOutput', false); % first of occurrences of unique ids
usright = cellfun(@(sright, usrightidxl)sright(usrightidxl), sright, usrightidxl, 'UniformOutput', false); % get unique ids
usrightidxi = cellfun(@(usrightidxl)find(usrightidxl), usrightidxl, 'UniformOutput', false); % idxi of first of occurrences of unique ids
rlswallidxi = cellfun(@(lswallidxi, right2sright)lswallidxi(right2sright), lswallidxi, right2sright, 'UniformOutput', false); % sort wallvoxelidxi in the same way as right
rlswallidxi = cellfun(@(rlswallidxi, usrightidxi, usrightidxl)mat2cell(rlswallidxi, diff([usrightidxi; numel(usrightidxl)+1]), 1), rlswallidxi, usrightidxi, usrightidxl, 'UniformOutput', false); % and separate
rlswallidxi = cellocells2cell(rlswallidxi, 1); % flatten cell array
leftright = arrayfun(@(i)[repmat(usleft(i), size(usright{i})), usright{i}], 1:numel(usright), 'UniformOutput', false); 
leftright = cat(1, leftright{:}); 
nContacts = size(leftright,1); 
 
 
% find used segment idxs
[segidxis, segID2segidxi] = bucketsort(segments(:)+1); 
segidxis = segidxis(2:end); segID2segidxi = segID2segidxi(2:end)-1; % remove wall segment
unused = true(size(segidxis)); unused(leftright(:)) = false; % f ind unused segments
sub2idxis = cumsum(~unused); 
sub2idxis(unused) = nan; 
segID2segidxi(~isnan(segID2segidxi)) = sub2idxis(segID2segidxi(~isnan(segID2segidxi))); 
segidxis = segidxis(~unused); % remove unused segments
toc
 
fprintf('restricting segment idxi to parts close to contact...\n'); tic; 
% genereate list of idxi for sub segments close to contacts for all contacts
subsegidxis = cell(nContacts, 2); 
for iContact = 1:nContacts
    wallidxnm = em.idx2nm(ind2suba(cubesize, rlswallidxi{iContact})); % translate locations to nm to overcome anisotropie
    roughframe = [min(wallidxnm,[],1)-rinclude; max(wallidxnm,[],1)+rinclude]; % every location out of this from cannot be within rinclude to any contact voxel
    for iCell = 1:2
        segidxi = segidxis{segID2segidxi(leftright(iContact,iCell))}; 
        segidxnm = em.idx2nm(ind2suba(cubesize, segidxi)); % translate locations to nm to overcome anisotropie
        sortedout = any(bsxfun(@lt, segidxnm, roughframe(1,:)), 2)|any(bsxfun(@gt, segidxnm, roughframe(2,:)), 2); 
        segidxi = segidxi(~sortedout); % forget locations not within the rough frame
        segidxnm = segidxnm(~sortedout,:); % forget locations not within the rough frame
        [~, dist] = knnsearch(wallidxnm, segidxnm); 
        subsegidxis{iContact,iCell} = segidxi((dist <= rinclude)); % forget remaining locations not in range
        % this distance criterion should be used for early stopping in the
        % knnsearch but is unfortunately not implemented
    end
end
toc
end
 


