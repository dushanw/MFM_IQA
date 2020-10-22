clc; clear all; close all

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

tic
for i=1:length(Data0)/3
  Data.NN = Data0{(i-1)*3+1};
  Data.PS = Data0{(i-1)*3+2};
  Data.TF = Data0{(i-1)*3+3};
    
  try    
%     Data.PS = imresize(Data.PS,max(size(Data.NN)./size(Data.PS)));
%     Data.TF = imresize(Data.TF,max(size(Data.NN)./size(Data.TF)));

    Data.PS = imresize3(Data.PS,size(Data.NN));
    Data.TF = imresize3(Data.TF,size(Data.NN));
    
    [optimizer,metric]          = imregconfig('multimodal');            % 3d registration
    optimizer.MaximumIterations = 500;
    optimizer.InitialRadius     = 1e-4;

    delta       = 0;                                                    % for cropping later
    DataReg.NN  = imregister(Data.NN+delta,Data.PS,'similarity',optimizer,metric,'DisplayOptimization',1);
    DataReg.TF  = imregister(Data.TF+delta,Data.PS,'similarity',optimizer,metric,'DisplayOptimization',0);

    figure('units','normalized','outerposition',[0 0 .5 1])                % visualize NN registartion for the figure 
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

    figure('units','normalized','outerposition',[0 0 .5 1])                % visualize TF registartion for the figure 
    tlo = tiledlayout(2,4,'TileSpacing','none','Padding','none');
    nexttile, imagesc   (max(Data.PS,[],3));axis image;axis off;                 title('PS')
    nexttile, imagesc   (max(Data.TF,[],3));axis image;axis off;                 title('TF')
    nexttile, imshowpair(max(Data.TF,[],3),max(Data.PS,[],3));                   title('overlay')
    nexttile, imshowpair(histeq(max(Data.TF,[],3)),histeq(max(Data.PS,[],3)));   title('overlay(eqHist)')
    nexttile, imagesc   (max(Data.PS,[],3));axis image;axis off;                 title('PS')
    nexttile, imagesc   (max(DataReg.TF,[],3));axis image;axis off;              title('TF registered')
    nexttile, imshowpair(max(DataReg.TF,[],3),max(Data.PS,[],3));                title('overlay')
    nexttile, imshowpair(histeq(max(DataReg.TF,[],3)),histeq(max(Data.PS,[],3)));title('overlay(eqHist)')
    set(tlo.Children,'XTick',[], 'YTick', [],'fontsize',20);
    saveas(gcf,sprintf('./__results/reg_tf_branch_%d.png',i));

    ssim_sigma = 3;                                                     % run SSIM on the registered data   
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
    
    % disp(sprintf('SSIM: NN=%d, TF=%d',ssimval_rnn(i),ssimval_rtf(i)))

    figure('units','normalized','outerposition',[0 0 1 1])               % visualize TF registartion for the figure  
    tlo = tiledlayout(1,4,'TileSpacing','none','Padding','none');
    nexttile, imagesc(min(ssimmap_rnn,[],3));axis image;axis off;colorbar;  title('SSIM-map NN');
    nexttile, imshowpair(max(Data.PS,[],3), min(ssimmap_rnn,[],3));         title('overlay with PS');  
    nexttile, imagesc(min(ssimmap_rtf,[],3));axis image;axis off;colorbar;  title('SSIM-map TF');
    nexttile, imshowpair(max(Data.PS,[],3), min(ssimmap_rtf,[],3));         title('overlay with PS');  
    set(tlo.Children,'fontsize',32);
    saveas(gcf,sprintf('./__results/ssim-maps_branch_%d.png',i));
  catch   
    display(sprintf('missed %d',i))
  end
  close all 
end
toc

% subplot(1,2,1);bar([ssimval_nn' ssimval_rnn' ssimval_th_rnn']);title('SSIM NN');
% xlabel('branch#')
% ylabel('mean SSIM value [AU]')
% legend({'no reg','reg','reg + no bg'})
% set(gca,'fontsize',16);
% 
% subplot(1,2,2);bar([ssimval_tf' ssimval_rtf' ssimval_th_rtf']);title('SSIM TF');
% xlabel('branch#')
% ylabel('mean SSIM value [AU]')
% legend({'no reg','reg','reg + no bg'})
% set(gca,'fontsize',16);

figure('units','normalized','outerposition',[0 0 1 .5])          
subplot(1,3,1);bar([ssimval_tf' ssimval_nn']);title('SSIM no reg');
xlabel('branch#')
ylabel('mean SSIM value [AU]')
legend({'TF','NN'})
set(gca,'fontsize',16);

subplot(1,3,2);bar([ssimval_rtf' ssimval_rnn']);title('SSIM reg');
xlabel('branch#')
ylabel('mean SSIM value [AU]')
legend({'TF','NN'})
set(gca,'fontsize',16);

subplot(1,3,3);bar([ssimval_th_rtf' ssimval_th_rnn']);title('SSIM reg + no bg');
xlabel('branch#')
ylabel('mean SSIM value [AU]')
legend({'TF','NN'})
set(gca,'fontsize',16);





