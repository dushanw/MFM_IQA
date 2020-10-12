% main_psf


Nx = 50;
Ny = 50;
Nz = 50;
dx = .2;        % [um] pixel size 
lambda = 520;   % [nm]
NA = 1;
Rindex = 1;

APSF_3D = Efficient_PSF(NA,Rindex,lambda,dx,Nx,Ny,Nz);
PSF_3D = abs(APSF_3D{1}).^2+abs(APSF_3D{2}).^2+abs(APSF_3D{3}).^2;

save(sprintf('APSF_3D_%dNA_1RI_%dumdx.mat',NA,dx),'APSF_3D');
%save(sprintf('PSF_3D_%dNA_1RI_%dumdx.mat',NA,dx),'PSF_3D');

imagesc(PSF_3D(:,:,25))
imagesc([abs(APSF_3D{1}(:,:,25))+abs(APSF_3D{2}(:,:,25))+abs(APSF_3D{3}(:,:,25))])

%% example of convolving with a phase mask
A_phase = rand(10,10);
A_phase = imresize(A_phase,[size(APSF_3D{1},1) size(APSF_3D{1},1)]);
C_phase = zeros(size(APSF_3D{1}));
C_phase(:,:,end/2) = 1*exp(j*A_phase);

Ex = convn(C_phase,APSF_3D{1},'same');
Ey = convn(C_phase,APSF_3D{2},'same');
Ez = convn(C_phase,APSF_3D{3},'same');

dc = 50
I = abs(Ex+dx).^2+abs(Ey+dc).^2+abs(Ez+dc).^2;



subplot(1,2,1);imagesc(A_phase);
subplot(1,2,2);imagesc(I(:,:,round(end/2)));% intensity pattern on the focal plane





