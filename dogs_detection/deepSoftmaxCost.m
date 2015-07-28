function [ cost, grad ] = deepSoftmaxCost(theta, inputSize, hiddenSize, ...
                                              numClasses, lambda, ... 
                                              data, labels)
                                         
% stackedAECost: Takes a trained softmaxTheta and a training data set with labels,
% and returns cost and gradient using a stacked autoencoder model. Used for
% finetuning.
                                         
% theta: trained weights from the autoencoder
% visibleSize: the number of input units
% hiddenSize:  the number of hidden units *at the 2nd layer*
% numClasses:  the number of categories
% lambda:      the weight regularization penalty
% data: Our matrix containing the training data as columns.  So, data(:,i) is the i-th training example. 
% labels: A vector containing labels, where labels(i) is the label for the
% i-th training example

%% Unroll softmaxTheta parameter

% We first extract the part which compute the softmax gradient
softmaxTheta = reshape(theta(1:hiddenSize*numClasses), numClasses, hiddenSize);

% Extract out the "stack"
stack = cell(1,1);
stack{1} = struct;
stack{1}.w = reshape(theta(hiddenSize*numClasses+1:end-hiddenSize), hiddenSize, inputSize);
stack{1}.b = reshape(theta(end-hiddenSize+1:end), hiddenSize, 1);

% You will need to compute the following gradients
softmaxThetaGrad = zeros(size(softmaxTheta));
stackgrad = cell(size(stack));
for d = 1:numel(stack)
    stackgrad{d}.w = zeros(size(stack{d}.w));
    stackgrad{d}.b = zeros(size(stack{d}.b));
end

cost = 0; % You need to compute this

% You might find these variables useful
M = size(data, 2);
groundTruth = full(sparse(labels, 1:M, 1));


%% --------------------------- YOUR CODE HERE -----------------------------
%  Instructions: Compute the cost function and gradient vector for 
%                the stacked autoencoder.
%
%                You are given a stack variable which is a cell-array of
%                the weights and biases for every layer. In particular, you
%                can refer to the weights of Layer d, using stack{d}.w and
%                the biases using stack{d}.b . To get the total number of
%                layers, you can use numel(stack).
%
%                The last layer of the network is connected to the softmax
%                classification layer, softmaxTheta.
%
%                You should compute the gradients for the softmaxTheta,
%                storing that in softmaxThetaGrad. Similarly, you should
%                compute the gradients for each layer in the stack, storing
%                the gradients in stackgrad{d}.w and stackgrad{d}.b
%                Note that the size of the matrices in stackgrad should
%                match exactly that of the size of the matrices in stack.
%
outLay = numel(stack) + 2;
a = cell( outLay);
z = cell( outLay);
delta = cell( outLay);

% Forward computing
a{1} = data; 
for d=1:numel(stack)
    l = d + 1;      % layer index, from input to output 
    ah = [ones(1, size(a{d},2)); a{d}];
    wh = [stack{d}.b stack{d}.w];
    z{l} = wh * ah;
    a{l} = sigmoid(z{l});    
end
z{outLay} = softmaxTheta * a{outLay - 1}; 
a{outLay} = exp(z{outLay});
hvalue = a{outLay} ./ repmat( sum(a{outLay},1), size(a{outLay},1), 1);

% cost computing
wr = 0; 
for d=1:numel(stack)
    wr = wr + sum(sum(stack{d}.w.^2));
end
wr = wr + sum(sum(softmaxTheta.^2));

cost = -1 * sum(sum(log(hvalue).*groundTruth)) / M + 0.5 * lambda * wr;

% backpropagation
delta{outLay} = -1 * (groundTruth - hvalue);
softmaxThetaGrad = softmaxThetaGrad + delta{outLay} * a{outLay-1}' / M + lambda * softmaxTheta;

delta{outLay-1} = softmaxTheta' * delta{outLay} .* a{outLay-1} .* ( 1 - a{outLay-1});

for d=numel(stack):-1:1
    l = d;
    stackgrad{d}.w = stackgrad{d}.w + delta{l+1} * a{l}' / M + lambda * stack{d}.w;
    stackgrad{d}.b = stackgrad{d}.b + sum(delta{l+1},2)/ M;
    delta{l} = stack{d}.w' * delta{l+1} .* a{l} .* (1-a{l});
end


% -------------------------------------------------------------------------

%% Roll gradient vector
grad = [softmaxThetaGrad(:) ; stackgrad{1}.w(:); stackgrad{1}.b(:)];

end


% You might find this useful
function sigm = sigmoid(x)
    sigm = 1 ./ (1 + exp(-x));
end
