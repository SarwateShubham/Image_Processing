close all;
img = mri_read('D:\Resources\Stud\MY PROJECTS\DSP Project\lab3files\data\sw\spgr\I.082');

figure;
display_image(img, 'original image');
figure;
% white matter thresholded =65
display_image(img > 65, 'thresholded at 65');


%Gaussian filter of sigma 1 and H size= 5
gf = fspecial('gauss', 3, 1);
%filtering the image with the 2D gaussian filter
blur_img = filter2(gf, img, 'same');
figure;
display_image(blur_img,'blurred Image with sigma = 1');
figure;
display_image(blur_img > 65,'thresholded filtered image of sigma=1');



% Median filtering
mf_img = medfilt2(img, [3 3]);
figure;
display_image(mf_img,'Image filtered with the median filter of order = 3');
figure;
display_image(mf_img > 65,'thresholded median filtered image with 3x3 filter');
