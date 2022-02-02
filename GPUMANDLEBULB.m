clear
clc

SCALE_FACTOR = 10;


MAX_RAY_LENGTH = 10;
FOCAL_LENGTH = SCALE_FACTOR*60;
WIDTH = 1366;%SCALE_FACTOR*100;%
HEIGHT = 768;%SCALE_FACTOR*100;%

F = [0:18-1];
MAXIMUM = 50;
for frame = 1:length(F)
    VALS = gpuArray(zeros(HEIGHT+1,WIDTH+1));
    RVALS = gpuArray(zeros(HEIGHT+1,WIDTH+1));
        tic
        Ray_Length = zeros(768,1366);
    for ir = 0:50
        f = F(frame);
        a = -WIDTH/2;
        b =  WIDTH/2;
        c = -HEIGHT/2;
        d =  HEIGHT/2;
        [U,V] = meshgrid(a:b,c:d);
        Ug = gpuArray(U);
        Vg = gpuArray(V);
        r = sqrt(FOCAL_LENGTH^2.*ones(size(U)) + U.*U + V.*V);
        X = Ug.*(Ray_Length)./r;
        Y = Vg.*(Ray_Length)./r;
        Z = sqrt(Ray_Length.^2 - X.^2 + Y.^2);
        clear Ug Vg
        %TRANSLATE ROTATIONAL CENTRE TO OBJECT FROM CAMERA
        fZ = Z-2.5;
        %ROTATE AROUND ROTATIONAL CENTRE
        R = sqrt(X.*X + (Z*Z).*ones(size(X)));
        t = arrayfun(@atan2, ones(size(X)).*Z, X) + ones(size(X)).*deg2rad(5)*f;
        %a = ones(size(t)).*deg2rad(5)*f;
        fZ = sin(t).*R;
        fX = cos(t).*R;
        X1 = X;
        Y1 = Y;
        Z1 = Zg;
        R1 = R;
        clear t R VAL1 X Y Zg
        dfX = ones(size(fX));
        dfY = ones(size(fY));
        dfZ = ones(size(fZ));
        dr = zeros(size(fX));


        n = 3;
        VAL1 = zeros(size(VALS));
        %teration Step
        R = sqrt(X.*X + Zg.*Zg + Y.*Y);
        for i = 1:100
            %do iteration
            dfX = n.*(f.^(n-1)).*dfX + 1;
            dfY = n.*(f.^(n-1)).*dfY + 1;
            dfZ = n.*(f.^(n-1)).*dfZ + 1;

            phi = arrayfun(@atan2, fY,fX).*n;
            theta = arrayfun(@atan2, R,fZ).*n;
            Rn=R.^n;
            fX  = X1 + Rn.*sin(theta).*cos(phi);
            fY  = Y1 + Rn.*sin(theta).*sin(phi);
            fZ = Z1 + Rn.*cos(theta);
            
            dr = sqrt(dfX.*dfX + dfZ.*dfZ + dfY.*dfY);
            R  = sqrt(fX.*fX   + fZ.*fZ   + fY.*fY);
            % once the (R-R1) exceeds ~50 stop iterating that element and
            %assign the Value with iteratiion step i.
            %VAL1 = (abs(R-R1) > 10^3).*i.*(VAL1==0) + VAL1.*(VAL1~=0);
            %X = X.*(abs(R-R1) <= 10^3);
            %Y = Y.*(abs(R-R1) <= 10^3);
            %Zg = Zg.*(abs(R-R1) <= 10^3);
            %R(abs(R-R1) > 10^3) = inf;
            if(sum(R~=inf) == 0)
                break;
            end
        end
        dist = R.*log(R)./df;
        Ray_Length = Ray_Length + dist/2; 

        VALS = (VALS == 0).*(dist < 0.01).*i + (VALS~=0).*VALS;

        %once the distance is sufficiently small load the iteration count
        %into vals

        %value is assigned as the most  number of iterations until meme
       % R(R == inf) = 9999;
       % RVALS = ((R<500).*(RVALS==0).*(~isnan(R))).*sqrt(X1.*X1 + Z1.*Z1) + RVALS;
       % VALS = (VAL1>VALS).*VAL1 + (VAL1<=VALS).*VALS;

        
      %  disp(sprintf('%d:%d\n',(Z+2.5)*100, 4*100));
    end
    disp('Frame Complete')%PLOT

  %  IMAGE = ones(HEIGHT, WIDTH,3).*0;
   % [ROW, COLS] = find((VALS<9000).*(VALS~=0));
   % POINTS = [ROW,COLS, VALS(find((VALS<9000).*(VALS~=0)))];
   % a = POINTS(:,3)-min(POINTS(:,3))./(max(POINTS(:,3))-min(POINTS(:,3)));
    P = VALS-min(VALS(VALS ~= 0)).*ones(size(VALS));
    P = P.*(P>4);
    if max(P(:)) > MAXIMUM
        MAXIMUM = max(P(:))
    end
    P = P./MAXIMUM;
    A = hsv2rgb(P,1.*ones(size(P)),P);
    A = A.*(P>0);
 %   if(sum(VALS(:)<0) > 0)
 %       a = (VALS - min(a));
  %      a = a/max(a);
   % end
  %  for i = 2:length(POINTS(:,1))
  %      IMAGE(POINTS(i,1), POINTS(i,2), 1:3) = hsv2rgb(mod(a(i),0.1)*10,1,a(i));
  %  end
    imwrite(A, sprintf('frames/test2/GPUtest2_%d.png',f));
    disp(sprintf('FRAME %d of 35',frame));
    toc
end
