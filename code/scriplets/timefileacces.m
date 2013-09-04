
siz=[1 1 1];

n=1000;
pos=1000+randi(1,n,3);

filename='F:\datasets\2012-09-28_ex145_07x2.h5';
datasetpath=sprintf('/raw/mag%i',em.magnification);

fprintf('hdf5:');tic;
for i=1:n
    b=h5read(filename,datasetpath,pos(i,:),siz);
end
toc



fprintf('KNOSSOS:');tic;
for i=1:n
    bbox=[pos(i,:) ;pos(i,:)+siz-1].';
    a=em.readKNOSSOSroi(bbox);
end
toc