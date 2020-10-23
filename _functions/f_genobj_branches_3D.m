
function X0 = f_genobj_branches_3D()

  %% imaging parameters
  dx_ps = 0.25; % [um]
  dx_tf = 0.17; % [um]
  dz_ps = 1;    % [um]
  dz_tf = 1;    % [um]
  
  %% read and preprocess
  of = cd('_Datasets/CroppedBranches_scarletCell/');
  imds = imageDatastore('./',...
                        'IncludeSubfolders',1,...
                        'FileExtensions','.tif',...
                        'ReadFcn',@f_readDataset);                         
  Data0 = imds.readall();
  cd(of)
  
  %% pad to make minimum size more than 16 (or 20) for the imreg algo
  for i=1:length(Data0)
    if size(Data0{i},3)<=20
      Data0{i} = (padarray(Data0{i},[0 0 ceil((20-size(Data0{i},3))/2) ]));
    end
  end

  %% resize TF and NN to match PS pixel size
  for i=1:length(Data0)/3
    X0{i}.NN  = Data0{(i-1)*3+1};
    X0{i}.PS  = Data0{(i-1)*3+2};
    X0{i}.TF  = Data0{(i-1)*3+3};
    
    X0{i}.NN  = imresize(X0{i}.NN,dx_tf/dx_ps);
    X0{i}.TF  = imresize(X0{i}.TF,dx_tf/dx_ps);
    
%   [i size(X0{i}.PS,1) size(X0{i}.TF,1) size(X0{i}.NN,1)]
  end 
  
  %% rotate branches to make them straight
              % 1   2   3   4   5   6   7   8   9   10    11    12    13    
  rot_angles = [0   40  0  -60 -45 -90 -90  0  -25  10   -70    0     30];      % values set manually
%   i=4  
%   subplot(3,2,1);imagesc(max(X0{i}.PS,[],3));                         axis image
%   subplot(3,2,2);imagesc(max(imrotate(X0{i}.PS,rot_angles(i)),[],3)); axis image
%   subplot(3,2,3);imagesc(max(X0{i}.NN,[],3));                         axis image  
%   subplot(3,2,4);imagesc(max(imrotate(X0{i}.NN,rot_angles(i)),[],3)); axis image
%   subplot(3,2,5);imagesc(max(X0{i}.TF,[],3));                         axis image  
%   subplot(3,2,6);imagesc(max(imrotate(X0{i}.TF,rot_angles(i)),[],3)); axis image
  
  for i=1:length(X0)
    X0{i}.NN  = imrotate(X0{i}.NN,rot_angles(i));
    X0{i}.PS  = imrotate(X0{i}.PS,rot_angles(i));
    X0{i}.TF  = imrotate(X0{i}.TF,rot_angles(i));
    
%     [i size(X0{i}.PS,1) size(X0{i}.TF,1) size(X0{i}.NN,1)]
%     [i size(X0{i}.PS,2) size(X0{i}.TF,2) size(X0{i}.NN,2)]    
  end
  
  %% crop empty regions    
  for i=1:length(X0)
%     figure;
%     subplot(2,3,1);imagesc(max(X0{i}.PS,[],3));                         axis image
%     subplot(2,3,2);imagesc(max(X0{i}.TF,[],3));                         axis image
%     subplot(2,3,3);imagesc(max(X0{i}.NN,[],3));                         axis image
    
    stats     = regionprops(max(X0{i}.TF,[],3)>0,'BoundingBox');
    bb        = stats.BoundingBox;    
    X0{i}.TF  = X0{i}.TF(bb(2):bb(2)+bb(4)-1,bb(1):bb(1)+bb(3)-1,:);
    
    stats     = regionprops(max(X0{i}.PS,[],3)>0,'BoundingBox');
    bb        = stats.BoundingBox;
    X0{i}.PS  = X0{i}.PS(bb(2):bb(2)+bb(4)-1,bb(1):bb(1)+bb(3)-1,:);
    
    stats     = regionprops(max(X0{i}.NN,[],3)>0,'BoundingBox');
    bb        = stats.BoundingBox;
    X0{i}.NN  = X0{i}.NN(bb(2):bb(2)+bb(4)-1,bb(1):bb(1)+bb(3)-1,:);
    
%     subplot(2,3,4);imagesc(max(X0{i}.PS,[],3));                         axis image
%     subplot(2,3,5);imagesc(max(X0{i}.TF,[],3));                         axis image
%     subplot(2,3,6);imagesc(max(X0{i}.NN,[],3));                         axis image

%   [i size(X0{i}.PS,1) size(X0{i}.TF,1) size(X0{i}.NN,1)]
%   [i size(X0{i}.PS,2) size(X0{i}.TF,2) size(X0{i}.NN,2)]    
  end
  
end









