v = VideoWriter('MB_GPU_5', 'MPEG-4');
open(v);
for i = 1:2
    for a = 1:72
        frame = imread(sprintf('frames/test5/GPUtest5_%d.png',a));
        writeVideo(v, frame);
        writeVideo(v, frame);
    end
end
close(v);