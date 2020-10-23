clc; clear all; close all

%% read data
X0 = f_genobj_branches_3D;

%% register volumes
[optimizer,metric]          = imregconfig('multimodal');              % 3d registration
optimizer.MaximumIterations = 100;
optimizer.InitialRadius     = 1e-4;
delta                       = 0;                                      % for cropping later

XReg = cell(1,13);
parfor i=1:length(X0)
  i
                                                                    
%   X0{i}.PS = imresize(X0{i}.PS,max(size(X0{i}.NN)./size(X0{i}.PS)));  % using the 2d-im resize; preserves the aspect ratios
%   X0{i}.TF = imresize(X0{i}.TF,max(size(X0{i}.NN)./size(X0{i}.TF)));
% 
%   X0{i}.PS     = imresize3(X0{i}.PS,size(X0{i}.NN));                  % using 3d im resize; changes the aspect ratios.     
%   X0{i}.TF     = imresize3(X0{i}.TF,size(X0{i}.NN));
                                                     
  XReg{i}.NN  = imregister(X0{i}.NN+delta,X0{i}.PS,'similarity',optimizer,metric,'DisplayOptimization',0);
  XReg{i}.TF  = imregister(X0{i}.TF+delta,X0{i}.PS,'similarity',optimizer,metric,'DisplayOptimization',0);
end

%% plot registration and calculate ssim values
for i=1:length(X0)
  Data.PS = X0{i}.PS;    
  Data.NN = imresize3(X0{i}.NN,size(Data.PS));
  Data.TF = imresize3(X0{i}.TF,size(Data.PS));

  DataReg.NN  = XReg{i}.NN;
  DataReg.TF  = XReg{i}.TF;

  if size(Data.NN,2)>size(Data.NN,1)
    Data.NN     = permute(Data.NN   ,[2 1 3]);
    Data.PS     = permute(Data.PS   ,[2 1 3]);
    Data.TF     = permute(Data.TF   ,[2 1 3]);
    DataReg.NN  = permute(DataReg.NN,[2 1 3]);
    DataReg.TF  = permute(DataReg.TF,[2 1 3]);
  end  
  
  figure('units','normalized','outerposition',[0 0 1 1])                % visualize NN registartion for the figure 
  tlo = tiledlayout(2,4,'TileSpacing','none','Padding','none');
  nexttile, imagesc   (max(Data.PS,[],3));axis image;axis off;                 title('PS')
  nexttile, imagesc   (max(Data.NN,[],3));axis image;axis off;                 title('NN')
  nexttile, imshowpair(max(Data.NN,[],3),max(Data.PS,[],3));                   title('overlay')
  nexttile, imshowpair(histeq(max(Data.NN,[],3)),histeq(max(Data.PS,[],3)));   title('overlay(eqHist)')
  nexttile, imagesc   (max(Data.PS,[],3));axis image;axis off;           title('PS')
  nexttile, imagesc   (max(DataReg.NN,[],3));axis image;axis off;              title('NN registered')
  nexttile, imshowpair(max(DataReg.NN,[],3),max(Data.PS,[],3));                title('overlay')
  nexttile, imshowpair(histeq(max(DataReg.NN,[],3)),histeq(max(Data.PS,[],3)));title('overlay(eqHist)')
  set(tlo.Children,'XTick',[], 'YTick', [],'fontsize',20);
  saveas(gcf,sprintf('./__results/reg_nn_branch_%d.png',i));

  figure('units','normalized','outerposition',[0 0 1 1])                % visualize TF registartion for the figure 
  tlo = tiledlayout(2,4,'TileSpacing','none','Padding','none');
  nexttile, imagesc   (max(Data.PS,[],3));axis image;axis off;                 title('PS')
  nexttile, imagesc   (max(Data.TF,[],3));axis image;axis off;                 title('TF')
  nexttile, imshowpair(max(Data.TF,[],3),max(Data.PS,[],3));                   title('overlay')
  nexttile, imshowpair(histeq(max(Data.TF,[],3)),histeq(max(Data.PS,[],3)));   title('overlay(eqHist)')
  nexttile, imagesc   (max(Data.PS,[],3));axis image;axis off;                 title('PS')
  nexttile, imagesc   (max(DataReg.TF,[],3));axis image;axis off;              title('TF registered')
  nexttile, imshowpair(max(DataReg.TF,[],3),max(Data.PS,[],3));                title('overlay')
  nexttile, imshowpair(histeq(max(DataReg.TF,[],3)),histeq(max(Data.PS,[],3)));title('overlay(eqHist)')
  set(tlo.Children,'XTick',[], 'YTick', [],'fontsize',16);
  saveas(gcf,sprintf('./__results/reg_tf_branch_%d.png',i));

  ssim_sigma = 3;                                                     % run SSIM on the registered data   
  [ssimval_rnn(i),ssimmap_rnn] = ssim(rescale(Data.PS),rescale(DataReg.NN),'Radius',ssim_sigma);
  [ssimval_rtf(i),ssimmap_rtf] = ssim(rescale(Data.PS),rescale(DataReg.TF),'Radius',ssim_sigma);
  [ssimval_nn(i) ,ssimmap_nn ] = ssim(rescale(Data.PS),rescale(Data.NN),'Radius',ssim_sigma);
  [ssimval_tf(i) ,ssimmap_tf ] = ssim(rescale(Data.PS),rescale(Data.TF),'Radius',ssim_sigma);

  pxval_th      = -1;% to remove bg regions
  pxval_th_reg  =  0;% to remove bg regions after registration    
  fg_inds_rnn   = (Data.PS(:)>pxval_th | DataReg.NN(:)>pxval_th) & DataReg.NN(:)>0;
  fg_inds_rtf   = (Data.PS(:)>pxval_th | DataReg.TF(:)>pxval_th) & DataReg.TF(:)>0;
  ssimval_th_rnn(i) = mean(ssimmap_rnn(fg_inds_rnn));
  ssimval_th_rtf(i) = mean(ssimmap_rtf(fg_inds_rtf));

  [ssimval_m3_rnn(i),ssimmap_m3_rnn] = multissim3(rescale(Data.PS),rescale(DataReg.NN),'Sigma',ssim_sigma);
  [ssimval_m3_rtf(i),ssimmap_m3_rtf] = multissim3(rescale(Data.PS),rescale(DataReg.TF),'Sigma',ssim_sigma);
  [ssimval_m3_nn(i) ,ssimmap_m3_nn ] = multissim3(rescale(Data.PS),rescale(Data.NN)   ,'Sigma',ssim_sigma);
  [ssimval_m3_tf(i) ,ssimmap_m3_tf ] = multissim3(rescale(Data.PS),rescale(Data.TF)   ,'Sigma',ssim_sigma);
  
  figure('units','normalized','outerposition',[0 0 1 1])               % visualize ssim-maps for the figure  
  tlo = tiledlayout(2,4,'TileSpacing','none','Padding','none');
  nexttile, imagesc(min(ssimmap_rnn,[],3));axis image;axis off;colorbar;  title('SSIM-map NN');
  nexttile, imshowpair(max(Data.PS,[],3), min(ssimmap_rnn,[],3));         title('overlay with PS');  
  nexttile, imagesc(min(ssimmap_rtf,[],3));axis image;axis off;colorbar;  title('SSIM-map TF');
  nexttile, imshowpair(max(Data.PS,[],3), min(ssimmap_rtf,[],3));         title('overlay with PS');  
  nexttile, imagesc(min(ssimmap_m3_rnn{1},[],3));axis image;axis off;colorbar;  title('SSIM-map NN');
  nexttile, imshowpair(max(Data.PS,[],3), min(ssimmap_m3_rnn{1},[],3));         title('overlay with PS');  
  nexttile, imagesc(min(ssimmap_m3_rtf{1},[],3));axis image;axis off;colorbar;  title('SSIM-map TF');
  nexttile, imshowpair(max(Data.PS,[],3), min(ssimmap_m3_rtf{1},[],3));         title('overlay with PS');  
  set(tlo.Children,'fontsize',16);
  saveas(gcf,sprintf('./__results/ssim-maps_branch_%d.png',i));

  close all 
end


figure('units','normalized','outerposition',[0 0 1 1])          
ylim([0 1])
subplot(2,3,1);bar([ssimval_tf' ssimval_nn']);title('SSIM no reg');
xlabel('branch#')
ylabel('mean SSIM value [AU]')
legend({'TF','NN'})
set(gca,'fontsize',16);

subplot(2,3,2);bar([ssimval_rtf' ssimval_rnn']);title('SSIM reg');
ylim([0 1])
xlabel('branch#')
ylabel('mean SSIM value [AU]')
legend({'TF','NN'})
set(gca,'fontsize',16);

subplot(2,3,3);bar([ssimval_th_rtf' ssimval_th_rnn']);title('SSIM reg + no bg');
ylim([0 1])
xlabel('branch#')
ylabel('mean SSIM value [AU]')
legend({'TF','NN'})
set(gca,'fontsize',16);

ylim([0 1])
subplot(2,3,4);bar([ssimval_m3_tf' ssimval_m3_nn']);title('MS-SSIM no reg');
xlabel('branch#')
ylabel('mean SSIM value [AU]')
legend({'TF','NN'})
set(gca,'fontsize',16);

subplot(2,3,5);bar([ssimval_m3_rtf' ssimval_m3_rnn']);title('MS-SSIM reg');
ylim([0 1])
xlabel('branch#')
ylabel('mean SSIM value [AU]')
legend({'TF','NN'})
set(gca,'fontsize',16);

saveas(gcf,sprintf('./__results/ssim-barplot_branches_%s.png',datetime))



