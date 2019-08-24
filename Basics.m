clear all
img_name = 'hokiebird.jpg';
img = imread(img_name);
%Solution 1
imgR=img(:,:,1);
imgG=img(:,:,2);
imgB=img(:,:,3);
a=[imgR(250,:)]
b=[imgG(250,:)]
c=[imgB(250,:)]
figure()
subplot(2,2,1); plot(a); title('Red channel',   'FontSize', 20);
subplot(2,2,2); plot(b); title('Green channel',   'FontSize', 20);
subplot(2,2,3); plot(c); title('Blue channel',   'FontSize', 20);

%Solution 2

imgcombine = [imgR; imgG ; imgB] 
figure()
imshow(imgcombine);

%Solution 3
newimg(:,:,1)=img(:,:,2);
newimg(:,:,2)=img(:,:,1);
newimg(:,:,3)=img(:,:,3);
figure()
imshow(newimg);

%Solution 4
I= rgb2gray(img);
figure()
imshow(I);

%Solution 5
Rave=im2double(imgR);
Gave=im2double(imgG);
Bave=im2double(imgB);
Iave=(Rave+Gave+Bave)/3;
figure()
imshow(Iave);

%Solution 6
Ineg=imcomplement(I);
figure()
imshow(Ineg);

%Solution 7
Icrop=imcrop(img,[0 0 372 372]);
Icrop_90=imrotate(Icrop, 90);
Icrop_180=imrotate(Icrop, 180);
Icrop_270=imrotate(Icrop, 270);
figure()
subplot(2,2,1); imshow(Icrop); title('Cropped 0 degree',  'FontSize', 15);
subplot(2,2,2); imshow(Icrop_90); title('Cropped 90 degree','FontSize', 15);
subplot(2,2,3); imshow(Icrop_180); title('Cropped 180 degree','FontSize', 15);
subplot(2,2,4); imshow(Icrop_270); title('Cropped 270 degree','FontSize', 15);

%Solution 8
img2=zeros(372,600);


for i=1:372;
 for j=1:600;
  if img(i,j)>127;   
      img2(i,j)=255;
  else
      img2(i,j)=img(i,j);
      
   end
  end
end
figure()
imshow(img2);

%Solution 9
B=zeros(372,600);
ind = find(img2 > 127);
B(ind)=img2(ind);

temp = im2double(B);

img2R=temp(:,:,1);
img2G=temp(:,:,2);
img2B=temp(:,:,3);

meanR = mean2(img2R);
disp(meanR);
meanG = mean2(img2G);
disp(meanG);
meanB = mean2(img2B);
disp(meanB);

%Solution 10
imggray=rgb2gray(newimg);
figure()
imshow(imggray);
imggray2=zeros(372,600);
for i=1:368;
 for j=1:596;
     centre = imggray(i+1,j+1);
     maxval = centre;
   for m=i:i+4;
     for n=j:j+4;
         
     if  maxval > imggray(m,n);
         maxval = imggray(m,n);
     
     end
   end
   if maxval == centre;
       imggray2(i+1,j+1) = 255;
   end
   end
 end
end

figure()
imshow(imggray2);













