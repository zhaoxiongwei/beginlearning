fileList = dir('./dogImages/');
fileList = fileList(3:end);
[fileNumber] = size(fileList);
imgWidth = 64;
imgHeight = 64;
testImages = zeros(imgWidth, imgHeight, 3, 0);
testLabels = zeros(0);
trainImages = zeros(imgWidth, imgHeight, 3, 0);
trainLabels = zeros(0);


for i=1:fileNumber
    fileName = fileList(i).name;
    class = sscanf(fileName, '%d_');
    class = class(1);

    fileName = sprintf('./dogImages/%s', fileName);
    img = imread(fileName);
    img = im2double(img);
 
    if mod(i, 10) == 0
        testImages(:,:,:,end+1) = img;
        testLabels(end+1) = class;
    else
        trainImages(:,:,:,end+1) = img;
        trainLabels(end+1) = class;
    end
    
end

save('testImages_class.mat', 'testImages', 'testLabels');
save('trainImages_class.mat', 'trainImages', 'trainLabels');
