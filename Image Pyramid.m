N = 5;
% Load an image

im=im2double(imread('car.jpg'));
img=rgb2gray(im);



[G, L] = pyramidsGL(img, N);



% Display the Gaussian and Laplacian pyramid
displayPyramids(G, L);





function [G, L] = pyramidsGL(img, N)
% [G, L] = pyramidsGL(im, N)
% Creates Gaussian (G) and Laplacian (L) pyramids of level N from image im.
% G and L are cell where G{i}, L{i} stores the i-th level of Gaussian and Laplacian pyramid, respectively. 

%Setting cut off frequency of the filter
cutoff_frequency = 3;
filter = fspecial('Gaussian', cutoff_frequency*4+1, cutoff_frequency/3);

G{1}=img;
 for i=1:N
   G{i+1}= imfilter(imresize(G{i},0.5, 'nearest'),filter);

%Upscaling the image
temp = imfilter(imresize(G{i+1}, 2, 'nearest'), filter);

%Laplacian Pyramid
L{i} = mat2gray(G{i} - temp);


     
 end 
end

function displayPyramids(G, L)
% Displays intensity and fft images of pyramids

figure; 
ha = tight_subplot(2,5,[.01 .03],[.1 .03],[.01 .03]);
         for ii = 1:5
             axes(ha(ii));
             imshow(G{ii});
             axes(ha(ii+5));
             imshow(L{ii});
             
   
         end
         set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')
end

function displayFFT(G,L)
% Displays FFT images


figure;
 imagesc(log(abs(fftshift(fft2(G)))))
 figure;
imagesc(log(abs(fftshift(fft2(L)))))


end
