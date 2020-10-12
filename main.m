% 20201010 by Dushan N. Wadduwage
% Explore and compare Image Quality Assessment methods

addpath(genpath('./_functions/'))

%% Simulated object
Nx = 128;
Ny = 128;
Nz = 128;

X0 = f_genobj_minist3D(Ny,Nx,Nz);
% volshow(X0);

%% Simulated images
load PSF_3D_1NA_1RI_2.000000e-01umdx.mat
% volshow(PSF_3D);

%% Traditional metrics: SSIM, PSNR
[ssimval,ssimmap] = ssim(A,ref);
peaksnr = psnr(A,ref);