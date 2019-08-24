load gs.mat;
load sift_desc;
%for train
d = dir("train\*.jpg");
num_imgs = length(d);
X = int16([]);
for i = 1:num_imgs
    img_1 = im2single(imread(fullfile("train", [num2str(i) '.jpg'])));
    x = randperm(size(train_D{1,i},2),20);
    X = [X,train_D{1,i}(:,x)];
end
C = kcluster(X',25);
C=C';
X = double(X);
for i=1:num_imgs
    x  =zeros(105);
    I = knnsearch(C',train_D{1,i}','K',1);
    for j = 1:size(I)
        x(I(j)) = x(I(j))+1;
    end
    lab_ht = x(:,1);
    hist1(:,i) = lab_ht / sqrt(lab_ht' * lab_ht);
end
d = dir("test\*.jpg");
num_imgs = length(d);
 X = [];
for i = 1:num_imgs
    img_1 = im2single(imread(fullfile("test", [num2str(i) '.jpg'])));
    x = randperm(size(test_D{1,i},2),20);
    X = [X,test_D{1,i}(:,x)];
    
end
%for test
X = double(X);

for i=1:num_imgs
    x  =zeros(105);
    I = knnsearch(C',test_D{1,i}','K',1);
    for j = 1:size(I)
        x(I(j)) = x(I(j))+1;
    end
    lab_ht = x(:,1);
    hist2(:,i) = lab_ht / sqrt(lab_ht' * lab_ht);
end

I = knnsearch(hist1',hist2', 'K',10);
conf_mat = zeros(8,8);
    for i = 1:num_imgs
        for j=1:8
            vote(j)=train_gs(1,I(i,j));
            label(1,i) = mode(vote);
        end
        conf_mat(label(1,i), test_gs(1,i)) = conf_mat(label(1,i), test_gs(1,i)) + 1;
    end

        %g1=label;
        %g2=(test_gs)';
        %conf_mat=confusionmat(g2,g1);
disp(conf_mat);
imagesc(conf_mat)
accuracy = sum(diag(conf_mat))/800;
disp(accuracy)

function C = kcluster(X, K)
% Initialize cluster centers to be randomly sampled points
[N, d] = size(X);
rp = randperm(N);
C = X(rp(1:K), :);
lastAssignment = zeros(N,1);
bestAssignment = zeros(N, 1);
mindist = Inf*ones(N, 1);
while true
  % Assign each point to nearest cluster center
  for k = 1:K
    for n = 1:N
      dist = sum((X(n, :)-C(k, :)).^2);
      if dist < mindist(n)
        mindist(n) = dist;
        bestAssignment(n) = k;
      end
    end
  end
  % Assign each cluster center to mean of points within it
  for k = 1:K
    C(k, :) = mean(X(bestAssignment==k, :));
  end
  if(bestAssignment == lastAssignment)
   % break if assignment is unchanged  
  break
  end
  lastAssignment = bestAssignment;
end
end