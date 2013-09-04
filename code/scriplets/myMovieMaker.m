function myMovieMaker(emRaw,emLab,bbox,pathOut,mBufSiz)
fig=figure;
set(gcf,'NextPlot','replacechildren');
set(gcf,'Renderer','OpenGL');
writerObj = VideoWriter(pathOut);
writerObj.FrameRate = 4;
open(writerObj);
if ~exist('mBufSiz','var')
    mBufSiz=500000;
end
imgSiz=diff(bbox)+1;
mBufSiz=ceil(mBufSiz/prod(imgSiz(1:2)));
pBuf=[bbox(1,3):mBufSiz:bbox(2,3)-1 bbox(2,3)];
nBuf=numel(pBuf)-1;

for iBuf=1:nBuf
    mBufSiz=pBuf(iBuf+1)-pBuf(iBuf);
    x=single(emRaw.readKNOSSOSroi([bbox(:,1:2), [pBuf(iBuf); pBuf(iBuf+1)-1]].', 'uint8' ))/255;
    y=single(emLab.readKNOSSOSroi([bbox(:,1:2), [pBuf(iBuf); pBuf(iBuf+1)-1]].', 'uint8' ))/255;
    for f=1:mBufSiz
        hold off;
        imshow(x(:,:,f));%,  'InitialMagnification', 200
        hold on;
        size2D=size(x);size2D=size2D(1:2);
        temp = cat(3,(y(:,:,f)),zeros(size2D),zeros(size2D));
        himage = imshow(temp);%, 'InitialMagnification', 200
        set(himage, 'AlphaData', 0.3 );
        frame = getframe;
        writeVideo(writerObj,frame);
    end
end
close(writerObj);
close(fig);