load gs.mat;
load sift_desc;

%for train
d = dir("train\*.jpg");
num_imgs = length(d);
X = int16([]);
for i = 1:num_imgs
    img = im2single(imread(fullfile("train", [num2str(i) '.jpg'])));
    x = randperm(size(train_D{1,i},2),20);
    X = [X,train_D{1,i}(:,x)];
end

C = kcluster(X',25);
C=C';
X = double(X);

for i=1:num_imgs
    x = zeros(600);
    I = knnsearch(C',train_D{1,i}','K',1);
    for j = 1:size(I)
        x(I(j)) = x(I(j))+1;
    end
    lab_ht = x(:,1);
    lab_ht = lab_ht / sqrt(lab_ht' * lab_ht);
    hist1(:,i) = lab_ht;
end
%for test
d = dir("test\*.jpg");
num_imgs = length(d);
 X = int16([]);
for i = 1:num_imgs
    img = im2single(imread(fullfile("train", [num2str(i) '.jpg'])));
    x = randperm(size(test_D{1,i},2),20);
    desc = test_D{1,i}(:,x);
    X = [X,desc];
end
X = double(X);

for i=1:num_imgs
    x  =zeros(600);
    p= test_D{1,i};
    I = knnsearch(C',test_D{1,i}','K',1);
    for j = 1:size(I)
        x(I(j)) = x(I(j))+1;
    end
    lab_ht = x(:,1);
    lab_ht = lab_ht / sqrt(lab_ht' * lab_ht);
    hist2(:,i) = lab_ht;
end

for i = 1:1888
    if(train_gs(1,i) == 1)
        label1(1,i)= 1;
    else
        label1(1,i)= -1;
    end
end
for i = 1:1888
    if(train_gs(1,i) == 2)
        label2(1,i)= 2;
    else
        label2(1,i)= -1;
    end
end
for i = 1:1888
    if(train_gs(1,i) == 3)
        label3(1,i)= 3;
    else
        label3(1,i)= -1;
    end
end
for i = 1:1888
    if(train_gs(1,i) == 4)
        label4(1,i)= 4;
    else
        label4(1,i)= -1;
    end
end
for i = 1:1888
    if(train_gs(1,i) == 5)
        label5(1,i)= 5;
    else
        label5(1,i)= -1;
    end
end
for i = 1:1888
    if(train_gs(1,i) == 6)
        label6(1,i)= 6;
    else
        label6(1,i)= -1;
    end
end
for i = 1:1888
    if(train_gs(1,i) == 7)
        label7(1,i)= 7;
    else
        label7(1,i)= -1;
    end
end
for i = 1:1888
    if(train_gs(1,i) == 8)
        label8(1,i)= 8;
    else
        label8(1,i)= -1;
    end
end

tic;
mdl1 = fitcsvm(hist1',label1);
mdl2 = fitcsvm(hist1',label2);
mdl3 = fitcsvm(hist1',label3);
mdl4 = fitcsvm(hist1',label4);
mdl5 = fitcsvm(hist1',label5);
mdl6 = fitcsvm(hist1',label6);
mdl7 = fitcsvm(hist1',label7);
mdl8 = fitcsvm(hist1',label8);
train_time= toc;

tic;
[~, score1] = predict(mdl1, hist2');
[~, score2] = predict(mdl2, hist2');
[~, score3] = predict(mdl3, hist2');
[~, score4] = predict(mdl4, hist2');
[~, score5] = predict(mdl5, hist2');
[~, score6] = predict(mdl6, hist2');
[~, score7] = predict(mdl7, hist2');
[~, score8] = predict(mdl8, hist2');
test_time = toc;

score = [score1(:,2) score2(:,2) score3(:,2) score4(:,2) score5(:,2) score6(:,2) score7(:,2) score8(:,2)];
label =ones(1,800);
for i=1:800
   [~,I] = max(score(i,:));
   label(1,i)=I;
end
conf_mat = zeros(8,8);
for i = 1:num_imgs
    conf_mat(label(1,i), test_gs(1,i)) = conf_mat(label(1,i), test_gs(1,i)) + 1;
end
disp(conf_mat);
imagesc(conf_mat);
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
