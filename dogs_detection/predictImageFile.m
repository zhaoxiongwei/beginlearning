function value = predictImageFile(fileName);

outputDim = 64;
imageChannels = 3;

img = imread(fileName);
img = im2double(img);
[w h c] = size(img);
img = imresize(img, [384 round(384/w*h)]);
[w h c] = size(img);

searchWindows = [200 32;128 16;64 8];

images = zeros(outputDim, outputDim, imageChannels, 0);

for i = 1:size(searchWindows,1)
    dim = searchWindows(i,1);
    step = searchWindows(i,2);
    for x = 1:step:w
        if (w-x < dim - 1)
            break;
        end
        for y=1:step:h
            if (h-y < dim - 1)
                break;
            end
            
            subImage = img(x:x+dim-1,y:y+dim-1,:);
            subImage = imresize(subImage, [outputDim outputDim]);
            images(:,:,:,1) = subImage;
            
            value = predictImages(images);       
            if ( value > 0.90) 
                img(x:x+dim-1,y,:) = 1;
                img(x:x+dim-1,y+dim-1,:) = 1;
                img(x,y:y+dim-1,:) = 1;
                img(x+dim-1,y:y+dim-1,:) = 1;
                imshow(img);
                figure;
                imshow(subImage);
                return;
            end
        end
    end    
end


end
