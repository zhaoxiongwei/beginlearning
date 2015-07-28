function [J, grad] = linearRegCost(theta, X, y, lambda)
%COSTFUNCTIONREG Compute cost and gradient for logistic regression with regularization
%   J = COSTFUNCTIONREG(theta, X, y, lambda) computes the cost of using
%   theta as the parameter for regularized logistic regression and the
%   gradient of the cost w.r.t. to the parameters. 

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(theta));

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the cost of a particular choice of theta.
%               You should set J to the cost.
%               Compute the partial derivatives and set grad to the partial
%               derivatives of the cost w.r.t. each parameter in theta


J = sum ( -1 * y .* log ( sigmoid(X*theta)) - (1-y).*log(1-sigmoid(X*theta))) + 0.5 * lambda * (sum(theta.*theta) - theta(1)*theta(1));
J = J / m;

dif = sigmoid(X*theta) - y;
grad = (X' * dif) / m;

iNumber = size(theta,1);
grad(2:iNumber) = grad(2:iNumber) + theta(2:iNumber) .* lambda / m;

% =============================================================

end

