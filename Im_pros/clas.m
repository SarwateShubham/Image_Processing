close all;
%we have 124 MRI images of the head of a person in the oo5 directory named slice.001 thru slice.124
MRI_PREFIX = 'C:\Users\lullichoti\Desktop\DSP Project\lab3files\data\swrot\spgr\I';
%we also have 124 classified images by an expert named output.001 to output.124
LABELS_PREFIX = 'C:\Users\lullichoti\Desktop\DSP Project\lab3files\data\swrot\segtruth\I';
%choosing the slices that are going to be used as trining data. In this case, just
% 8 images 30 32 34 36 38 40 42 44
TRAINING_SLICES = [30:2:44];
%choosing 39 slices for testing purposes.
TEST_SLICES = [26:64];
%defining the name of the files for our classification output
CLASSIFICATION_PREFIX='C:\Users\lullichoti\Desktop\DSP Project\Output';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read and display an MRI slice and its segmentation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SLICE_NUM = 45; %slice number of the image to plot
%% create the filename corresponding to the prefix and slice number
%creating the name of the file to read
mri_fn = sprintf('%s.%0.3d', MRI_PREFIX, SLICE_NUM);
img = mri_read(mri_fn); %% read the mri image into img
%creating the name of the file labeled by the expert to read
labels_fn = sprintf('%s.%0.3d', LABELS_PREFIX, SLICE_NUM);
labels = mri_read(labels_fn); %% read the labelled img into labels
%% Display img using a grayscale colormap
%% and labels using the default colormap
figure; imagesc(img); colormap(gray);
title(mri_fn); axis off; colorbar;
figure; imagesc(labels); colormap('default');
title(labels_fn); axis off; colorbar;
%disp('hit Control-C')
%pause;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Next we will take some statistics on the
% intensities and build some class-conditional
% probability models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LABEL_WHITE = 8;
LABEL_GRAY = 4;
LABEL_CSF = 5;
NUM_LABELS = 3;
colors = {'g', 'r', 'b', 'm'};
%% The following vectors will eventually hold all of the intensity
%% values observed in the training data for their respective tissue
%% classes.
intensity_white = [];
intensity_gray = [];
intensity_csf = [];
% The following loops over the training slices and collects
% the intensity values that correspond to each tissue class
for i=TRAINING_SLICES
 %% read mri image
 mri_fn = sprintf('%s.%0.3d', MRI_PREFIX, i)
 img = mri_read(mri_fn);
 %% read corresponding labelled img
 labels_fn = sprintf('%s.%0.3d', LABELS_PREFIX, i);
 labels = mri_read(labels_fn);
 %% concatenate in the observed intensity values in this slice
 intensity_white = [intensity_white; img(find(labels == LABEL_WHITE))];
 intensity_gray = [intensity_gray; img(find(labels == LABEL_GRAY))];
 intensity_csf = [intensity_csf; img(find(labels == LABEL_CSF))];
end
% Here is an example of how to display a histogram of the intensities observed
% as white matter
figure;
hist(intensity_white); title('White Matter Histogram');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%% Question 5.
%% TURN IN:
%%
%% Histogramming is one approach to estimating probability density functions (PDFs).
%% If you inspect the histogram plotted above, you may notice that
%% it is not a legitimage PDF, because, when viewed as a function over
%% the real line, it does not integrate to one.
%%
%% Your task in this problem is to implement a histogram based estimate of
%% the PDF for the intensity of white matter in the training data.
%%
%% Your implementation will probably need to construct Matlab
%% function that has two parts,
%% one that constructs the state of the histogram from the training data,
%% by, among other things, establishing an array of "bins" and
%% counting the number of training data points that fall into each bin.
%% (You may want to look at the documentation for the Matlab function "hist").
%%
%% The other part would implement the PDF itself as a function from real-valued
%% intensities to probability density. In this situation, each bin will
%% corresponds to a range of intensity values. Keep in mind that probability density
%% must be non-negative, and the PDF must integrate to one.
%%
%%
%% There is some freedom available in making histograms, for example the
%% choice of the number of bins. Plot your histogram-based PDF with
%% several choices for bin count. Pick your favorite count,
%% say why you think it is a good choice, and turn in
%% the corresponding plot.
%%
%%
%% In designing the code for this example, you might find it useful to
%% refer to the documentation for the Matlab function "hist".
%%
%% Write a .m file that implements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
% here is an example of plotting our PDF
IntensityValues = [1:.01:100];%range of values that we wish our new pdf function to have in x axis
figure;
plot( IntensityValues, HistPDF(IntensityValues, intensity_white, 20));title('White matter histogrampdf');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%
%% Next we will estimate Gaussian class conditional models that are meant
%% to capture the way the intensities depend on tissue class.
%%
%% The vectors below, "tissue_means" and "tissue_vars"
%% will eventually hold the estimated tissue class mean and variance
%% parameters for the estimated Gaussian densities, indexed by tissue
%% being white, gray, or csf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
tissue_means = [ mean(intensity_white) mean(intensity_gray) mean(intensity_csf)];
tissue_vars = [ var(intensity_white) var(intensity_gray) var(intensity_csf)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%% Question 6.
%% TURN IN:
%%
%% Your next task is to implement the maximum likelihood method for estimating
%% the parameters of Gaussian class conditional densities.
%%
%% You will need to set the two vectors defined above with three values
%% each that are derived from the observed class conditional intensities:
%% intensity_white, intensity_gray, and intensity_csf. Turn in your
%% lines of code that set values for "tissue_means" and "tissue_vars"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%% Define the Gaussian density function
gauss = inline('(1/(sqrt(2*pi)*s))*exp(-(x-m).*(x-m)/(2*s*s))', 'x','m','s');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%% Question 7.
%% TURN IN:
%%
%% At this point we have estimated tissue class conditional PDFs
%% on intensity by the use of Gaussian models.
%% This was done by using the ML method
%% to estimate the mean and variance parameters for each class, based
%% on the training intensities.
%%
%% These Gaussian models may be visualized by plotting, e.g.
%% plot(gauss([0:500], tissue_means(1), sqrt(tissue_vars(1))), 'r');
%%
%% Previously, we constructed and displayed a histogram estimate of the
%% PDF for white matter.
%%
%% Arrange for a plot that, for white matter, shows the histogram based
%% PDF, along with its Gaussian counterpart. Comment on the differences you
%% see between the two models.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
figure;
hold;
plot(0:100,gauss([0:100], tissue_means(1), sqrt(tissue_vars(1))), 'r',IntensityValues, HistPDF(IntensityValues, intensity_white,20),'b');
title('White matter histogrampdf vs Gaussian pdf')
legend('Gaussian pdf','Histogram pdf');
hold;
%code not necesary, but for visualizing the different pdfs of tissues
figure;
plot(0:100,gauss(0:100, tissue_means(1), sqrt(tissue_vars(1))), 'k',0:100,gauss(0:100, tissue_means(2), sqrt(tissue_vars(2))),'r',0:100,gauss(0:100, tissue_means(3), sqrt(tissue_vars(3))), 'b');
title('Gaussian pdfs for all tissue');
legend('white pdf','Gray pdf','Csf pdf');
%end of visualization code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%
%% Next we will implement ML classification of the image intensities
%% using the Gaussian models that we have constructed.
%%
%% The following code loops over the test slices and performs ML classification.
%%
%% Each slice is read in
%%
%% for that slice, 3 images are displayed showing the likelihoods
%% for each tissue
%%
%% (after you supply the missing code) the tissue class is determined for each
%% pixel
%%
%% the resulting classifications are then written out for subsequent processing
%% later in the lab.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(7); figure(8); %create windows with names 1 and 2
set(1, 'nextplot', 'replace') %set the names for figure 1
%for all the test slices images do
for i=TEST_SLICES
 %% read mri image
 mri_fn = sprintf('%s.%0.3d', MRI_PREFIX, i)
 img = mri_read(mri_fn);
 for k=1:NUM_LABELS
 w(:,k) = gauss(img(:), tissue_means(k), sqrt(tissue_vars(k)));
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %% Display the tissue likelihoods for the pixels in the slice
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Change 1 to zero to suppress display of tissue likelihoods
 if 1
 figure(9);
 imagesc([reshape(w(:,1), size(img));reshape(w(:,2), size(img));reshape(w(:,3), size(img))]);
 colormap(gray)
 title('tissue likelihoods');
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%% Question 8.
%% TURN IN:
%%
%% At this point, the matrix w (65536x3) contains the tissue likelihoods
%% for each pixel in the image img.
%% Your task is to fill in the matrix "classification"
%% with the ML classification of the image.
%% "classification" has the same dimensions as img,
%% and should contain the predefined tissue labels
%% LABEL_WHITE, LABEL_GRAY, LABEL_CSF
%% to indicate the classification of the image.
%% Seriously: try to do this the MATLAB way, and
%% avoid looping over pixels.
%% Turn in your lines of code that go after this comment.
%%
%% IN ADDITION: As the classifier runs, it displays the tissue likelihoods
%% as well as the resulting classification. What different information do
%% the likelihoods and classification contain?
%% Turn in your answer to this question.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
% put your code here
classification=zeros(size(img));
% order in w white gray csf
classificationt = (w(:,1)>w(:,2)&w(:,1)>w(:,3))*LABEL_WHITE + ...
 (w(:,2)>w(:,1)&w(:,2)>w(:,3))*LABEL_GRAY + ...
 (w(:,3)>w(:,2)&w(:,3)>w(:,1))*LABEL_CSF;
%converting the image from a vector to a 256x256 matrix
for z = 1:256,
 classification(:,z) = classificationt(256*(z-1)+1:z*256);
end
% Display the image and classification
figure(7); imagesc(img); colormap(gray); colorbar;title(mri_fn); axis off;
figure(8); imagesc(classification); colormap('default'); colorbar; title(mri_fn); axis off;
% Write out the classification for use downstream
 out_fn = sprintf('%s.%0.3d', CLASSIFICATION_PREFIX, i)
 mri_write(classification, out_fn);
 fprintf(1, 'Hit any Key to Continue\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
% CHANGE ME BACK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
pause; %pause in each classification of the image
end