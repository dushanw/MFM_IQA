% 20201010 by Dushan N. Wadduwage
% Explore and compare Image Quality Assessment methods

clear all;close all;clc;
addpath(genpath('./_functions/'))
addpath('./__toolboxes/vlfeat-0.9.21')

%% Test IQAs (SSIM, PSNR, FSIM) in simulated rotations 
Nx        = 128;
Ny        = 128;
Nz        = 128;
rot_angle = 5;

X0 = f_genobj_minist3D(Ny,Nx,Nz);                                     % object: {minsteD,cell3d,beads3D,spines3D}
% volshow(X0,'Renderer','MaximumIntensityProjection');

load PSF_3D_1NA_1RI_2.000000e-01umdx.mat                              % PSF
PSF_3D = single(PSF_3D);
PSF_3D = PSF_3D.^2;                                                   % for 2p-excitation
PSF_3D = PSF_3D./sum(PSF_3D(:));

imagesc(squeeze(PSF_3D(size(PSF_3D,1)/2,:,:)));axis image
% volshow(PSF_3D,'Renderer','MaximumIntensityProjection');

X0_rot  = imrotate3(X0,rot_angle,[1 0 0],'crop');                     % rotate X0

Y0      = convn(X0    ,PSF_3D,'same');                                % image using the 3d psf
Y0_rot  = convn(X0_rot,PSF_3D,'same');
Y0_aRot = imrotate3(Y0_rot,-rot_angle,[1 0 0],'crop');                % rotate the imaged-volume back
% imagesc(squeeze(sum([rescale(X0) rescale(Y0)],3)));axis image;colorbar
% imagesc(squeeze([rescale(X0(:,:,15)) ...
%                  rescale(Y0(:,:,15)) ...
%                  rescale(Y0_aRot(:,:,15))]));axis image;colorbar

figure;                                                               % plot images  
subplot(1,3,1);imagesc(squeeze(Y0(:,:,15)));axis image;colorbar
subplot(1,3,2);imagesc(squeeze(Y0_aRot(:,:,15)));axis image;colorbar
subplot(1,3,3);imagesc(squeeze(Y0(:,:,15) - Y0_aRot(:,:,15)));axis image;colorbar

z_picked  = 15;                                                       % pick slice and crop for IQA            
cX0       = X0(Ny/4:3*Ny/4,Nx/4:3*Nx/4,z_picked);
cX0_rot   = X0_rot(Ny/4:3*Ny/4,Nx/4:3*Nx/4,z_picked);

cY0       = Y0(Ny/4:3*Ny/4,Nx/4:3*Nx/4,z_picked);
cY0_rot   = Y0_rot(Ny/4:3*Ny/4,Nx/4:3*Nx/4,z_picked);
cY0_aRot  = Y0_aRot(Ny/4:3*Ny/4,Nx/4:3*Nx/4,z_picked);

figure;
subplot(1,3,1);imagesc(squeeze(cY0));axis image;colorbar
subplot(1,3,2);imagesc(squeeze(cY0_aRot));axis image;colorbar
subplot(1,3,3);imagesc(squeeze(cY0 - cY0_aRot));axis image;colorbar

                                                                    % SSIM, PSNR, FSIM due to rotation and PSF     
ssimval_rot   = ssim(cY0,cY0_rot);                                  % SSIM
ssimval_aRot  = ssim(cY0,cY0_aRot);                                 % after rotation correction, shows iqa due to PSF alone

peaksnr_rot   = psnr(cY0,cY0_rot);                                  % PSNR
peaksnr_aRot  = psnr(cY0,cY0_aRot);

fsimval = f_fsim(cX0,cX0_rot);                                      % <incomplete> new FSIM - Feature Similarity Index Measure
fsimval = f_fsim(cY0,cY0_rot);
fsimval = f_fsim(cY0,cY0_aRot);

disp(sprintf('SSIM: rot=%d, aRot=%d, PSNR:rot=%d, aRot=%d,',...
              ssimval_rot,ssimval_aRot,peaksnr_rot,peaksnr_aRot));

            




