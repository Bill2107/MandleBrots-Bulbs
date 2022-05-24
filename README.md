# MandleBrots-Bulbs
Matlab Scripts to Solve Plot and Film Fractals
## Goal
The Goal of this project was to test various different hardware acceleration techniques for the 'embarrassingly parallel'
problem of generating projections of a 3D object (a MandleBulb/MandleBrot set) using Ray Marching techniques and Camera Matricies.

## Results
I found that by loading large matricies the size of the image (~1000x1000) into the gpu and by applying the various recursion and ray marching operations element wise,
I could achieve a computation time of 0.1s/frame, this was a huge improvement on the non accelerated problem which could take 10s per frame. Using this accelerated algorithm
I was able to create animation of the 'camera' rotating and zooming into a mandlebulb quickly.

## Images
Below is a gif of one of the mandlebulbs I was able to generate spinning as the camera rotates around it.


![Alt Text](https://github.com/Bill2107/MandleBrots-Bulbs/blob/main/MB_GPU_5_AdobeCreativeCloudExpress.gif)


(I used the Adobe mp4 to gif tool to convert this from the mp4 that I initially generated)
