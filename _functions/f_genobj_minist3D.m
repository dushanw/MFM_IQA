
function X0 = f_genobj_minist3D(Ny,Nx,Nz)

  load ./_Datasets/minist.mat
  
  O_2d  = XTest(:,:,randi(size(XTest,3)));
  O_2d  = imresize(O_2d,[Ny Nx]);
  O_2d  = O_2d - min(O_2d(:));
  
%   Ny  = size(O_2d,1);
%   Nx  = size(O_2d,2);
%   Nz  = max(size(O_2d,1),size(O_2d,2));

  O_3d            = zeros(Ny,Nx,Nz);
  O_3d(:,:,Nz/2)  = O_2d;
  O_3d_rot        = imrotate3(O_3d,60,[0 1 0],'crop');
  
  % imagesc([mean(O_3d,3) mean(O_3d_rot,3)]);axis image;colorbar
  % volshow(cat(1,O_3d,O_3d_rot));
  % figure;volshow(O_3d)
  % figure;volshow(O_3d_rot)

  X0  = O_3d_rot(1:Ny,1:Nx,1:Nz);
end