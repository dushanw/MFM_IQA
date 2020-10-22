clc; clear all; close all

%% read and preprocess
of = cd('_Datasets/CroppedBranches_scarletCell/');
imds = imageDatastore('./',...
                      'IncludeSubfolders',1,...
                      'FileExtensions','.tif',...
                      'ReadFcn',@f_readDataset);                         
Data0 = imds.readall();
cd(of)
for i=1:length(Data0)
  [i size(Data0{i},3)]
  if size(Data0{i},3)<=16
    Data0{i} = (padarray(Data0{i},[0 0 ceil((16-size(Data0{i},3))/2) ]));
  end
end

%% registration
[optimizer,metric]          = imregconfig('multimodal');            % 3d registration
optimizer.MaximumIterations = 500;
optimizer.InitialRadius     = 1e-4;
delta                       = 0;                                    % for cropping later

DataAll     = cell(1,13);
DataRegAll  = cell(1,13);
parfor i=1:length(Data0)/3
  i
  DataAll{i}.NN     = Data0{(i-1)*3+1};
  DataAll{i}.PS     = Data0{(i-1)*3+2};
  DataAll{i}.TF     = Data0{(i-1)*3+3};
  
  DataAll{i}.PS     = imresize3(DataAll{i}.PS,size(DataAll{i}.NN));    
  DataAll{i}.TF     = imresize3(DataAll{i}.TF,size(DataAll{i}.NN));
                                                     % for cropping later
  DataRegAll{i}.NN  = imregister(DataAll{i}.NN+delta,DataAll{i}.PS,'similarity',optimizer,metric,'DisplayOptimization',0);
  DataRegAll{i}.TF  = imregister(DataAll{i}.TF+delta,DataAll{i}.PS,'similarity',optimizer,metric,'DisplayOptimization',0);
end

tic
for i=1:length(Data0)/3
  
  Data.NN = DataAll{i}.NN;
  Data.PS = DataAll{i}.PS;
  Data.TF = DataAll{i}.TF;
  
  DataReg.NN  = DataRegAll{i}.NN;
  DataReg.TF  = DataRegAll{i}.TF;

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

  ssim_sigma = 1.5;                                                     % run SSIM on the registered data   
  [ssimval_rnn(i),ssimmap_rnn] = ssim(rescale(Data.PS),rescale(DataReg.NN),'Radius',ssim_sigma);
  [ssimval_rtf(i),ssimmap_rtf] = ssim(rescale(Data.PS),rescale(DataReg.TF),'Radius',ssim_sigma);
  [ssimval_nn(i) ,ssimmap_nn ] = ssim(rescale(Data.PS),rescale(Data.NN),'Radius',ssim_sigma);
  [ssimval_tf(i) ,ssimmap_tf ] = ssim(rescale(Data.PS),rescale(Data.TF),'Radius',ssim_sigma);

  pxval_th      = -1;% to remove bg regions
  pxval_th_reg  = 0;% to remove bg regions after registration    
  fg_inds_rnn   = (Data.PS(:)>pxval_th | DataReg.NN(:)>pxval_th) & DataReg.NN(:)>0;
  fg_inds_rtf   = (Data.PS(:)>pxval_th | DataReg.TF(:)>pxval_th) & DataReg.TF(:)>0;
  ssimval_th_rnn(i) = mean(ssimmap_rnn(fg_inds_rnn));
  ssimval_th_rtf(i) = mean(ssimmap_rtf(fg_inds_rtf));

  [ssimval_m3_rnn(i),ssimmap_m3_rnn] = multissim3(rescale(Data.PS),rescale(DataReg.NN),'Sigma',ssim_sigma);
  [ssimval_m3_rtf(i),ssimmap_m3_rtf] = multissim3(rescale(Data.PS),rescale(DataReg.TF),'Sigma',ssim_sigma);
  [ssimval_m3_nn(i) ,ssimmap_m3_nn ] = multissim3(rescale(Data.PS),rescale(Data.NN)   ,'Sigma',ssim_sigma);
  [ssimval_m3_tf(i) ,ssimmap_m3_tf ] = multissim3(rescale(Data.PS),rescale(Data.TF)   ,'Sigma',ssim_sigma);

  score = multissim3(rescale(Data.PS),rescale(DataReg.TF));
  score = multissim3(rescale(Data.PS),rescale(DataReg.NN));
  
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
toc

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



