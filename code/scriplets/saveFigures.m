outPath=fullfile(savePath,[em.dataName '_features']);
allfile=fullfile(outPath,'all.csv');
dd=csv2cell(allfile,'fromfile');
for i=1:size(dd,1)
    em3=emData.readKNOSSOSconf(fullfile(outPath,sprintf('feature%03u',i)),'knossos.conf',dd{i,4});
    em3.dim=str2double(dd{i,3});
    block=em3.readRoi([1000 1300;1000 1300;1000 1000]);
    for j=1:prod(em3.dim)
	imwrite(scaler(block(:,:,:,j)),sprintf('feature%03u-%3u.png',i,j));
    end
end

