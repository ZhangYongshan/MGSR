function [data, label,labelA] = Labeled_dataSuperPixel(data3D, label_gt,labelA)
%LABELED_DATA 此处显示有关此函数的摘要
%   此处显示详细说明
% lableA -superpixel label
[m, n, p] = size(data3D);

data_col = reshape(data3D,m*n,p);

label_col = reshape(label_gt,m*n,1);
label_colA = reshape(labelA,m*n,1);

idx = find(label_col~=0);
data = data_col(idx,:);
label = label_col(idx,:);

 labelA=label_colA(idx,:);
end

