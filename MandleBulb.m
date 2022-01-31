clear
clc
clf

x = linspace(-1,1,50);
y = linspace(-1,1,50);
z = linspace(-1,1,50);

[X, Y, Z] = meshgrid(x,y,z);
figure(1)
hold on
for ix = 1:length(x)
    disp(ix*2);
for iy = 1:length(y)
for iz = 1:length(z)
    C = [x(ix); y(iy); z(iz)];
    v = [0;0;0];
    for i = 1:100  
     if(v'*v > 3)
         v = inf.*[1;1;1];
         break;
     end
     v = iterate(v, 9, C);
    end
    Z(ix,iy,iz) = norm(v,2);
    if(Z(ix,iy,iz) < 1 && Z(ix,iy,iz)>0.5 )
        plot3(x(ix),y(iy),z(iz), '.');
    end
end
end
end
xlim([-2,2])
ylim([-2,2])
zlim([-2,2])
disp('done');
%%plot3(X,Y,Z);

function V = iterate(v,n,c)
    R = norm(v,2);
    phi = atan2(v(2),v(1));
    theta = atan2(R,v(3));
    P = phi*n;
    T = theta*n;

    T = [sin(T)*cos(P);sin(T)*sin(P);cos(T)];

    V = (R^n).*T + c;
end