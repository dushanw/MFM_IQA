
%% previous work on fsim on simulated images and other real images

I = single(I_NN);
I = single(I_PS);

[f,d] = vl_sift(I,'PeakThresh',.05,'NormThresh',10) ;

[f,d] = vl_covdet(I, 'method', 'HarrisLaplace');

[f,d] = vl_covdet(I,'EstimateAffineShape', true);

figure;
imagesc(I);axis image;colorbar
h1 = vl_plotframe(f);
%h3 = vl_plotsiftdescriptor(d,f) ;
clc

fixedPoints   = cat(2,fa(1,matches(1,:))',fa(2,matches(1,:))');
movingPoints  = cat(2,fb(1,matches(2,:))',fb(2,matches(2,:))');

tform = fitgeotrans(movingPoints,fixedPoints,'nonreflectivesimilarity');

Ib_rec = imwarp(Ib,tform);

subplot(1,2,1);imagesc(Ia);
subplot(1,2,2);imagesc(Ib_rec);

subplot(1,2,1);imagesc(Ia);
subplot(1,2,2);imagesc(Ib);



moving  = I_PS;
fixed   = I_NN;

[optimizer,metric]      = imregconfig('multimodal');

movingRegisteredDefault = imregister(moving,fixed,'similarity',optimizer,metric);


I_NN_reg = imregister(I_NN,I_PS,'similarity',optimizer,metric);
I_TF_reg = imregister(I_TF,I_PS,'similarity',optimizer,metric);

I_NN_reg = imregister(I_NN,I_PS,'affine',optimizer,metric);
I_TF_reg = imregister(I_TF,I_PS,'affine',optimizer,metric);

subplot(3,2,1);imshowpair(I_NN_reg,I_PS);
subplot(3,2,2);imshowpair(I_TF_reg,I_PS);

subplot(3,2,3);imagesc(I_PS);axis image
subplot(3,2,4);imagesc(I_NN_reg);axis image

subplot(3,2,5);imagesc(I_PS);axis image
subplot(3,2,6);imagesc(I_TF_reg);axis image

[ssimval,ssimmap] = ssim(I_PS,I_NN_reg);
[ssimval,ssimmap] = ssim(I_PS,I_TF_reg);

scoreNN = multissim(I_PS,I_NN_reg)
scoreTF = multissim(I_PS,I_TF_reg)

imagesc([movingRegisteredDefault fixed]);axis image


%% test fsim 20201022-ish

fsimval = f_fsim( max(Data.PS,[],3), max(DataReg.NN,[],3));
fsimval = f_fsim( max(Data.PS,[],3), max(DataReg.TF,[],3));
