function render
%RENDER  Perform 3D brain surface rendering
%  This file contains a quick hack for doing a simple 3d surface rendering of a
%  portion of the top of the white matter structure.
%
%  The strategy that is used is to walk through the labelled slices, and for
%  each one, build a 1D array that indicates the "altitude" (y - coordinate) of
%  the highest white matter.
%
%  These 1D arrays are collected into a 2D array, and the graph of that
%  structure ("tmpmins") corresponds to an altitude map for the white matter.

%  The graph is rendered in 3d with realistic shading, and 3D interaction is
%  enabled so that the operator can flip it round with the mouse.
%
%  As usual, you must modify in the variables CLASSIFICATION_PREFIX and
%  BRAIN_PREFIX to point to the data path that you used for MRI segment
%  classification.

% Last modified: 4/06/06, Eric Weiss


% Update your path prefixes here
%-------------------------------
CLASSIFICATION_PREFIX = '/mit/6.555/....../output/classification';
BRAIN_PREFIX = '/mit/6.555/....../output/brain';


% MRI path and image specifications (do not modify)
%--------------------------------------------------
MRI_PREFIX = '/mit/6.555/data/seg/case1/005/slice';
LABELS_PREFIX = '/mit/6.555/data/seg/case1/seg_yoh/output';
TEST_SLICES = [102:190];
LABEL_WHITE = 8;
LABEL_GRAY = 4;
LABEL_CSF = 5;


% Perform surface rendering
%--------------------------
for i = TEST_SLICES
    in_fn = sprintf('%s.%0.3d', BRAIN_PREFIX, i)
    figure(1); img =(mri_read(in_fn));
    display_image(img, 'brain slice');
    figure(2); display_image(img == LABEL_WHITE);
    fprintf(1, 'Hit any Key to continue\n');

    tmp= (img == LABEL_WHITE);
    tmp = double(tmp);
    [r,c] = find(tmp);
    tmp(find(tmp)) = r;
    tmp(find(tmp==0)) = Inf;
    tmpmins(i,:) = min(tmp,[],1);

    % pause
end;

% Plot 3D surface
%----------------
surfl(0-tmpmins(TEST_SLICES,:));
shading interp;
colormap(pink);
axis('equal');
rotate3d;
