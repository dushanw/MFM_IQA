% 20201010 by Dushan N. Wadduwage
% Explore and compare Image Quality Assessment methods

addpath(genpath('./_functions/'))

%% Simulated object
Nx        = 128;
Ny        = 128;
Nz        = 128;
rot_angle = 10;

X0 = f_genobj_minist3D(Ny,Nx,Nz);
% volshow(X0,'Renderer','MaximumIntensityProjection');

%% PSF
load PSF_3D_7.500000e-01NA_1RI_2.000000e-01umdx.mat
% volshow(PSF_3D,'Renderer','MaximumIntensityProjection');

%% Simulated images

X0_rot  = imrotate3(X0,rot_angle,[1 0 0],'crop');
%imagesc(squeeze(sum([X0 X0_rot X1],3)));axis image;colorbar

Y0      = convn(X0    ,PSF_3D,'same');
Y0_rot  = convn(X0_rot,PSF_3D,'same');
Y0_aRot = imrotate3(Y0_rot,-rot_angle,[1 0 0],'crop');

%imagesc(squeeze(sum([rescale(X0) rescale(Y0)],3)));axis image;colorbar
%imagesc(squeeze([rescale(X0(:,:,64)) rescale(Y0(:,:,64)) rescale(Y0_aRot(:,:,64))]));axis image;colorbar

figure;
subplot(1,3,1);imagesc(squeeze(Y0(:,:,64)));axis image;colorbar
subplot(1,3,2);imagesc(squeeze(Y0_aRot(:,:,64)));axis image;colorbar
subplot(1,3,3);imagesc(squeeze(Y0(:,:,64) - Y0_aRot(:,:,64)));axis image;colorbar

%% Traditional metrics: SSIM, PSNR
% <now read more on the ssim and psnr>
[ssimval,ssimmap] = ssim(Y0(:,:,64),Y0_aRot(:,:,64));
imagesc(ssimmap)
[peaksnr,snr] = psnr(Y0,Y0_aRot);

%% Feature matching matric: FSIM - Feature Similarity Index Measure
fsimval = f_fsim(Y0(:,:,64),Y0_aRot(:,:,64));

