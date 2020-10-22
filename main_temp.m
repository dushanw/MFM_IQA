% <clean the code>

clc; clear all; close all

of    = cd('./_Datasets/FullStacks/');
Data  = f_readDataset();
cd(of);

% volshow(Data.PS,'Renderer','MaximumIntensityProjection');
subplot(1,3,1);imagesc(max(Data.PS,[],3));axis image
subplot(1,3,2);imagesc(max(Data.TF,[],3));axis image
subplot(1,3,3);imagesc(max(Data.NN,[],3));axis image

[optimizer,metric]          = imregconfig('multimodal');
optimizer.MaximumIterations = 500;
optimizer.InitialRadius     = 1e-4;

delta       = 1; % for cropping later
DataReg.NN  = imregister(Data.NN+delta,Data.PS,'similarity',optimizer,metric,'DisplayOptimization',1);
DataReg.TF  = imregister(Data.TF+delta,Data.PS,'similarity',optimizer,metric,'DisplayOptimization',1);

%% NN
figure;
tlo = tiledlayout(2,4,'TileSpacing','none','Padding','none');
nexttile, imagesc(max(Data.PS,[],3));axis image;axis off;                    title('PS')
nexttile, imagesc(max(Data.NN,[],3));axis image;axis off;                    title('NN')
nexttile, imshowpair(max(Data.NN,[],3),max(Data.PS,[],3));                   title('overlay')
nexttile, imshowpair(histeq(max(Data.NN,[],3)),histeq(max(Data.PS,[],3)));   title('overlay(eqHist)')

nexttile, imagesc(max(DataReg.PS_NN,[],3));axis image;axis off;                    title('PS')
nexttile, imagesc(max(DataReg.NN,[],3));axis image;axis off;                 title('NN registered')
nexttile, imshowpair(max(DataReg.NN,[],3),max(Data.PS,[],3));                title('overlay')
nexttile, imshowpair(histeq(max(DataReg.NN,[],3)),histeq(max(Data.PS,[],3)));title('overlay(eqHist)')

set(tlo.Children,'XTick',[], 'YTick', [],'fontsize',16);

%% TF
figure;
tlo = tiledlayout(2,4,'TileSpacing','none','Padding','none');
nexttile, imagesc(max(Data.PS,[],3));axis image;axis off;                    title('PS')
nexttile, imagesc(max(Data.TF,[],3));axis image;axis off;                    title('TF')
nexttile, imshowpair(max(Data.TF,[],3),max(Data.PS,[],3));                   title('overlay')
nexttile, imshowpair(histeq(max(Data.TF,[],3)),histeq(max(Data.PS,[],3)));   title('overlay(eqHist)')

nexttile, imagesc(max(Data.PS,[],3));axis image;axis off;                    title('PS')
nexttile, imagesc(max(DataReg.TF,[],3));axis image;axis off;                 title('TF registered')
nexttile, imshowpair(max(DataReg.TF,[],3),max(Data.PS,[],3));                title('overlay')
nexttile, imshowpair(histeq(max(DataReg.TF,[],3)),histeq(max(Data.PS,[],3)));title('overlay(eqHist)')

set(tlo.Children,'XTick',[], 'YTick', [],'fontsize',16);


%% test ssim

close all
ssim_sigma = 1;

[ssimval_nn ,ssimmap_nn ] = ssim(Data.PS,Data.NN   ,'Radius',ssim_sigma);
[ssimval_rnn,ssimmap_rnn] = ssim(Data.PS,DataReg.NN,'Radius',ssim_sigma);
% figure;
% subplot(2,2,1);imagesc(rescale(max(Data.PS   ,[],3)));axis image;colorbar
% subplot(2,2,2);imagesc(rescale(max(DataReg.NN,[],3)));axis image;colorbar
% subplot(2,2,3);imagesc(mean(ssimmap_nn ,3));axis image;colorbar
% subplot(2,2,4);imagesc(mean(ssimmap_rnn,3));axis image;colorbar
% figure;
[ssimval_tf ,ssimmap_tf ] = ssim(Data.PS,Data.TF   ,'Radius',ssim_sigma);
[ssimval_rtf,ssimmap_rtf] = ssim(Data.PS,DataReg.TF,'Radius',ssim_sigma);
% subplot(2,2,1);imagesc(rescale(max(Data.PS   ,[],3)));axis image;colorbar
% subplot(2,2,2);imagesc(rescale(max(DataReg.TF,[],3)));axis image;colorbar
% subplot(2,2,3);imagesc(mean(ssimmap_tf ,3));axis image;colorbar
% subplot(2,2,4);imagesc(mean(ssimmap_rtf,3));axis image;colorbar
figure;
% subplot(1,2,1);imagesc(min(ssimmap_rnn,[],3));axis image;axis off;colorbar
% subplot(1,2,2);imagesc(min(ssimmap_rtf,[],3));axis image;axis off;colorbar
subplot(1,2,1);imagesc(mean(ssimmap_rnn,3));axis image;axis off;colorbar
subplot(1,2,2);imagesc(mean(ssimmap_rtf,3));axis image;axis off;colorbar



