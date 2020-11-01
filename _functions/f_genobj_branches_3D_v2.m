
function X0 = f_genobj_branches_3D_v2()

  %% imaging parameters
  dx_ps = 0.25; % [um]
  dx_tf = 0.17; % [um]
  dz_ps = 1;    % [um]
  dz_tf = 1;    % [um]
  
  %% read and preprocess
  of = cd('_Datasets/CroppedBranches_ForSSIM_v2/');
  imds = imageDatastore('./',...
                        'IncludeSubfolders',1,...
                        'FileExtensions','.tif',...
                        'ReadFcn',@f_readDataset);                         
  Data0 = imds.readall();
  cd(of)
  
  N_branches = 12;
  for i=1:N_branches
    X0{i}.cDconv  = Data0{ N_branches*0 +i};                           % ConventionalDeconvolution
    X0{i}.nnDconv = Data0{ N_branches*1 +i};                           % DeconvNN
    X0{i}.nnDenoi = Data0{ N_branches*2 +i};                           % Denoise 
    X0{i}.NN      = Data0{ N_branches*3 +i};                           % NN
    X0{i}.nnNoSkp = Data0{ N_branches*4 +i};                           % NoSkip
    X0{i}.nnNoDS  = Data0{ N_branches*5 +i};                           % No_Downsampling
    X0{i}.PS      = Data0{ N_branches*6 +i};                           % PS
    X0{i}.TF      = Data0{ N_branches*7 +i};                           % TFM_network_input
    
%     imds.Files{N_branches*0 +i}
%     imds.Files{N_branches*1 +i}
%     imds.Files{N_branches*2 +i}
%     imds.Files{N_branches*3 +i}
%     imds.Files{N_branches*4 +i}
%     imds.Files{N_branches*5 +i}
%     imds.Files{N_branches*6 +i}
%     imds.Files{N_branches*7 +i}

    rs_tf = [size(X0{i}.TF,1)*dx_tf/dx_ps   size(X0{i}.TF,2)*dx_tf/dx_ps  size(X0{i}.TF,3)*dz_tf/dx_ps];
    rs_ps = [size(X0{i}.PS,1)               size(X0{i}.PS,2)              size(X0{i}.PS,3)*dz_ps/dx_ps];
    
    X0{i}.PS      = imresize3(X0{i}.PS      ,rs_ps);    % Resize PS to match the all three pixel sizes
    X0{i}.TF      = imresize3(X0{i}.TF      ,rs_tf);    % Resize TF to match the TF size
    X0{i}.NN      = imresize3(X0{i}.NN      ,rs_tf);    % Resize NN to match the TF size
    X0{i}.cDconv  = imresize3(X0{i}.cDconv  ,rs_tf);    % Resize cDconv to match the TF size
    X0{i}.nnDconv = imresize3(X0{i}.nnDconv ,rs_tf);    % Resize nnDconv to match the TF size
    X0{i}.nnDenoi = imresize3(X0{i}.nnDenoi ,rs_tf);    % Resize nnDenoi to match the TF size
    X0{i}.nnNoSkp = imresize3(X0{i}.nnNoSkp ,rs_tf);    % Resize nnNoSkp to match the TF size
    X0{i}.nnNoDS  = imresize3(X0{i}.nnNoDS  ,rs_tf);    % Resize nnNoDS to match the TF size
        
%   X0{i}
  end 

end
