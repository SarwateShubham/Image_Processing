close all;
MRI_PREFIX = 'D:\Resources\Stud\MY PROJECTS\DSP Project\lab3files\data\case1\case1\005\slice';
LABELS_PREFIX = 'D:\Resources\Stud\MY PROJECTS\DSP Project\lab3files\data\case1\case1\seg_yoh\output';
CLASSIFICATION_PREFIX='D:\Resources\Stud\MY PROJECTS\DSP Project\Output\classification';
BRAIN_PREFIX='D:\Resources\Stud\MY PROJECTS\DSP Project\Output\brain'; % name of the output files
TEST_SLICES = [26:64];
LABEL_WHITE = 8;
LABEL_GRAY = 4;
LABEL_CSF = 5;
LABEL_AIR = 0;
num_labels = 3;
colors = {'g', 'r', 'b', 'm'};



for i=TEST_SLICES
    out_fn = sprintf('%s.%0.3d', CLASSIFICATION_PREFIX, i);
    img = mri_read(out_fn);
    brain = (img == LABEL_WHITE | img == LABEL_GRAY);
    figure(1); display_image(brain, 'initial brain pixels (White and Gray matter)');
    %applying erotion to the brain
    brain_eroded = bwmorph(brain, 'erode', 1);
    figure(4); display_image(brain_eroded, 'eroded brain pixels ');
    
    [cc, num] = bwlabel(brain_eroded);
    figure(5); display_image(cc*2, 'connected components');
    % size_cc may have leftover stuff in it from last time around...
    size_cc = 0;
    %now, for all the connected components, we calculate their size
    %by counting the number of pixels that have the same label assigned
    for j=1:num
        size_cc(j) = length(find(cc==j));
    end
    %sort the sizes so that the last object is the bigger one
    [Y, I] = sort(size_cc);
    brain_cc = (cc==I(num));
    %calculating the x,y median position of largest connected component 256 is maximum values
    [xvalues yvalues] = find(brain_cc==1);
    xmean = mean(xvalues);
    ymean = mean(yvalues);
   
    figure(7); display_image(brain_cc*2, 'brain connected component emt');colorbar;
    brain_dilated = bwmorph(brain_cc, 'dilate', 2);
    brain_conditionally_dilated = double(brain_dilated).*brain;
    white_matter = zeros(size(img));
    white_matter = brain_conditionally_dilated .* (img == LABEL_WHITE);
    white_matter(find(white_matter)) = LABEL_WHITE;
    gray_matter = zeros(size(img));
    gray_matter = brain_conditionally_dilated .* (img == LABEL_GRAY);
    gray_matter(find(gray_matter)) = LABEL_GRAY;
    out_fn = sprintf('%s.%0.3d', BRAIN_PREFIX, i)
    mri_write(gray_matter+white_matter, out_fn);
    figure(8); imagesc(white_matter+gray_matter);
    figure(9); display_image(white_matter+gray_matter, 'classification for isolated brain');
end
