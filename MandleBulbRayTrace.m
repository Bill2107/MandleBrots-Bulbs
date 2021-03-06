clear
clc

SCALE_FACTOR = 10;


MAX_RAY_LENGTH = 10;
FOCAL_LENGTH = SCALE_FACTOR*60;
WIDTH = SCALE_FACTOR*100;
HEIGHT = SCALE_FACTOR*100;

POINTS = [1,1,1];
CAMERAPOS = [0;0;-2];
t = deg2rad(10);

Rx = [1 0 0; 0 cos(t) -sin(t); 0 sin(t) cos(t)];
Ry = [cos(t) 0 sin(t); 0 1 0; -sin(t) 0 cos(t)];
Rz = [cos(t) -sin(t) 0; sin(t) cos(t) 0; 0 0 1];

F = [0:18*2-1];
parfor frame = 1:length(F)
    tic
    f = F(frame);
    POINTS = [1,1,1];
    disp(sprintf("%d / 18\n", f));
    for ix = 1:WIDTH
        disp(sprintf("%d: %d %%",f, 100*ix/WIDTH));
    for iy = 1:HEIGHT
        U = ix - WIDTH/2;
        V = iy - WIDTH/2;
        for Z = 0:0.01:2
            X = Z*U/FOCAL_LENGTH;
            Y = Z*V/FOCAL_LENGTH;
            %TRANSLATE ROTATIONAL CENTRE TO OBJECT FROM CAMERA
            C = [X;Y;Z]+ CAMERAPOS;
            %ROTATE AROUND ROTATIONAL CENTRE
            R = norm([C(1),C(3)],2);
            t = atan2(C(3),C(1));
            a = deg2rad(5)*f;
            C(3) = sin(t+a)*R;
            C(1) = cos(t+a)*R;
            v = C;
            for i = 1:50  
                v = iterate(v, 3, C);
                if(v'*v > 10^40)
                    break;
                end
            end
            if(v'*v<10^40)
                POINTS = [POINTS;[ix,iy, R]];
                break;
            end
        end
    end
    end
    %PLOT
    IMAGE = ones(HEIGHT, WIDTH,3).*0;
    for i = 2:length(POINTS(:,1))
        a = POINTS(i,3)./max(POINTS(:,3));
        IMAGE(POINTS(i,2), POINTS(i,1), 1:3) = hsv2rgb(mod(a,0.1)*10,1,a);
    end
    
    imwrite(IMAGE, sprintf('frames/test%d.png',f));
    toc
end
movieMaker;

function V = iterate(v,n,c)
    R = norm(v,2);
    phi = atan2(v(2),v(1));
    theta = atan2(R,v(3));
    P = phi*n;
    T = theta*n;

    T = [sin(T)*cos(P);sin(T)*sin(P);cos(T)];

    V = (R^n).*T + c;
end