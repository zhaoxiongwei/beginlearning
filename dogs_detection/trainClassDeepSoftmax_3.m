load cnnPooledFeatures_class.mat;
numTrainImages = size(pooledFeaturesTrain,2);
softmaxX = permute(pooledFeaturesTrain, [1 3 4 2]);
softmaxX = reshape(softmaxX, numel(pooledFeaturesTrain) / numTrainImages,...
    numTrainImages);
softmaxY = trainLabels;

numClasses = 25;
inputSize = size(softmaxX,1);
hiddenSize = 100;

theta = 0.005 * randn(numClasses * hiddenSize + (inputSize+1) * hiddenSize, 1);

addpath minFunc/
options = struct;
options.maxIter = 1000;
options.Method = 'lbfgs';
options.display = 'on';

lambda = 0.0001;
[optTheta, cost] = minFunc( @(p) deepSoftmaxCost(p, ...
                                    inputSize, hiddenSize, ...
                                    numClasses, lambda, ... 
                                    softmaxX, softmaxY), ...
                                theta, options);

save('deepSoftmaxOptTheta.mat', 'optTheta');

[pred] = deepSoftmaxPredict(optTheta, inputSize, hiddenSize, ...
                          numClasses, softmaxX);

acc = mean(trainLabels(:) == pred(:));
fprintf('Train Accuracy: %0.3f%%\n', acc * 100);


numTestImages = size(pooledFeaturesTest,2);
softmaxX = permute(pooledFeaturesTest, [1 3 4 2]);
softmaxX = reshape(softmaxX, numel(pooledFeaturesTest) / numTestImages,...
    numTestImages);
softmaxY = testLabels;

[pred] = deepSoftmaxPredict(optTheta, inputSize, hiddenSize, ...
                          numClasses, softmaxX);

acc = mean(testLabels(:) == pred(:));
fprintf('Test Accuracy: %0.3f%%\n', acc * 100);

