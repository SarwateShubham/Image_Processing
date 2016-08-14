%MRI_CLASSIFY  Perform statistical image classification (requires updates)
%  While this script is mostly complete, you are responsible for modifying the
%  contents of this function to make it fully operational. Be sure to create an
%  "output/classification" directory within your personal directory and modify
%  CLASSIFICATION_PREFIX to point to this directory.

% Last Modified: 4/6/06, Eric Weiss


% Update the CLASSIFICATION_PREFIX directory here
%------------------------------------------------
CLASSIFICATION_PREFIX = 'C:\Users\lullichoti\Desktop\DSP Project\Output';


% MRI training & test image specifications (do not modify)
%---------------------------------------------------------
MRI_PREFIX = 'C:\Users\lullichoti\Desktop\DSP Project\lab3files\data\swrot\spgr\I';
LABELS_PREFIX = 'C:\Users\lullichoti\Desktop\DSP Project\lab3files\data\swrot\segtruth\I';
TRAINING_SLICES = [120:2:150];
TEST_SLICES = [102:190];
SLICE_NUM = 120;


%---------------------------------------------------
% Read and display an MRI slice and its segmentation
%---------------------------------------------------
mri_fn = sprintf('%s.%0.3d', MRI_PREFIX, SLICE_NUM); % create filename
img = mri_read(mri_fn);  % img is the raw MRI image
labels_fn = sprintf('%s.%0.3d', LABELS_PREFIX, SLICE_NUM);
labels = mri_read(labels_fn);  % labels is the image with labeled segments

% Display img & labels using grayscale colormap
%...  INSERT YOUR CODE HERE.
display_image(img,labels);

%------------------------------------------------------------------
% Next we compile the segmented intensity data for all MRI training
% slices and build some class-conditional probability models.
%------------------------------------------------------------------
LABEL_WHITE = 8; % pixel label/value corresponding to white matter
LABEL_GRAY = 4;  % pixel label/value corresponding to grey matter
LABEL_CSF = 5;   % pixel label/value corresponding to cerebrospinal fluid
NUM_LABELS = 3;  % number of labels


% The following loops over the training slices and collects
% the intensity values that correspond to each tissue class
%----------------------------------------------------------
intensity_white = []; % compiles all white matter intensity data
intensity_gray  = []; % compiles all gray matter intensity data
intensity_csf   = []; % compiles all csf intensity data
for i = TRAINING_SLICES
    %% read mri image & corresponding labelled img
    mri_fn = sprintf('%s.%0.3d', MRI_PREFIX, i);
    img = mri_read(mri_fn);
    labels_fn = sprintf('%s.%0.3d', LABELS_PREFIX, i);
    labels = mri_read(labels_fn);

    %% concatenate the observed intensity values in this slice
    intensity_white = [intensity_white; img(find(labels == LABEL_WHITE))];
    intensity_gray  = [intensity_gray;  img(find(labels == LABEL_GRAY))];
    intensity_csf   = [intensity_csf;   img(find(labels == LABEL_CSF))];
end;

%---------------------
% Histogram PDF Models
%---------------------

% Here is an example of how to display a histogram
% of the intensities observed as white matter
%-------------------------------------------------
figure; hist(intensity_white); title('White Matter: Intensity Histogram');

% Construct Histogramming-Based PDFs (call your version of HistPDF)
%------------------------------------------------------------------
% ... INSERT YOUR CODE HERE.
[pdf,x]=HistPDF(intensity_white,1000);
plot(x,pdf)

%--------------------
% Gaussian PDF Models
%--------------------

% Fit Gaussian distributions to white, gray, and csf intensity data
%------------------------------------------------------------------
tissue_means = [mean(intensity_white) mean(intensity_gray) mean(intensity_csf)];
    % its three elements are white, gray, csf means
tissue_vars = [var(intensity_white) var(intensity_gray) var(intensity_csf)];  
    % its three elements are white, gray, csf variances

% Define the Gaussian probability density function
%-------------------------------------------------
gauss = inline('(1/(sqrt(2*pi)*s))*exp(-(x-m).*(x-m)/(2*s*s))','x','m','s');

% Construct Gaussian PDFs
%------------------------
y=normpdf(intensity_white,mean(intensity_white),sqrt(var(intensity_white)));

% Plot the Gaussian PDFs, along with their histogram-based counterparts
%----------------------------------------------------------------------
% ... INSERT YOUR CODE HERE.
figure;
plot(y,'r')

%------------------------------------------
% Perform Maximum Likelihood Classification
%------------------------------------------
h1 = figure; set(h1, 'nextplot', 'replace');
h2 = figure;
h3 = figure;  % for tissue likelihoods
for i = TEST_SLICES
    %% read mri image
    mri_fn = sprintf('%s.%0.3d', MRI_PREFIX, i)
    img = mri_read(mri_fn);
    w = zeros(length(img(:)),NUM_LABELS);
    for k = 1:NUM_LABELS
        w(:,k) = gauss(img(:), tissue_means(k), sqrt(tissue_vars(k)));
    end;

    % Display the tissue likelihoods for the pixels in the slice
    % Change 1 to zero to suppress display of tissue likelihoods
    if 1
        figure(h3);
        imagesc([reshape(w(:,1), size(img)); ...
            reshape(w(:,2), size(img)); ...
            reshape(w(:,3), size(img))]);
        colormap(gray)
        title('Tissue Likelihoods');
    elseif ~isempty(h3)
        close(h3)
        h3 = [];
    end;

    % Classify Image Pixels
    classification = zeros(size(img));
    
    % put your ML classification code here
    % ...

    % Display the image and classification
    [fpath,fname,ext] = fileparts(mri_fn);
    name = [fname,ext];
    figure(h1); display_image(img,['MRI Image: ',name]);
    figure(h2); display_image(classification,['Classified: ',name,...
        sprintf(' (%d=White, %d=Gray, %d=CSF)',LABEL_WHITE,LABEL_GRAY,LABEL_CSF)]);

    % Write the classification for use downstream
    out_fn = sprintf('%s.%0.3d', CLASSIFICATION_PREFIX, i);
    mri_write(classification, out_fn);
    fprintf(1,['Classification file %s has been written. ',...
        'Hit any key to continue.\n'],name);
    pause;
end;
