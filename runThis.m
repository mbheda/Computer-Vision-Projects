function F = HW3_SfM
close all;

folder = 'images/';
im = readImages(folder, 0:50);

load './tracks.mat';


figure(2), imagesc(im{1}), hold off, axis image, colormap gray
hold on, plot(track_x', track_y', 'r')
figure(3), imagesc(im{end}), hold off, axis image, colormap gray
hold on, plot(track_x', track_y', 'r')
%pause;

valid = ~any(isnan(track_x), 2) & ~any(isnan(track_y), 2); 

[R, S] = affineSFM(track_x(valid, :), track_y(valid, :));

plotSfM(R, S);



function [R, S] = affineSFM(x, y)

% Normalize x, y to zero mean
[nf, nc] = size(x);
%disp(nc)
%disp(nf)
x_m = mean(x,1);
y_m = mean(y,1);
%Normalized values
xn = x - repmat(x_m, [size(x(:,1)) 1]); 
yn = y - repmat(y_m, [size(x(:,1)) 1]); 

% Create measurement matrix
D = [xn' ; yn'];


%svd on D
[U, W, V] = svd(D) ;
U_svd= U(:,1:3);
W_svd= W(1:3,1:3);
V_svd= V(:,1:3)';
R = U_svd*sqrt(W_svd);
S = sqrt(W_svd)*V_svd;

% Apply orthographic constraints
%a1'CC'a2=0
%A= 3rows X No of cameras
A = zeros(153, 9);
b = zeros(153, 1);

for i = 1:51
    
    a1= R(i,:);
    a2= R(i+51,:);
    b = repmat([1;1;0],51,1);
    A(3*i, :) = reshape(a1'*a2, [1 9]);
    A(3*i-1, :) = reshape(a2'*a2, [1 9]);
    A(3*i-2, :) = reshape(a1'*a1, [1 9]);
    
    %L is  a 9X1 matrix=>Reshape
    L = reshape(A\b, [3 3]);
    
end

C = chol(L);
R = R*C;
S = inv(C)*S;

function im = readImages(folder, nums)
im = cell(numel(nums),1);
t = 0;
for k = nums,
    t = t+1;
    im{t} = imread(fullfile(folder, ['hotel.seq' num2str(k) '.png']));
    im{t} = im2single(im{t});
end
