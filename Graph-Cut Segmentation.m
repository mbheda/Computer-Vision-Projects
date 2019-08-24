% Add path
addpath(genpath('GCmex1.5'));
im = im2double( imread('cat.jpg') );

org_im = im;

H = size(im, 1); W = size(im, 2); K = 3;

% Load the mask
load cat_poly
inbox = poly2mask(poly(:,1), poly(:,2), size(im, 1), size(im,2));

% 1) Fit Gaussian mixture model for foreground regions
g1 = {};
L=logical(inbox);
for i=1:K
  rgb=im(:,:,i); 
  g1{i} = rgb(L);
end
g1 = cell2mat(g1);
gmm1 = gmdistribution.fit(g1, 4);
pm1 = pdf(gmm1, reshape(im, [H*W 3]) );
pm1 = reshape(pm1, [H W] );


% 2) Fit Gaussian mixture model for background regions
g2 = {};
for i=1:K
  rgb=im(:,:,i);
  g2{i} = rgb(~L);
end
g2 = cell2mat(g2);
gmm2 = gmdistribution.fit(g2, 6);
pm2 = pdf(gmm2, reshape(im, [H*W 3]) );
pm2 = reshape(pm2, [H W] );
% 3) Prepare the data cost
% - data [Height x Width x 2] 
% - data(:,:,1) the cost of assigning pixels to label 1
% - data(:,:,2) the cost of assigning pixels to label 2
data = cat(3, -log(pm1), -log(pm2));
% 4) Prepare smoothness cost
% - smoothcost [2 x 2]
% - smoothcost(1, 2) = smoothcost(2,1) => the cost if neighboring pixels do not have the same label
smoothcost = [0 1; 1 0];
% 5) Prepare contrast sensitive cost
% - vC: [Height x Width]: vC = 2-exp(-gy/(2*sigma)); 
% - hC: [Height x Width]: hC = 2-exp(-gx/(2*sigma));
sigma = .01;
gx = {};
gy = {};

for i=1:K
  [gx{i}, gy{i}] = gradient(im(:,:,i));
end
gx = sum(cat(3, gx{:}).^2, 3);
gy = sum(cat(3, gy{:}).^2, 3);
vC = 2-exp(-gy/(2*sigma));
hC = 2-exp(-gx/(2*sigma));
% 6) Solve the labeling using graph cut
% - Check the function GraphCut
gch = GraphCut('open', data, smoothcost, vC, hC);
%gch = GraphCut('open', data, sc);
[gch labels] = GraphCut('expand', gch);

% 7) Visualize the results
figure()
subplot(1,2,1);
imagesc(log(pm1), [-3 3])
subplot(1,2,2);
imagesc(log(pm2), [-7 7]) 

labels=labels==1;
im1=im(:,:,1);
im1(labels)=0;
im2=im(:,:,2);
im2(labels)=0;
im3=im(:,:,3);
im3(labels)=1;
figure();
imgGC=cat(3, im1, im2, im3);
imshow(imgGC);
