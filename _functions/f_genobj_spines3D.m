
function X0 = f_genobj_spines3D(Ny,Nx,Nz)

  for i=1:176
    O_3d(:,:,i) = imread('./_Datasets/C3-GEP009_031618pointscan_300mWstart__STACK_cropped.tif',i);     
  end
  O_3d = single(O_3d(:,:,end-Nz+1:end));                        % select only 128 depths
  O_3d  = imresize(O_3d,[Ny Nx]);
  
  % volshow(O_3d,'Renderer','MaximumIntensityProjection');
  % imagesc(O_3d(:,:,74));axis image;colorbar
  % imagesc(mean(O_3d,3));axis image;colorbar
  % figure;volshow(O_3d)
  
  X0  = O_3d(1:Ny,1:Nx,1:Nz);
end