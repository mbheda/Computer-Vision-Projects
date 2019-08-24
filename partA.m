close all;


d = dir("train\*.jpg");
num_imgs = length(d);
 
for i = 1:num_imgs
    img = im2single(imread(fullfile("train", [num2str(i) '.jpg'])));
    im(i)= {img}
end

k=8; 
load gs.mat;


hist_train=cell(1888,3);
for i=1:1888
   
    im_r=im{i}(:,:,1);
    im_g=im{i}(:,:,2);
    im_b=im{i}(:,:,3);
    
    im_r1=reshape(im_r,[],1);
    im_g1=reshape(im_g,[],1);
    im_b1=reshape(im_b,[],1);
    
    hist_train{i,1}=hist(im_r1,50);
    hist_train{i,2}=hist(im_g1,50);
    hist_train{i,3}=hist(im_b1,50);
    
end

d = dir("test\*.jpg");
num_imgs = length(d);
label=zeros(800,1);

for i = 1:num_imgs
    img = im2single(imread(fullfile("test", [num2str(i) '.jpg'])));
    im_test(i)= {img}
end

hist_test=cell(800,3);
for i=1:800

dist=zeros(1888,1);    
    
    im_r=im_test{i}(:,:,1);
    im_r1=reshape(im_r,[],1);
   
    im_g=im_test{i}(:,:,2);
    im_g1=reshape(im_g,[],1);
   
    im_b=im_test{i}(:,:,3);
    im_b1=reshape(im_b,[],1);
    
    hist_test{i,1}=hist(im_r1,50);
    hist_test{i,2}=hist(im_g1,50);
    hist_test{i,3}=hist(im_b1,50);

        for j=1:1888
            dist(j)=sum(((hist_train{j,1}-hist_test{i,1}).^2)+((hist_train{j,2}-hist_test{i,2}).^2)+((hist_train{j,3}-hist_test{i,3}).^2));
        end
        
        [B,I]=sort(dist);
      

label(i)=mode(train_gs(I(1:k)));
end


g1=test_gs';
g2=label;

Conf_mat = confusionmat(g1,g2);
accuracy= sum(diag(Conf_mat))/800;
imagesc(Conf_mat);




