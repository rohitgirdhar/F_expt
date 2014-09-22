function match()

run('~/software/vlfeat/toolbox/vl_setup');

I = imread('1.jpg');
J = imread('2.jpg');
[f1, d1] = vl_sift(single(rgb2gray(I)));
[f2, d2] = vl_sift(single(rgb2gray(J)));
matches = vl_ubcmatch(d1, d2);
visualizeMatching(I, J, f1, f2, matches, 'save', 'raw_matches.jpg');
matchedPoints1 = f1(1 : 2, matches(1, :))';
matchedPoints2 = f2(1 : 2, matches(2, :))';
[~, inliersIndex] = estimateFundamentalMatrix(matchedPoints1, ...
        matchedPoints2, 'Method', 'RANSAC');
matches = matches(:, inliersIndex == 1);
visualizeMatching(I, J, f1, f2, matches, 'save', 'final_matches.jpg');

function visualizeMatching(I1, I2, f1, f2, matches, varargin)
% @param I1, I2 are the images
% @param f1, f2 are feature keypoints, as detected by vl_sift
% matches are between f1 and f2, as detected by vl_ubcmatch or
% bow_computeMatchesQuantized
% @param (optional): 'save', 'filename' to instead save the matches to a
% file and not show on the screen

p = inputParser;
addOptional(p, 'save', 0);
parse(p, varargin{:});

I = appendimages(I1, I2);
if p.Results.save == 0
    figure('Position', [100 100 size(I, 2) size(I, 1)]);
else
    fig = figure('visible', 'off');
end
imagesc(I);
hold on;
cols1 = size(I1, 2);
ColorSet = lines(size(matches, 2)); % Lines colorset from COLORMAPS
for i = 1 : size(matches, 2)
    X = [f1(1, matches(1, i)); f2(1, matches(2, i)) + cols1];
    Y = [f1(2, matches(1, i)); f2(2, matches(2, i))];
    line(X, Y, 'Color', ColorSet(i, :), 'LineWidth', 2, 'Marker', '*');
end
hold off;

if p.Results.save ~= 0
    saveas(fig, p.Results.save);
end

function im = appendimages(image1, image2)
% im = appendimages(image1, image2)
%
% Return a new image that appends the two images side-by-side.

% Select the image with the fewest rows and fill in enough empty rows
%   to make it the same height as the other image.
rows1 = size(image1,1);
rows2 = size(image2,1);

if (rows1 < rows2)
     image1(rows2,1) = 0;
else
     image2(rows1,1) = 0;
end

% Now append both images side-by-side.
im = [image1 image2];

