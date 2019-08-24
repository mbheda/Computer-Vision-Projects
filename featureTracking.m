function featureTracking
% Main function for feature tracking
folder = '.\images';
im = readImages(folder, 0:50);

tau = 0.06;                                 % Threshold for harris corner detection
[pt_x, pt_y] = getKeypoints(im{1}, tau);    % Prob 1.1: keypoint detection

ws = 7;                                     % Tracking ws x ws patches
[track_x, track_y] = ...                    % Keypoint tracking
    trackPoints(pt_x, pt_y, im, ws);
  
% Visualizing the feature tracks on the first and the last frame
figure(2), imagesc(im{1}), hold off, axis image, colormap gray
hold on, plot(track_x', track_y', 'r','linewidth',1.5 );
figure(3), imagesc(im{end}), hold off, axis image, colormap gray
hold on, plot(track_x', track_y', 'r', 'linewidth',1.5);


function [track_x, track_y] = trackPoints(pt_x, pt_y, im, ws)
% Tracking initial points (pt_x, pt_y) across the image sequence
% track_x: [Number of keypoints] x [2]
% track_y: [Number of keypoints] x [2]

% Initialization
N = numel(pt_x);
nim = numel(im);
track_x = zeros(N, nim);
track_y = zeros(N, nim);
track_x(:, 1) = pt_x(:);
track_y(:, 1) = pt_y(:);
%tracking points from t to t+1
for t = 1:nim-1
    [track_x(:, t+1), track_y(:, t+1)] = ...
            getNextPoints(track_x(:, t), track_y(:, t), im{t}, im{t+1}, ws);
end


function [x2, y2] = getNextPoints(x, y, im1, im2, ws)
% Iterative Lucas-Kanade feature tracking
% x,  y : initialized keypoint position in im2
% x2, y2: tracked keypoint positions in im2
% ws: patch window size

% YOUR CODE HERE
x2 = x;
y2 = y;

hw = floor(ws/2);
%to get patch index
[X, Y] = meshgrid(-hw:hw, -hw:hw);
X = X(:);
Y = Y(:);

cutoff_frequency = 3;
filter = fspecial('gaussian', cutoff_frequency, 1);
%Compute gradients from Im1 (get Ix and Iy)
Img_filt = imfilter(im1, filter);
[Gx,Gy] = gradient(Img_filt); 


%Get displacement with meshgrid and add to current patch
%idea from Piazza Discussions
x_win1 = repmat(x,[1 numel(X)])';
y_win1 = repmat(y,[1 numel(Y)])';
x_win2 = repmat(X',[numel(x) 1])';
y_win2 = repmat(Y',[numel(y) 1])';
x_win = x_win1 + x_win2;
y_win = y_win1 + y_win2;

valid_temp = ~isnan(x) & x>=hw & y>=hw & x+hw<=size(im1,1) & y+hw<=size(im1,1);
Ix_sum = zeros(size(x_win));
Iy_sum = zeros(size(x_win));
patch_sum1 = zeros(size(x_win));

%use “interp2” to sample non-integer positions.
%patch= interp2(im,X,Y).
patch_sum1(:, valid_temp) = interp2(im1, x_win(:, valid_temp), y_win(:, valid_temp),'bilinear');

Ix_sum(:, valid_temp) = interp2(Gx, x_win(:, valid_temp), y_win(:, valid_temp),'bilinear');
Iy_sum(:, valid_temp) = interp2(Gy, x_win(:, valid_temp), y_win(:, valid_temp),'bilinear');

for iter = 1:5

    %Check if tracked patch are outside the image. Only track valid patches.
    valid = valid_temp & x2>=hw  & y2>=hw & x2+hw<=size(im2,1) & y2+hw<=size(im2,1);
    
    x2_win1 = repmat(x2, [1 numel(X)])';
    y2_win1 = repmat(y2, [1 numel(Y)])';
    x2_win2 = repmat(X', [numel(x) 1])';
    y2_win2 = repmat(Y', [numel(y) 1])';
    x2_win = x2_win1 + x2_win2;
    y2_win = y2_win1 + y2_win2;
    
    patch_sum2 = zeros(size(patch_sum1));
    %use “interp2” to sample non-integer positions.
    patch_sum2(:, valid) = interp2(im2, x2_win(:, valid), y2_win(:, valid), 'bilinear');    
    
    
       for p = 1:numel(x)

           if ~valid(p)
           continue;
   
           end
        
        Ix = Ix_sum(:, p);
        Iy = Iy_sum(:, p);
        Ixy= Ix.*Iy;
        
        patch1 = patch_sum1(:, p);
        patch2 = patch_sum2(:, p);       
        
        % compute It = patch2 – patch1
        It = patch2-patch1;
        %Set up matrix A and vector b
        A = [sum(Ix.^2) sum(Ixy) ;
             sum(Ixy) sum(Iy.^2)];
        b = -[sum(Ix .* It) ;
            sum(Iy.*It)];
        %Solve linear system d = A\b. 
        d = A\b; 
        x2(p)=x2(p)+d(1);
        y2(p)=y2(p)+d(2);        
          
    end
end


function im = readImages(folder, nums)
im = cell(numel(nums),1);
t = 0;
for k = nums,
    t = t+1;
    im{t} = imread(fullfile(folder, ['hotel.seq' num2str(k) '.png']));
    im{t} = im2single(im{t});
end
