% main simulate point cloud.
clear all; close all; clc

load APSF_3D_p8NA_1RI_p2umdx
% load('APSF_3D_1.000000e-01NA_1RI_2.000000e-01umdx.mat')
% load('APSF_3D_1.000000e-01NA_1RI_2.000000e-01umdx.mat')
name_stem = 'p8';

Ex = PSF_3D{1};
Ey = PSF_3D{2};
Ez = PSF_3D{3};

Nx = size(Ex,1);
Ny = size(Ex,2);
Nz = size(Ex,3);
Nt = 1;
N_foci = 10;

Phi_mask = rand(Nx*2,Ny*2)*2*pi-pi;
delta_Phi = pi/5;

Phi_mask = rand(Nx*2,Ny*2)*2*pi-pi;
Amp_mask = 1;%rand(Nx*2,Ny*2);

mask_t = Amp_mask.*exp(i.*(Phi_mask));        

for t=1:Nt
    t    
    % mask_t = ifftn(fftn(mask_t)*exp(i*delta_Phi));
    mask_t = mask_t*exp(i*delta_Phi);
    
    Ex_volume = convn(Ex,mask_t,'same');
    Ey_volume = convn(Ey,mask_t,'same');
    Ez_volume = convn(Ez,mask_t,'same');

    I_ext_volume{t}   = abs(Ex_volume).^2+abs(Ey_volume).^2+abs(Ez_volume).^2;
    I_ext_volume_n{t} = I_ext_volume{t}/max(I_ext_volume{t}(:));         
end

% plot the point cloud
imagesc([squeeze(I_ext_volume_n{1}(:,:,50)),...
         squeeze(I_ext_volume_n{1}(:,100,:)),...
         squeeze(I_ext_volume_n{1}(100,:,:))]);
axis image;axis off
colormap gray
set(gca,'fontsize',16);
%colorbar
saveas(gcf,['I_ext_NA_' name_stem '.tif']);

%% generate intensity psf
IPSF = abs(Ex).^2+abs(Ey).^2+abs(Ez).^2;

imagesc([squeeze(IPSF(:,:,50)) squeeze(IPSF(:,100,:))   squeeze(IPSF(100,:,:))])
axis image;axis off
colormap gray
set(gca,'fontsize',16);
%colorbar
saveas(gcf,['IPSF_NA_' name_stem '.tif']);

%% generate the few point object
O = zeros(Nx/2,Ny/2,Nz);
O(randi(Nx*Ny*Nz/4,[1 N_foci-1])) = 1000;
O(randi(Nx/2),randi(Ny/2),Nz/2) = 1000;

close all
I = convn(O.*I_ext_volume_n{1}(1:Nx/2,1:Ny/2,:),IPSF,'same');
In = I./max(I(:));
imagesc(log10(In(:,:,50)));
colorbar
axis image;axis off
set(gca,'fontsize',16);
%colorbar
saveas(gcf,['I_sim_mod_NA_' name_stem '.tif']);


imagesc(max(log10(In),[],3)));








 


