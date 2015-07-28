function [pred value] = deepSoftmaxPredict(theta, inputSize, hiddenSize, ...
                                              numClasses, data)
                                         
softmaxTheta = reshape(theta(1:hiddenSize*numClasses), numClasses, hiddenSize);

% Extract out the "stack"
stack = cell(1,1);
stack{1} = struct;
stack{1}.w = reshape(theta(hiddenSize*numClasses+1:end-hiddenSize), hiddenSize, inputSize);
stack{1}.b = reshape(theta(end-hiddenSize+1:end), hiddenSize, 1);


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
[v pred] = max(z{outLay});

end


% You might find this useful
function sigm = sigmoid(x)
    sigm = 1 ./ (1 + exp(-x));
end
