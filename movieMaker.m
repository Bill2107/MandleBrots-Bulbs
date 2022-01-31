v = VideoWriter('MB2', 'MPEG-4');
open(v);
for a = 0:18
    frame = imread(sprintf('frames/test%d.png',a));
    writeVideo(v, frame);
    writeVideo(v, frame);
end
close(v);