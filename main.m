% 20201010 by Dushan N. Wadduwage
% Explore and compare Image Quality Assessment methods

clear all;close all;clc;
addpath(genpath('./_functions/'))
addpath('./__toolboxes/vlfeat-0.9.21')

%% Simulated object
Nx        = 128;
Ny        = 128;
Nz        = 128;
rot_angle = 10;

%X0 = f_genobj_minist3D(Ny,Nx,Nz);
X0 = f_genobj_spines3D(Ny,Nx,Nz);
X0 = X0(:,:,60:90);

% volshow(X0,'Renderer','MaximumIntensityProjection');

%% PSF
load PSF_3D_7.500000e-01NA_1RI_2.000000e-01umdx.mat
PSF_3D = single(PSF_3D);
% volshow(PSF_3D,'Renderer','MaximumIntensityProjection');

%% Simulated images
X0_rot  = imrotate3(X0,rot_angle,[1 0 0],'crop');
%imagesc(squeeze(sum([X0 X0_rot X0-X0_rot],3)));axis image;colorbar

Y0      = convn(X0    ,PSF_3D,'same');
Y0_rot  = convn(X0_rot,PSF_3D,'same');
Y0_aRot = imrotate3(Y0_rot,-rot_angle,[1 0 0],'crop');

%imagesc(squeeze(sum([rescale(X0) rescale(Y0)],3)));axis image;colorbar
%imagesc(squeeze([rescale(X0(:,:,15)) rescale(Y0(:,:,15)) rescale(Y0_aRot(:,:,15))]));axis image;colorbar

figure;
subplot(1,3,1);imagesc(squeeze(Y0(:,:,15)));axis image;colorbar
subplot(1,3,2);imagesc(squeeze(Y0_aRot(:,:,15)));axis image;colorbar
subplot(1,3,3);imagesc(squeeze(Y0(:,:,15) - Y0_aRot(:,:,15)));axis image;colorbar

%% Traditional metrics: SSIM, PSNR
% <now read more on the ssim and psnr>
[ssimval,ssimmap] = ssim(Y0(:,:,15),Y0_aRot(:,:,15));
[peaksnr,snr] = psnr(Y0,Y0_aRot);

%% Feature matching matric: FSIM - Feature Similarity Index Measure
fsimval = f_fsim(Y0(:,:,15),Y0_aRot(:,:,15));
fsimval = f_fsim(X0(:,:,15),X0_rot(:,:,15));

