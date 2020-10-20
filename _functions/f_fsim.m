
function fsimval = f_fsim(Ia,Ib)

  Ib = imresize(Ib,size(Ia));

  Ia = rescale(single(Ia));
  Ib = rescale(single(Ib));
  
%   [fa,da] = vl_sift(single(Ia),'PeakThresh',0.01) ;
%   [fb,db] = vl_sift(single(Ib),'PeakThresh',0.01) ;
 
%   [fa,da] = vl_covdet(Ia, 'method', 'HarrisLaplace');
%   [fb,db] = vl_covdet(Ib, 'method', 'HarrisLaplace');

  [fa,da] = vl_covdet(Ia, 'EstimateAffineShape', true);
  [fb,db] = vl_covdet(Ib, 'EstimateAffineShape', true);
  
  [matches, scores] = vl_ubcmatch(da,db) ;

  [drop, perm] = sort(scores, 'descend') ;
  matches = matches(:, perm) ;
  scores  = scores(perm) ;

  figure ; clf ;
  imagesc(cat(2, Ia, Ib)) ; colormap('hot')  

  xa = fa(1,matches(1,:)) ;
  xb = fb(1,matches(2,:)) + size(Ia,2) ;
  ya = fa(2,matches(1,:)) ;
  yb = fb(2,matches(2,:)) ;

  hold on ;
  h = line([xa ; xb], [ya ; yb]) ;
  set(h,'linewidth', 1, 'color', 'b') ;

  vl_plotframe(fa(:,matches(1,:))) ;
  fb(1,:) = fb(1,:) + size(Ia,2) ;
  vl_plotframe(fb(:,matches(2,:))) ;
  axis image off ;

  % FSIM value
  % < wtite the function for ssim value >
  fsimval = 0; % dummy value  
  
end