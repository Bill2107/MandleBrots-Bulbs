clear
clc

SCALE_FACTOR = 10;
TURN_FACTOR = 1;
MAXIMUM = 100;

MAX_RAY_LENGTH = 10;
FOCAL_LENGTH = SCALE_FACTOR*60;
WIDTH = SCALE_FACTOR*100;%1366;%
HEIGHT = SCALE_FACTOR*100;%768;%

F = [1:10000];
zoom = 0;
left = 0;
Ray_Length = gpuArray(zeros(HEIGHT+1,WIDTH+1));
for frame = 1:1000
    zoom = zoom; %+ Ray_Length(500,500)/16;
    VALS = gpuArray(zeros(HEIGHT+1,WIDTH+1));
    left = -1;
    RVALS = gpuArray(zeros(HEIGHT+1,WIDTH+1));
        tic
        Ray_Length = zeros(HEIGHT+1,WIDTH+1);
    for ir = 0:MAXIMUM
        f = F(frame);
        a = -WIDTH/2;
        b =  WIDTH/2;
        c = -HEIGHT/2;
        d =  HEIGHT/2;
        [U,V] = meshgrid(a:b,c:d);
        Ug = gpuArray(U);
        Vg = gpuArray(V);
        r = sqrt(FOCAL_LENGTH^2.*ones(size(U)) + U.*U + V.*V);
        fX = Ug.*(Ray_Length)./r;
        fY = Vg.*(Ray_Length)./r;
        fZ = sqrt(Ray_Length.^2 - fX.^2 + fY.^2);
        clear Ug Vg
        %TRANSLATE ROTATIONAL CENTRE TO OBJECT FROM CAMERA
        fZ = fZ-2.5+zoom;
        fX = fX;
        %ROTATE AROUND ROTATIONAL CENTRE
        R = sqrt(fX.*fX + (fZ.*fZ).*ones(size(fX)));
        t = arrayfun(@atan2, ones(size(fX)).*fZ, fX) + ones(size(fX)).*deg2rad(5/TURN_FACTOR)*f;
        %a = ones(size(t)).*deg2rad(5)*f;
        fZ = sin(t).*R;
        fX = cos(t).*R;
        X1 = fX;
        Y1 = fY;
        Z1 = fZ;
        R1 = R;
        clear t R VAL1 X Y Zg
        dfX = zeros(size(fX));
        dfY = zeros(size(fY));
        dfZ = zeros(size(fZ));
        dr = ones(size(fX));


        n = 8;
        VAL1 = zeros(size(VALS));
        %teration Step
        R = sqrt(fX.*fX + fZ.*fZ + fY.*fY);
        for i = 1:5
            %do iteration
          %  dfX = n.*(fX.^(n-1)).*dfX + 1;
          %  dfY = n.*(fY.^(n-1)).*dfY + 1;
          %  dfZ = n.*(fZ.^(n-1)).*dfZ + 1;
            dr = n*(R.^(n-1)).*dr + ones(size(dr));

            phi = arrayfun(@atan2, fY,fX).*n;
            theta = arrayfun(@atan2, R,fZ).*n;
            Rn=R.^n;
            fX  = X1 + Rn.*sin(theta).*cos(phi);
            fY  = Y1 + Rn.*sin(theta).*sin(phi);
            fZ = Z1 + Rn.*cos(theta);
            
            R  = sqrt(fX.*fX   + fZ.*fZ   + fY.*fY);
            % once the (R-R1) exceeds ~50 stop iterating that element and
            %assign the Value with iteratiion step i.
            %VAL1 = (abs(R-R1) > 10^3).*i.*(VAL1==0) + VAL1.*(VAL1~=0);
            %X = X.*(abs(R-R1) <= 10^3);
            %Y = Y.*(abs(R-R1) <= 10^3);
            %Zg = Zg.*(abs(R-R1) <= 10^3);
            %R(abs(R-R1) > 10^3) = inf;
            if(sum(R<4) == 0)
                break;
            end
        end
        dist = R.*log(R)./dr;
        dist(isnan(dist)) = 2/10;
        dist(dist == inf) = 2/10;
        Ray_Length = Ray_Length + dist/2; 
        if(sum(dist(:)<0)) > 0
            %disp(sprintf("below zero: %d",sum(dist(:)<0)));
        end
        VALS = (VALS == 0).*(abs(dist) < 0.0001).*ir + (VALS~=0).*VALS;

        %once the distance is sufficiently small load the iteration count
        %into vals

        %value is assigned as the most  number of iterations until meme
       % R(R == inf) = 9999;
       % RVALS = ((R<500).*(RVALS==0).*(~isnan(R))).*sqrt(X1.*X1 + Z1.*Z1) + RVALS;
       % VALS = (VAL1>VALS).*VAL1 + (VAL1<=VALS).*VALS;
       if sum(dist(:) ~= 1/10)
           %disp(sprintf("not infinity: %d",sum(dist(:) ~= 1/10)));
       end
        
        %disp(sprintf('%d:%d\n',ir,MAXIMUM));
    end
    %fill in frames that didnt finish
    disp(mean(VALS(:)));
    VALS = VALS + (VALS==0).*(Ray_Length<1.8).*MAXIMUM;
    disp(mean(VALS(:)));

    disp('Frame Complete')%PLOT

  %  IMAGE = ones(HEIGHT, WIDTH,3).*0;
   % [ROW, COLS] = find((VALS<9000).*(VALS~=0));
   % POINTS = [ROW,COLS, VALS(find((VALS<9000).*(VALS~=0)))];
   % a = POINTS(:,3)-min(POINTS(:,3))./(max(POINTS(:,3))-min(POINTS(:,3)));
   % P = VALS-min(VALS(VALS ~= 0)).*ones(size(VALS));
   P = VALS;
  % P = P - min(P);
 %   P = P.*(P>4);
    if max(P(:)) > MAXIMUM
        MAXIMUM = max(P(:))
    end
    P = P./max(P(:));
    A = hsv2rgb(P,(1).*ones(size(P)),1-P);
    A = A.*(P>0);
 %   if(sum(VALS(:)<0) > 0)
 %       a = (VALS - min(a));
  %      a = a/max(a);
   % end
  %  for i = 2:length(POINTS(:,1))
  %      IMAGE(POINTS(i,1), POINTS(i,2), 1:3) = hsv2rgb(mod(a(i),0.1)*10,1,a(i));
  %  end
    imwrite(A, sprintf('frames/test5/GPUtest5_%d.png',f));
    disp(sprintf('FRAME %d of 35',frame));
    toc
end
