clear
clc

SCALE_FACTOR = 10;


MAX_RAY_LENGTH = 10;
FOCAL_LENGTH = SCALE_FACTOR*60;
WIDTH = 1366;%SCALE_FACTOR*100;
HEIGHT = 768;%SCALE_FACTOR*100;

F = [0:18*2-1];
MAXIMUM = 1;
for frame = 1:length(F)
    VALS = gpuArray(zeros(HEIGHT+1,WIDTH+1));
        tic
    for Z = 0:0.01:4
        f = F(frame);
        a = -WIDTH/2;
        b =  WIDTH/2;
        c = -HEIGHT/2;
        d =  HEIGHT/2;
        [U,V] = meshgrid(a:b,c:d);
        Ug = gpuArray(U);
        Vg = gpuArray(V);
    
        X = Ug.*Z./FOCAL_LENGTH;
        Y = Vg.*Z./FOCAL_LENGTH;
        clear Ug Vg
        %TRANSLATE ROTATIONAL CENTRE TO OBJECT FROM CAMERA
        Z = Z-2.5;
        %ROTATE AROUND ROTATIONAL CENTRE
        R = sqrt(X.*X + (Z*Z).*ones(size(X)));
        t = arrayfun(@atan2, ones(size(X)).*Z, X) + ones(size(X)).*deg2rad(5)*f;
        %a = ones(size(t)).*deg2rad(5)*f;
        Zg = sin(t).*R;
        X = cos(t).*R;
        X1 = X;
        Y1 = Y;
        Z1 = Zg;
        clear t R
        n = 3;
        %teration Step
        for i = 1:50
            R = sqrt(X.*X + Zg.*Zg + Y.*Y);
            phi = arrayfun(@atan2, Y,X).*n;
            theta = arrayfun(@atan2, R,Zg).*n;
            R=R.^n;
            X  = X1 + R.*sin(theta).*cos(phi);
            Y  = Y1 + R.*sin(theta).*sin(phi);
            Zg = Z1 + R.*cos(theta);
        end
      %  R = sqrt(X1.*X1 + (Z1.*Z1).*ones(size(X1)) + Y1.*Y1);
        %Zg = X + Y + Zg;
        %stop NAN errors
        %Zg(isnan(Zg)) = 9999;
        %Zg(Zg == inf) = 9999;
        %R(isnan(R)) = 9999;
        R(R == inf) = 9999;
        %a = R./max(max(R(R(:)~=9999)));
        %hsv = [];
        VALS = ((R<500).*(VALS==0).*(~isnan(R))).*sqrt(X1.*X1 + Z1.*Z1) + VALS;
        
        %disp(sprintf('%d:200\n',(Z+2)*100));
    end
    disp('Frame Complete')%PLOT

  %  IMAGE = ones(HEIGHT, WIDTH,3).*0;
   % [ROW, COLS] = find((VALS<9000).*(VALS~=0));
   % POINTS = [ROW,COLS, VALS(find((VALS<9000).*(VALS~=0)))];
   % a = POINTS(:,3)-min(POINTS(:,3))./(max(POINTS(:,3))-min(POINTS(:,3)));
    P = VALS;%-min(VALS(VALS ~= 0)).*ones(size(VALS));
    P = P.*(P>0);
    if max(P(:)) > MAXIMUM
        MAXIMUM = max(P(:))
    end
    P = P./MAXIMUM;
    A = hsv2rgb(mod(P,0.1)*10,1.*ones(size(P)),P);
    A = A.*(P>0);
 %   if(sum(VALS(:)<0) > 0)
 %       a = (VALS - min(a));
  %      a = a/max(a);
   % end
  %  for i = 2:length(POINTS(:,1))
  %      IMAGE(POINTS(i,1), POINTS(i,2), 1:3) = hsv2rgb(mod(a(i),0.1)*10,1,a(i));
  %  end
    imwrite(A, sprintf('frames/GPUtest%d.png',f));
    disp(sprintf('FRAME %d of 35',frame));
    toc
end