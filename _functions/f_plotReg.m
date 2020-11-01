
function f_plotReg(X0,X1,X1_reg,saveName,imageType)

  % visualize registartion for the figure 
  figure('units','normalized','outerposition',[0 0 1 1])                
  tlo = tiledlayout(2,4,'TileSpacing','none','Padding','none');
  nexttile, imagesc   (       max(X0,    [],3))                      ;  title('PS');                axis image;axis off;
  nexttile, imagesc   (       max(X1,    [],3))                      ;  title(imageType);           axis image;axis off;
  nexttile, imshowpair(       max(X1,    [],3),        max(X0,[],3)) ;  title('overlay');
  nexttile, imshowpair(histeq(max(X1,    [],3)),histeq(max(X0,[],3)));  title('overlay(eqHist)');
  nexttile, imagesc   (       max(X0,    [],3))                      ;  title('PS');                axis image;axis off;
  nexttile, imagesc   (       max(X1_reg,[],3))                      ;  title([imageType ' reg']);  axis image;axis off;
  nexttile, imshowpair(       max(X1_reg,[],3),        max(X0,[],3)) ;  title('overlay')
  nexttile, imshowpair(histeq(max(X1_reg,[],3)),histeq(max(X0,[],3)));  title('overlay(eqHist)')
  set(tlo.Children,'XTick',[], 'YTick', [],'fontsize',20);
  saveas(gcf,saveName);

  close all
end