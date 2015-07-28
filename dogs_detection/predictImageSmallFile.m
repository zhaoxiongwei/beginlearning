%function value = predictImageFile(fileName);
img = imread(fileName);
img = im2double(img);
if ( size(img,1) ~= 64 || size(img,2) ~= 64)
    disp('Input image size is not 64x64');
    value = -1;
    return;
end
images = zeros(64, 64, 3, 0);
images(:,:,:,1) = img;
[value  C X] = predictImages(images);       

%end
