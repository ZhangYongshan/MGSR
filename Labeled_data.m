function [data, label] = Labeled_data(data3D, label_gt)
%LABELED_DATA 此处显示有关此函数的摘要
%   此处显示详细说明

[m, n, p] = size(data3D);
data_col = reshape(data3D,m*n,p);
label_col = reshape(label_gt,m*n,1);

idx = find(label_col~=0);

data = data_col(idx,:);
label = label_col(idx,:);

end

