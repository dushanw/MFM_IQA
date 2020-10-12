% main simulate point cloud.
clear all; close all; clc

load APSF_3D_p8NA_1RI_p2umdx
Ex = PSF_3D{1};
Ey = PSF_3D{2};
Ez = PSF_3D{3};

% load('APSF_3D_1.000000e-01NA_1RI_2.000000e-01umdx.mat')
load('APSF_3D_4.000000e-01NA_1RI_2.000000e-01umdx.mat')
Ex2 = PSF_3D{1};
Ey2 = PSF_3D{2};
Ez2 = PSF_3D{3};

name_stem = 'p1_P8';

Nx = size(Ex,1);
Ny = size(Ex,2);
Nz = size(Ex,3);
Nt = 1;
N_foci = 10;

Phi_mask = rand(Nx*2,Ny*2)*2*pi-pi;
delta_Phi = pi/5;

Phi_mask = rand(Nx*2,Ny*2)*2*pi-pi;
Amp_mask = 1;%rand(Nx*2,Ny*2);

Phi_mask_2 = rand(Nx*2,Ny*2)*2*pi-pi;
Amp_mask_2 = 1;%rand(Nx*2,Ny*2);

mask_t = Amp_mask.*exp(i.*(Phi_mask));        
mask_t_2 = Amp_mask_2.*exp(i.*(Phi_mask_2));        

for t=1:Nt
    t    
    % mask_t = ifftn(fftn(mask_t)*exp(i*delta_Phi));
    mask_t = mask_t*exp(i*delta_Phi);
    mask_t_2 = mask_t_2*exp(i*delta_Phi);
    
    Ex_volume = convn(Ex,mask_t,'same');
    Ey_volume = convn(Ey,mask_t,'same');
    Ez_volume = convn(Ez,mask_t,'same');
    
    Ex_volume_2 = convn(Ex2,mask_t_2,'same');
    Ey_volume_2 = convn(Ey2,mask_t_2,'same');
    Ez_volume_2 = convn(Ez2,mask_t_2,'same');

    Ex_volume = Ex_volume + flip(Ex_volume_2,3);
    Ey_volume = Ey_volume + flip(Ey_volume_2,3);
    Ez_volume = Ez_volume + flip(Ez_volume_2,3);
        
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
saveas(gcf,['I_ext_2obj_NA_' name_stem '.tif']);

%% generate the few point object
IPSF = abs(Ex).^2+abs(Ey).^2+abs(Ez).^2;

imagesc([squeeze(IPSF(:,:,50)) squeeze(IPSF(:,100,:))   squeeze(IPSF(100,:,:))])
axis image;axis off
colormap gray
set(gca,'fontsize',16);
%colorbar
saveas(gcf,['IPSF_2obj_NA_' name_stem '.tif']);

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
saveas(gcf,['I_sim_mod_2obj_NA_' name_stem '.tif']);











 


