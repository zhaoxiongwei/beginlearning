fileList = dir('./dogImages/');
fileList = fileList(3:end);
imgWidth = 64;
imgHeight = 64;
imgPatch = 8;
patchNumber = 100000;
[fileNumber] = size(fileList);

patches = zeros(imgPatch*imgPatch*3, patchNumber);
% 随机选择文件, 以10结尾的文件作为测试集，其余作为训练集
for i=1:patchNumber

    fileSelected = round(rand * (fileNumber - 1)) + 1;
    if mod(fileSelected, 10) == 0
        continue;
    end
    
    positionX = round(rand*(imgWidth - imgPatch -1)) + 1;
    positionY = round(rand*(imgHeight - imgPatch -1)) + 1;
    fileName = fileList(fileSelected).name;
    fileName = sprintf('./dogImages/%s', fileName);
    img = imread(fileName);
    img = img(positionX : positionX+imgPatch-1, positionY : positionY+imgPatch-1, :);
    img = im2double(img);
    r = img(:,:,1); r = r(:);
    g = img(:,:,2); g = g(:);
    b = img(:,:,3); b = b(:);
    img = [r;g;b]; 
    patches(:,i) = img(:); 
end
save('imagePatches.mat', 'patches');
displayColorNetwork(patches(:,1:100));

testImages = zeros(imgWidth, imgHeight, 3, 0);
trainImages = zeros(imgWidth, imgHeight, 3, 0);


for i=1:fileNumber
    fileName = fileList(i).name;
    fileName = sprintf('./dogImages/%s', fileName);
    img = imread(fileName);
    img = im2double(img);
 
    if mod(i, 10) == 0
        testImages(:,:,:,end+1) = img;
    else
        trainImages(:,:,:,end+1) = img;
    end
    
end

trainOK = size(trainImages,4);
testOK = size(testImages,4);

fileList = dir('./fakeImages/');
fileList = fileList(3:end);
[fileNumber] = size(fileList);
for i=1:fileNumber
    fileName = fileList(i).name;
    fileName = sprintf('./fakeImages/%s', fileName);
    img = imread(fileName);
    img = im2double(img);
    if mod(i,10) == 0 
        testImages(:,:,:,end+1) = img; 
    else  
        trainImages(:,:,:,end+1) = img;
    end
end
trainLabels = zeros(1, size(trainImages,4));
trainLabels(1:trainOK) = 1;
testLabels = zeros(1, size(testImages,4));
testLabels(1:testOK) = 1;

save('testImages.mat', 'testImages', 'testLabels');
save('trainImages.mat', 'trainImages', 'trainLabels');
