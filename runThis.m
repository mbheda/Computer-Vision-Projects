function featureMatching
% Matching SIFT Features

im1 = imread('stop1.jpg');
im2 = imread('stop2.jpg');

load('SIFT_features.mat'); % Load pre-computed SIFT features
% Descriptor1, Descriptor2: SIFT features from image 1 and image 2
% Frame1, Frame2: position, scale, rotation of keypoints
% YOUR CODE HERE
a_temp = Descriptor1;
b_temp = Descriptor2;
c = zeros(597,2397);

for k = 1:597
     a = a_temp(:,k);

 for j = 1:2397
     b = b_temp(:,j);
     
  for i = 1:128
     c(k,j) = (sum((a(i)- b(i)).^2)).^0.5;
    
   
  end
 end 
 
end 

[M1,I1] = min(c,[],2);
[M2,I2] = 
matches= zeros(2,N);
 
 N = 1;
 t=0.7;
 for h=1:597
    if M1(h)/M2(h)<t
       matches()     
       N = N+1; 
    end
 end
% 
% 
% 
% % matches: a 2 x N array of indices that indicates which keypoints from image
% % 1 match which points in image 2
% 
% % Display the matched keypoints
% figure(1), hold off, clf
% plotmatches(im2double(im1),im2double(im2),Frame1,Frame2,matches);