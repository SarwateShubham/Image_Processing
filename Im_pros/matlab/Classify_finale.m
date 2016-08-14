close all;


MRI_PREFIX = 'D:\Resources\Stud\MY PROJECTS\DSP Project\lab3files\data\case1\case1\005\slice';
LABELS_PREFIX = 'D:\Resources\Stud\MY PROJECTS\DSP Project\lab3files\data\case1\case1\seg_yoh\output';
% training data
% 34 training pics
TRAINING_SLICES = 30:64;
%choosing 20 slices for testing
TEST_SLICES = 1:26;
CLASSIFICATION_PREFIX='D:\Resources\Stud\MY PROJECTS\DSP Project\Output\classification';



% Read and display an MRI slice and its segmentation
SLICE_NUM = 45; %slice number of the image to plot
mri_fn = sprintf('%s.%0.3d', MRI_PREFIX, SLICE_NUM);
img = mri_read(mri_fn); %% read the mri image into img
%creating the name of the file labeled by the expert to read
labels_fn = sprintf('%s.%0.3d', LABELS_PREFIX, SLICE_NUM);
labels = mri_read(labels_fn); %% read the labelled img into labels



% Display img using a grayscale colormap
figure; imagesc(img); colormap(gray);
title(mri_fn); axis off; colorbar;
figure; imagesc(labels); colormap('default');
title(labels_fn); axis off; colorbar;
pause;



%conditional probability models
LABEL_WHITE = 8;
LABEL_GRAY = 4;
LABEL_CSF = 5;
NUM_LABELS = 3;
colors = {'g', 'r', 'b', 'm'};

%% Training Data


%intensities of various feaatures
intensity_white = [];
intensity_gray = [];
intensity_csf = [];


for i=TRAINING_SLICES
    mri_fn = sprintf('%s.%0.3d', MRI_PREFIX, i)
    img = mri_read(mri_fn);
    labels_fn = sprintf('%s.%0.3d', LABELS_PREFIX, i);
    labels = mri_read(labels_fn);
    intensity_white = [intensity_white; img(find(labels == LABEL_WHITE))];
    intensity_gray = [intensity_gray; img(find(labels == LABEL_GRAY))];
    intensity_csf = [intensity_csf; img(find(labels == LABEL_CSF))];
end
tissue_means = [ mean(intensity_white) mean(intensity_gray) mean(intensity_csf)];
tissue_vars = [ var(intensity_white) var(intensity_gray) var(intensity_csf)];

%gaussian function
gauss = inline('(1/(sqrt(2*pi)*s))*exp(-(x-m).*(x-m)/(2*s*s))', 'x','m','s');

%Visualizing the different pdfs of tissues
figure;
plot(0:100,gauss(0:100, tissue_means(1), sqrt(tissue_vars(1))), 'k',0:100,gauss(0:100, tissue_means(2), sqrt(tissue_vars(2))),'r',0:100,gauss(0:100, tissue_means(3), sqrt(tissue_vars(3))), 'b');
title('Gaussian pdfs for all tissue');
legend('white pdf','Gray pdf','Csf pdf');





%% Classifying the testing set MRI scans from the Bayesian classifiers trained according to the above training set.


figure(7); figure(8); 
set(1, 'nextplot', 'replace') %set the names for figure 1



for i=TEST_SLICES
    mri_fn = sprintf('%s.%0.3d', MRI_PREFIX, i)
    img = mri_read(mri_fn);
    for k=1:NUM_LABELS
        w(:,k) = gauss(img(:), tissue_means(k), sqrt(tissue_vars(k)));
    end
    
    % Display the tissue likelihoods for the pixels in the slice
    if 1
        figure(9);
        imagesc([reshape(w(:,1), size(img));reshape(w(:,2), size(img));reshape(w(:,3), size(img))]);
        colormap(gray)
        title('tissue likelihoods');
    end
    
    
    
    
    %Classification of the pixels according to the classifier trained above
    classification=zeros(size(img));
    % order in w white gray csf
    classificationt = (w(:,1)>w(:,2)&w(:,1)>w(:,3))*LABEL_WHITE + (w(:,2)>w(:,1)&w(:,2)>w(:,3))*LABEL_GRAY + (w(:,3)>w(:,2)&w(:,3)>w(:,1))*LABEL_CSF;
    %converting the image from a vector to a 256x256 matrix
    for z = 1:256,
        classification(:,z) = classificationt(256*(z-1)+1:z*256);
    end
    
    %pause; 
end

    figure(7); imagesc(img); colormap(gray); colorbar;title(mri_fn); axis off;
    figure(8); imagesc(classification); colormap('default'); colorbar; title(mri_fn); axis off;
    % Write out the classification for use downstream
    out_fn = sprintf('%s.%0.3d', CLASSIFICATION_PREFIX, i);
    mri_write(classification, out_fn);