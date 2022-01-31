clear
clc

MAX_ITERATIONS = 100;

%set up parralel variables
    A = [2.47; 2.24]; B = [-2.00; -1.12];
    C = [-0.765; 0]; R = [1.235; 1.12]*2.78951;
    %R = R./80
    C = [-2.2; -0.37]; R = R./2;
delete(gcp('nocreate'));
parpool('local',4);
for frame = 1:1
    tic
    zL = [2.47,2.24];
    XDIM = 1366*2;
    YDIM = 768*2;
    if(~(frame==1))
        C = [-0.761574; -0.0847596];
        R = R*0.95;
        %S = 10^{-0.2*(frame-1)}
       % B = 0.2.*B;
        %A =  2.*(C-B);
    end
    for l = 1:100
        P(l,:) = [0,(l-1)*(YDIM/100)];
    end
    iterationCount(1:100) = {meshgrid(1:XDIM, 1:YDIM/100).*0};
    %disp('got here!!');
    %start paralellisation
    parfor i = 1:100
    %    iterationCount(1:(XDIM/100) + 1,1:(YDIM) + 1);
        for y = 0:YDIM/100
        for x = 0:XDIM
            %disp(sprintf('%f', (x/XDIM)*100 + (y/YDIM) ));
            % check if within the bulb
            Q = P(i, :)' + [x;y];
            %q = P'*P;
            %if ~(q*(1+(x-0.25)) > 0.25*y^2)
                iterationCount{i}(y+1, x+1) = itCheck(Q,R,C)*2;
            %end
        end
        end
     %   disp(i);
        %if a thing of 10 along the way
        %if(~mod(x,(XDIM/10))) %hold on
     %   imwrite(imageFile, sprintf('pics/mandleBrot%d.bmp',i));
        %disp("Writing!");
        %end
    end
    
    
    %stitch the sections together
    %I = imread("pics/mandleBrot1.bmp");
    I = iterationCount{1};
    for i = 2:100
        I = [I; iterationCount{i}];
        %I = [I; imread(sprintf('pics/mandleBrot%d.bmp',i))];
    end

    Im = ind2rgb(I-(min(I(:)).*ones(size(I))), lines);
    I = edge(I,'sobel');
    EIm = ind2rgb(I.*10, jet);

    [M,L] = max(I(:));
    [I_row, I_col] = ind2sub(size(I),L);

  %  EIm = insertShape(EIm, 'circle', [I_col, I_row, 20], 'LineWidth', 5 ); 
  %  Im = insertText(Im, [10, 100], sprintf('scale: [%d, %d]', B(1), B(2)),'TextColor','green');

    imwrite(Im, sprintf('frames/mandleBrotFrame%d.bmp',frame));
   % imwrite(EIm, sprintf('EdgeFrames/mandleBrotFrame%d.bmp',frame));
    disp('done!');
    disp(sprintf('frame %d out of 24 complete',frame));
    toc
    clear EIm Im iterationCount
    
end

%itCMax = max(max(iterationCount));
%figure(1);

%for x = 0:XDIM
%for y = 0:YDIM
%    plot(x,y, '.','Color',hsv2rgb([1,1,iterationCount(x+1,y+1)./itCMax]));
%end
%end
function it = itCheck(D, R, C) 
    XDIM = 1000;
    YDIM = 1000;
    MAX_ITERATIONS = 500;
    %D = D.*A./[XDIM; YDIM] + B;
    D = (D./[XDIM;YDIM]-1/2*[1;1]).*R+C;
    ix = 0;
    xtemp = 0;
    Q = [0;0];
    while(~(Q'*Q > 4) && ix < MAX_ITERATIONS)
        xtemp = (Q')*(Q.*[1;-1]) + D(1);
        Q(2) = 2*Q(1)*Q(2) + D(2);
        Q(1) = xtemp;
        ix = ix +1;
    end 
    it = ix;
    if(ix > 2)
    %disp(ix);
    end
end