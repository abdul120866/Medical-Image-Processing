function ip_hw_3()
    % -----------------------------------------
    % 1) Read & Prepare Image
    % -----------------------------------------
    I = imread('noisy_brain_1.png');  
    
    % Convert to grayscale if it is color
    if size(I, 3) == 3
        I_gray = rgb2gray(I);
    else
        I_gray = I;
    end
    
    % Convert to double for filtering
    I_gray_double = im2double(I_gray);

    % -----------------------------------------
    % 2) Define Window Size
    % -----------------------------------------
    windowSize = [3 3];  % 3×3 neighborhood
    
    % -----------------------------------------
    % 3) Apply Filters
    % -----------------------------------------
    
    % 3.1 Median Filter
    I_median = medfilt2(I_gray_double, windowSize);
    
    % 3.2 Minimum Filter (ordfilt2 with rank=1)
    %     ones(3,3) => neighborhood shape
    I_min = ordfilt2(I_gray_double, 1, ones(windowSize));
    
    % 3.3 Maximum Filter (ordfilt2 with rank=9 for a 3×3)
    %     The rank is m*n for an m×n neighborhood => 3×3 => rank=9
    I_max = ordfilt2(I_gray_double, 9, ones(windowSize));
    
    % 3.4 Midpoint Filter => (min + max)/2
    I_midpoint = (I_min + I_max) / 2;
    
    % 3.5 Alpha-Trimmed Mean Filter
    %     We remove "alpha" pixels total, i.e. alpha/2 from the lowest side, 
    %     alpha/2 from the highest side. For a 3×3 neighborhood => 9 pixels. 
    %     Example alpha=2 => remove 1 smallest and 1 largest => keep 7 pixels.
    alpha = 2;  % remove 'alpha' pixels from each block
    I_alphaTrimmed = nlfilter(I_gray_double, windowSize, ...
        @(block) alphaTrimFn(block(:), alpha));
    
    % 3.6 Bilateral Filter
    %     Sigma values can be adjusted as needed. 
    %     For example, "DegreeOfSmoothing" = 0.01, "SpatialSigma" = 2
    I_bilateral = imbilatfilt(I_gray_double, 0.01, 2);

    % -----------------------------------------
    % 4) Display: Each in a Separate, Centered Figure
    % -----------------------------------------
    
    % Dimensions for each figure (in pixels)
    figWidth  = 600;  
    figHeight = 500;  
    
    openCenteredFigure(figWidth, figHeight);
    imshow(I_gray, []);
    title('Original Image');

    openCenteredFigure(figWidth, figHeight);
    imshow(I_median, []);
    title('Median Filter');

    openCenteredFigure(figWidth, figHeight);
    imshow(I_min, []);
    title('Minimum Filter');

    openCenteredFigure(figWidth, figHeight);
    imshow(I_max, []);
    title('Maximum Filter');

    openCenteredFigure(figWidth, figHeight);
    imshow(I_midpoint, []);
    title('Midpoint Filter');

    openCenteredFigure(figWidth, figHeight);
    imshow(I_alphaTrimmed, []);
    title(['Alpha-Trimmed Mean (alpha = ', num2str(alpha), ')']);

    openCenteredFigure(figWidth, figHeight);
    imshow(I_bilateral, []);
    title('Bilateral Filter');
     
    % Save all images as .jpg in current folder
    % -----------------------------------------
    % Convert images to 8-bit before saving if you prefer standard JPG.
    % If you want to store as double-precision images in TIF/PNG, you can skip
    % im2uint8(...) or choose a different file format.

    imwrite(im2uint8(I_gray_double),          '01_original.jpg');
    imwrite(im2uint8(I_median),               '02_median.jpg');
    imwrite(im2uint8(I_min),                  '03_minimum.jpg');
    imwrite(im2uint8(I_max),                  '04_maximum.jpg');
    imwrite(im2uint8(I_midpoint),             '05_midpoint.jpg');
    imwrite(im2uint8(I_alphaTrimmed),         '06_alpha_trimmed.jpg');
    imwrite(im2uint8(I_bilateral),            '07_bilateral.jpg');


    % -----------------------------------------
    %  Nested Function: Alpha-Trimmed Mean
    % -----------------------------------------
    function val = alphaTrimFn(vec, alphaVal)
        % Sort the 3×3 neighborhood pixels
        sVec = sort(vec);
        
        % Number of pixels in the window
        n = numel(sVec);
        
        % Trim alphaVal/2 from the bottom and top
        trimLow  = alphaVal / 2;
        trimHigh = alphaVal / 2;
        
        % Check edge cases (ensure we don't exceed array bounds)
        startIdx = 1 + trimLow;
        endIdx   = n - trimHigh;
        
        % If alphaVal is 0 or incorrectly set, handle that gracefully
        if startIdx < 1,    startIdx = 1;    end
        if endIdx   > n,    endIdx   = n;    end
        
        trimmed = sVec(startIdx : endIdx);
        val = mean(trimmed);
    end

end

% -----------------------------------------
%  Helper Function: openCenteredFigure
%    Creates a new figure centered on screen
% -----------------------------------------
function fh = openCenteredFigure(figWidth, figHeight)
    % Get screen size: [left, bottom, screenWidth, screenHeight]
    screenSize = get(0, 'ScreenSize');
    
    % Compute the x,y for centering
    xPos = (screenSize(3) - figWidth) / 2;
    yPos = (screenSize(4) - figHeight) / 2;
    
    % Create the figure at [xPos, yPos, figWidth, figHeight]
    fh = figure('Position', [xPos, yPos, figWidth, figHeight]);
end
