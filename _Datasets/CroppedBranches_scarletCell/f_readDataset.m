
function Data  = f_readDataset(fname)

  Nz = length(imfinfo(fname));
  for i=1:Nz
    Data(:,:,i) = imread(fname,i);
  end
  
end
