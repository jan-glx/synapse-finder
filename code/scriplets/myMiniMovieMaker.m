function myMiniMovieMaker(x,y,pathOut,alpha)
fig=figure;
set(gcf,'NextPlot','replacechildren');
set(gcf,'Renderer','OpenGL');
writerObj = VideoWriter(pathOut);
writerObj.FrameRate = 10;
open(writerObj);
scrsz = get(0,'ScreenSize');

for f=1:size(x,3)
    hold off;
    imshow(x(:,:,f),'InitialMagnification', 200);%,  'InitialMagnification', 200
    hold on;
    size2D=size(x);size2D=size2D(1:2);
    temp = cat(3,(y(:,:,f)),zeros(size2D),zeros(size2D));
    himage = imshow(temp,'InitialMagnification', 200);%, 'InitialMagnification', 200
    set(himage, 'AlphaData', alpha );
    set(fig,'Position',scrsz);
    frame = getframe;
    writeVideo(writerObj,frame);
end
close(writerObj);
close(fig);