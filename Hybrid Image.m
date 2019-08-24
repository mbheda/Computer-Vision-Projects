im1 = im2single(imread('einstein.bmp'));
im2 = im2single(imread('marilyn.bmp'));
image1 = rgb2gray(im1);
image2 = rgb2gray(im2);
cutoff_frequency = 7;
filter = fspecial('Gaussian', cutoff_frequency*4+1, cutoff_frequency/3.5);
a= imfilter(image2,filter);
figure()
imshow(a);

b= imfilter(image1,filter);
b2=image1-b;
figure();
imshow(b2+0.5);
hybrid_image=a+b2;
vis = vis_hybrid_image(hybrid_image);
figure()
imshow(hybrid_image);
figure()
imshow(vis);
figure()
imagesc(log(abs(fftshift(fft2(hybrid_image)))))
figure()
imagesc(log(abs(fftshift(fft2(image1))))) 
figure()
imagesc(log(abs(fftshift(fft2(image2)))))
figure()
imagesc(log(abs(fftshift(fft2(a)))))
figure()
imagesc(log(abs(fftshift(fft2(b)))))


imwrite(a, 'low_frequencies.jpg', 'quality', 95);
imwrite(b2 + 0.5, 'high_frequencies.jpg', 'quality', 95);
imwrite(hybrid_image, 'hybrid_image.jpg', 'quality', 95);
imwrite(vis, 'hybrid_image_scales.jpg', 'quality', 95);








function output = vis_hybrid_image(hybrid_image)
scales = 5; %how many downsampled versions to create
scale_factor = 0.5; %how much to downsample each time
padding = 5; %how many pixels to pad.

original_height = size(hybrid_image,1);
num_colors = size(hybrid_image,3); %counting how many color channels the input has
output = hybrid_image;
cur_image = hybrid_image;

for i = 2:scales
    %add padding
    output = cat(2, output, ones(original_height, padding, num_colors));
    
    %dowsample image;
    cur_image = imresize(cur_image, scale_factor, 'bilinear');
    %pad the top and append to the output
    tmp = cat(1,ones(original_height - size(cur_image,1), size(cur_image,2), num_colors), cur_image);
    output = cat(2, output, tmp);    
end



end

