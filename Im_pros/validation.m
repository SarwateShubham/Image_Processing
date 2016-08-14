close all
MRI_PREFIX = 'D:\Resources\Stud\MY PROJECTS\DSP Project\lab3files\data\case1\case1\005\slice';
LABELS_PREFIX = 'D:\Resources\Stud\MY PROJECTS\DSP Project\lab3files\data\case1\case1\seg_yoh\output';
CLASSIFICATION_PREFIX='D:\Resources\Stud\MY PROJECTS\DSP Project\Output\classification';
BRAIN_PREFIX='D:\Resources\Stud\MY PROJECTS\DSP Project\Output\brain';
LABEL_WHITE = 8;
LABEL_GRAY = 4;
LABEL_CSF = 5;
LABEL_AIR = 0;
num_labels = 3;
TEST_SLICE = 41;
% read and display your result for slice 41.
my_result_fn = sprintf('%s.%0.3d', BRAIN_PREFIX, TEST_SLICE);
my_result = mri_read(my_result_fn);
% read and display expert's result for slice 41.
gold_standard_fn = sprintf('%s.%0.3d', LABELS_PREFIX, TEST_SLICE);
gold_standard = mri_read(gold_standard_fn);
figure;
display_image(my_result,'My Classification Result');
figure;
display_image(gold_standard,'Expert Classification Result');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%% Question 10:
%% TURN IN:
%%
%% You will notice that your result is not the same as the
%% "gold standard" that was done by an expert using better
%% tools, in particular, he is getting good CSF segmentation,
%% where we did not attempt to differentiate CSF from air.
%% (But he also was using a T2 weighted scan that has good
%% water contrast).
%%
%% Figure out a way to quantify the agreement of your segmentation and his
%% with respect to white matter and gray matter in slice 41, and include that
%% in your report.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%First, lets extract the white matter from the expert classification image
ewmatter = gold_standard == LABEL_WHITE;
%then, lets extract my_result white matter
wmatter = my_result == LABEL_WHITE;
%now lets see how many mismatches are there
wmismatches = ewmatter - wmatter;
%calculate false positive error
wfalsepositive = length(find(wmismatches==1))
%false positive in percent
wfalsepositivep = wfalsepositive * (100/65536)
%calculate false negative error
wfalsenegative = length(find(wmismatches==-1))
%false negative in percent
wfalsenegativep = wfalsenegative * (100/65536)
%First, lets extract the gray matter from the expert classification image
egmatter = gold_standard == LABEL_GRAY;
%then, lets extract my_result gray matter
gmatter = my_result == LABEL_GRAY;
%now lets see how many mismatches are there
gmismatches = egmatter - gmatter;
%calculate false positive error
gfalsepositive = length(find(gmismatches==1))
%false positive in percent
gfalsepositivep = gfalsepositive * (100/65536)
%calculate false negative error
gfalsenegative = length(find(gmismatches==-1))
%false negative in percent
gfalsenegativep = gfalsenegative * (100/65536)
%now, calculating the total error in the classification
totalerror = gfalsepositivep + gfalsenegativep + wfalsepositivep + wfalsenegativep
%graph of white matter error
figure;
display_image(abs(wmismatches),'White matter error');
%graph of gray matter error
figure;
display_image(abs(gmismatches),'gray matter error');
%calculate absolute value to eliminate negative signs of the substraction procedure and
%be able to graph the error in classification
wmismatches = abs(wmismatches) + abs(gmismatches);
figure;
display_image(wmismatches,'Total error: mismatches in the classification');
