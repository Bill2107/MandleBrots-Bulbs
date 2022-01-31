load("POINTS_BIG.mat");
IMAGE = ones(HEIGHT, WIDTH,3).*0;
for i = 2:length(POINTS(:,1))
    a = POINTS(i,3)./max(POINTS(:,3));
    IMAGE(POINTS(i,2), POINTS(i,1), 1:3) = hsv2rgb(mod(a,0.1)*10,1,a);
end

imwrite(IMAGE, 'test.png')