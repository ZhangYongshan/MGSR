function W = MGSR(X, A, noise, lambda)
%MGSR 此处显示有关此函数的摘要
%   此处显示详细说明


iter_num = 20; %20;
[nSmp,nFea] = size(X);

% scatter matrix S
% S = X*X';
% Sp = X' * A' *X;
% Sq = X' * A' * A * X;   %n x n

Y = A * X;
Sp = Y' * X;
Sq = Y' * Y;   %n x n

% corruption vector
q = ones(nFea, 1)*(1-noise);

% Q: d x d
Q = Sq.*(q*q');
Q(1:nFea+1:end) = q.*diag(Sq);
% P: d x d
P = Sp(1:end,:).*repmat(q', nFea, 1);

D = eye(nFea);

for iter = 1:iter_num
    
    % update W
    W = (Q+lambda*D)^(-1) * P;

    wc = sqrt(sum(W.*W,2)+eps);
    D = diag(1./wc)*0.5;

    Term_1 = X-Y*W;
	obj(iter) = sum(sum(Term_1.*Term_1)) + lambda*sum(wc);
end

end



