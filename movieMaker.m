v = VideoWriter('MB_GPU', 'MPEG-4');
open(v);
for i = 1:8
    for a = 0:35
        frame = imread(sprintf('frames/GPUtest%d.png',a));
        writeVideo(v, frame);
        writeVideo(v, frame);
    end
end
close(v);