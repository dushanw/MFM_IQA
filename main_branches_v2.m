clc; clear all; close all

%% read data
X0 = f_genobj_branches_3D_v2;

%% register volumes
[optimizer,metric]          = imregconfig('multimodal');              % 3d registration
optimizer.MaximumIterations = 100;
optimizer.InitialRadius     = 1e-4;
trType                      = 'rigid';                                % {'translation','rigid','similarity','affine'}

tic
XReg = cell(1,12);
parfor i=1:length(X0)
  i
                                                                                                                         
  XReg{i}.TF      = imregister(X0{i}.TF     , X0{i}.PS, trType, optimizer, metric, 'DisplayOptimization',0);    
  XReg{i}.NN      = imregister(X0{i}.NN     , X0{i}.PS, trType, optimizer, metric, 'DisplayOptimization',0);
  XReg{i}.cDconv  = imregister(X0{i}.cDconv , X0{i}.PS, trType, optimizer, metric, 'DisplayOptimization',0);
  XReg{i}.nnDconv = imregister(X0{i}.nnDconv, X0{i}.PS, trType, optimizer, metric, 'DisplayOptimization',0);  
  XReg{i}.nnDenoi = imregister(X0{i}.nnDenoi, X0{i}.PS, trType, optimizer, metric, 'DisplayOptimization',0);
  XReg{i}.nnNoSkp = imregister(X0{i}.nnNoSkp, X0{i}.PS, trType, optimizer, metric, 'DisplayOptimization',0);  
  XReg{i}.nnNoDS  = imregister(X0{i}.nnNoDS , X0{i}.PS, trType, optimizer, metric, 'DisplayOptimization',0);  
end
toc


%% plot registration and calculate ssim values
resultsDir = sprintf('./__results/%s/',datetime);
mkdir(resultsDir)

save([resultsDir 'X0_XReg.mat'],'X0','XReg');

for i=1:length(X0)
  X0{i}.PS       = X0{i}.PS;    
  X0{i}.NN       = imresize3(X0{i}.NN      ,size(X0{i}.PS));
  X0{i}.TF       = imresize3(X0{i}.TF      ,size(X0{i}.PS));
  X0{i}.cDconv   = imresize3(X0{i}.cDconv  ,size(X0{i}.PS));
  X0{i}.nnDconv  = imresize3(X0{i}.nnDconv ,size(X0{i}.PS));
  X0{i}.nnDenoi  = imresize3(X0{i}.nnDenoi ,size(X0{i}.PS));
  X0{i}.nnNoSkp  = imresize3(X0{i}.nnNoSkp ,size(X0{i}.PS));
  X0{i}.nnNoDS   = imresize3(X0{i}.nnNoDS  ,size(X0{i}.PS));
    
%   f_plotReg(X0{i}.PS,X0{i}.NN     , XReg{i}.NN     , sprintf('%s/reg_nn_branch_%d.png'     ,resultsDir,i) ,'NN'     );    
%   f_plotReg(X0{i}.PS,X0{i}.TF     , XReg{i}.TF     , sprintf('%s/reg_tf_branch_%d.png'     ,resultsDir,i) ,'TF'     );
%   f_plotReg(X0{i}.PS,X0{i}.cDconv , XReg{i}.cDconv , sprintf('%s/reg_cDconv_branch_%d.png' ,resultsDir,i) ,'cDconv' );
%   f_plotReg(X0{i}.PS,X0{i}.nnDconv, XReg{i}.nnDconv, sprintf('%s/reg_nnDconv_branch_%d.png',resultsDir,i) ,'nnDconv');
%   f_plotReg(X0{i}.PS,X0{i}.nnDenoi, XReg{i}.nnDenoi, sprintf('%s/reg_nnDenoi_branch_%d.png',resultsDir,i) ,'nnDenoi');
%   f_plotReg(X0{i}.PS,X0{i}.nnNoSkp, XReg{i}.nnNoSkp, sprintf('%s/reg_nnNoSkp_branch_%d.png',resultsDir,i) ,'nnNoSkp');
%   f_plotReg(X0{i}.PS,X0{i}.nnNoDS , XReg{i}.nnNoDS , sprintf('%s/reg_nnNoDS_branch_%d.png' ,resultsDir,i) ,'nnNoDS' );
   
  ssim_sigma = 1.5;                                                     % run SSIM on the registered data   
  [ssimval_nn_r(i)     ,ssimmap_nn_r     ] = ssim(rescale(X0{i}.PS),rescale(XReg{i}.NN)     ,'Radius',ssim_sigma);
  [ssimval_tf_r(i)     ,ssimmap_tf_r     ] = ssim(rescale(X0{i}.PS),rescale(XReg{i}.TF)     ,'Radius',ssim_sigma);
  [ssimval_cDconv_r(i) ,ssimmap_cDconv_r ] = ssim(rescale(X0{i}.PS),rescale(XReg{i}.cDconv) ,'Radius',ssim_sigma);
  [ssimval_nnDconv_r(i),ssimmap_nnDconv_r] = ssim(rescale(X0{i}.PS),rescale(XReg{i}.nnDconv),'Radius',ssim_sigma);
  [ssimval_nnDenoi_r(i),ssimmap_nnDenoi_r] = ssim(rescale(X0{i}.PS),rescale(XReg{i}.nnDenoi),'Radius',ssim_sigma);
  [ssimval_nnNoSkp_r(i),ssimmap_nnNoSkp_r] = ssim(rescale(X0{i}.PS),rescale(XReg{i}.nnNoSkp),'Radius',ssim_sigma);
  [ssimval_nnNoDS_r(i) ,ssimmap_nnNoDS_r ] = ssim(rescale(X0{i}.PS),rescale(XReg{i}.nnNoDS) ,'Radius',ssim_sigma);
  
  [ssimval_nn(i)       ,ssimmap_nn       ] = ssim(rescale(X0{i}.PS),rescale(X0{i}.NN)       ,'Radius',ssim_sigma);
  [ssimval_tf(i)       ,ssimmap_tf       ] = ssim(rescale(X0{i}.PS),rescale(X0{i}.TF)       ,'Radius',ssim_sigma);
  [ssimval_cDconv(i)   ,ssimmap_cDconv   ] = ssim(rescale(X0{i}.PS),rescale(X0{i}.cDconv)   ,'Radius',ssim_sigma);
  [ssimval_nnDconv(i)  ,ssimmap_nnDconv  ] = ssim(rescale(X0{i}.PS),rescale(X0{i}.nnDconv)  ,'Radius',ssim_sigma);
  [ssimval_nnDenoi(i)  ,ssimmap_nnDenoi  ] = ssim(rescale(X0{i}.PS),rescale(X0{i}.nnDenoi)  ,'Radius',ssim_sigma);
  [ssimval_nnNoSkp(i)  ,ssimmap_nnNoSkp  ] = ssim(rescale(X0{i}.PS),rescale(X0{i}.nnNoSkp)  ,'Radius',ssim_sigma);
  [ssimval_nnNoDS(i)   ,ssimmap_nnNoDS   ] = ssim(rescale(X0{i}.PS),rescale(X0{i}.nnNoDS)   ,'Radius',ssim_sigma);
  
%   [ssimval_m3_rnn(i),ssimmap_m3_rnn] = multissim3(rescale(Data.PS),rescale(DataReg.NN),'Sigma',ssim_sigma);
  
  close all 
end

figure('units','normalized','outerposition',[0 0 1 1])          

subplot(1,2,1);bar([ssimval_nn'... 
                    ssimval_tf'... 
                    ssimval_cDconv'... 
                    ssimval_nnDconv'... 
                    ssimval_nnDenoi'... 
                    ssimval_nnNoSkp'... 
                    ssimval_nnNoDS'... 
                    ]);title('SSIM no reg');
ylim([0 1])
xlabel('branch#')
ylabel('mean SSIM value [AU]')
legend({'TF','NN','cDconv','nnDconv','nnDenoi','nnNoSkp','nnNoDS'})
set(gca,'fontsize',16);

subplot(1,2,2);bar([ssimval_nn'... 
                    ssimval_tf'... 
                    ssimval_cDconv'... 
                    ssimval_nnDconv'... 
                    ssimval_nnDenoi'... 
                    ssimval_nnNoSkp'... 
                    ssimval_nnNoDS'... 
                    ]);title('SSIM no reg');
ylim([0 1])
xlabel('branch#')
ylabel('mean SSIM value [AU]')
legend({'TF','NN','cDconv','nnDconv','nnDenoi','nnNoSkp','nnNoDS'})
set(gca,'fontsize',16);

saveas(gcf,sprintf('%s/ssim-barplot_branches_%s.png',resultsDir,datetime))



