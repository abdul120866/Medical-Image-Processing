
imageFileTask7 = 'image3.jpg';  
I7 = imread(imageFileTask7);

% === EXPLORING BRIGHTNESS & CONTRAST PARAMETERS ===

alphaValues = [0.8, 1.0, 1.2, 1.5];  % Contrast factors
betaValues  = [-0.1, 0, 0.1, 0.2];   % Brightness offsets (in [0,1] if double)

figure('Name','Task 7: Parameter Exploration');
idx = 1;
for a = 1:length(alphaValues)
    for b = 1:length(betaValues)
        % Convert to double [0,1]
        tempDouble = im2double(I7);

        % Apply alpha (contrast) and beta (brightness)
        tempDouble = immultiply(tempDouble, alphaValues(a));
        tempDouble = imadd(tempDouble, betaValues(b));

        % Clip values to [0,1]
        tempDouble = max(min(tempDouble, 1), 0);

        % Convert back to uint8
        tempUint8 = im2uint8(tempDouble);

        % Display in a grid of subplots
        subplot(length(alphaValues), length(betaValues), idx);
        imshow(tempUint8);
        title(sprintf('\\alpha=%.1f, \\beta=%.1f', alphaValues(a), betaValues(b)));
        idx = idx + 1;
    end
end

% === HISTOGRAM EQUALIZATION ===
% we can also compare standard histogram equalization:
I7_histeq = histeq(I7);

figure('Name','Task 7: Histogram Equalization');
subplot(1,2,1);
imshow(I7);
title('Original Image');

subplot(1,2,2);
imshow(I7_histeq);
title('Histogram Equalized Image');
