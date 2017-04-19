function [text] = extractImageText(fname)
% [text] = extractImageText(fname) loads the image specified by the path 'fname'
% and returns the next contained in the image as a string.

im = imread(fname);
[lines, bw] = findLetters(im);

% prepare data for classification
num_data = 0;
for i = 1:length(lines)
   num_data = num_data + size(lines{i}, 1);
end
data = zeros(num_data, 32 * 32);

index = 0;
linebreak = zeros(num_data, 1);  % indicate the line break
linebreak_ind = 1;
for i = 1:length(lines)
    line = lines{i};
    num_obj = size(line, 1);
    for j = 1: num_obj
        index = index + 1;
        obj = line(j, :);
        [H, W] = size(obj);
        img = ~bw(obj(2):obj(4), obj(1):obj(3));
        
        % padding to make it a squre image 
        sideLen = max(H, W);
        diff = max(sideLen - H, sideLen - W);
        if mod(diff, 2) == 0
            img = padarray(img, [(sideLen - H) / 2, (sideLen - W) / 2]);
        else 
            img = padarray(img, [sideLen - H, sideLen - W], 'pre');
        end
        img = ~imresize(img, [32 32]);
        % imshow(img);
        data(index, :) = img(:)';
    end
    linebreak(linebreak_ind) = index;
    linebreak_ind = linebreak_ind + 1;
end

% perform classification
load('nist36_model.mat');
[outputs] = Classify(W, b, data);
letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
text = '';
for i = 1:num_data
    predict = outputs(i, :);
    imshow(mat2gray(reshape(data(i, :), [32,32])));
    [~, ind] = max(predict);
    text = strcat(text, letters(ind));
    if ~isempty(find(linebreak == i))
        text = [text, sprintf('\n')];
    end
end

sprintf(text);

end
