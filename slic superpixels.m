function [cIndMap, time, imgVis] = slic(img, K, compactness)

%% Implementation of Simple Linear Iterative Clustering (SLIC)
%
% Input:
%   - img: input color image
%   - K:   number of clusters
  % K=256;
%   - compactness: the weights for compactness
  %compactness=40;
% Output: 
%   - cIndMap: a map of type uint16 storing the cluster memberships
%     cIndMap(i, j) = k => Pixel (i,j) belongs to k-th cluster
%   - time:    the time required for the computation
%   - imgVis:  the input image overlaid with the segmentation

% Put your SLIC implementation here

tic;
% Input data
K=256;
compactness=40;

%img=imread('15011.jpg');

imgB   = im2double(img);
cform  = makecform('srgb2lab');
imgLab = applycform(imgB, cform);

% Initialize cluster centers (equally distribute on the image). Each cluster is represented by 5D feature (L, a, b, x, y)
% Hint: use linspace, meshgrid
[Ht, Wd, ~] = size(imgB);
disp(size(imgB))
N = Ht*Wd;
S = floor(sqrt(N/K));
cIndMap = zeros(Ht, Wd);
sc = Spatial_Co(imgLab);
[Ht, Wd, ~] = size(imgLab);


x_co = linspace(1, Wd, 2 + sqrt(K));
y_co = linspace(1, Ht, 2 + sqrt(K));
x_co=x_co(2:end-1);
y_co=y_co(2:end-1);
[X, Y] = meshgrid(x_co, y_co);
X = X(:);Y = Y(:);


L = interp2(imgLab(:,:,1), X, Y);
a = interp2(imgLab(:,:,2), X, Y);
b = interp2(imgLab(:,:,3), X, Y);

C = cat(2, L, a, b, X, Y);
dc=compactness^2/S^2;
d = diag([1,1,1,dc,dc]);

plotd = 10000*ones(Ht, Wd);


% SLIC superpixel segmentation
% In each iteration, we update the cluster assignment and then update the cluster center

numIter  = 10; % Number of iteration for running SLIC
for iter = 1: numIter
	% 1) Update the pixel to cluster assignment
	for i = 1: K
        
        c_ct = C(i, :);
   
        cx_fr = floor(c_ct(:,4));
        cy_fr = floor(c_ct(:,5));
        
        Wx=cx_fr-S:cx_fr+S;
        Wy=cy_fr-S:cy_fr+S;
        [X, Y] = meshgrid(Wx, Wy);
      
        X=max(X,1);
        X=min(X,Wd);
        Y=max(Y,1);
        Y=min(Y,Ht);
        sc_index = sub2ind([Ht, Wd], Y(:),X(:));
      
        sc_r = sc(sc_index,:);
        
       %https://www.mathworks.com/help/matlab/ref/bsxfun.html
        Dct = sum(((bsxfun(@minus, c_ct, sc_r)).^2)*d, 2);
      
        d_thd = plotd(sc_index);
        
        new_loc = Dct < d_thd;
        
        new_ind=sc_index(new_loc);
        cIndMap(new_ind) = i;
        plotd(new_ind) = Dct(new_loc);
        
        %figure(1)
        %imagesc(plotd)
       
    end

	% 2) Update the cluster center by computing the mean
    for i = 1: K
        ct_ind = cIndMap == i;
        C(i,:) = mean(sc(ct_ind,:), 1);
    end
end
toc;
time = toc;


% Visualize mean color image
[gx, gy] = gradient(cIndMap);
bMap = (gx.^2 + gy.^2) > 0;
imgVis = imgB;
imgVis(cat(3, bMap, bMap, bMap)) = 1;
figure(1), imshow(imgVis);

cIndMap = uint16(cIndMap);
disp(time)
end

function sc = Spatial_Co(imgLab)

[Ht, Wd, ~] = size(imgLab);
[X, Y] = meshgrid(1:Wd, 1:Ht);
L = imgLab(:,:,1);
a = imgLab(:,:,2);
b = imgLab(:,:,3);
sc = cat(2, L(:), a(:), b(:), X(:), Y(:));

end
