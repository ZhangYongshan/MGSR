
clear all; clc;
addpath('Data');
addpath('Entropy Rate Superpixel Segmentation');

dataset = 'Indian'; %  KSC  Pavia  Botswana  Indian   SalinasA
method = 'MGSR-Seg';

%======================setup=======================
%create a folder named by the name of dataset
if exist(dataset) == 0
    mkdir(dataset);
end

%% load the HSI dataset
if strcmp(dataset,'Indian')
    load Indian_pines_corrected;load Indian_pines_gt; 
    data3D = indian_pines_corrected;        label_gt = indian_pines_gt;
end
data3D = data3D./max(data3D(:));

% super-pixels segmentation
num_Pixel = 25;
labelsA = cubseg(data3D, num_Pixel);
[fea, gnd, labelsA] = Labeled_dataSuperPixel(data3D, label_gt, labelsA);

[nSmp,nFea] = size(fea);
nClass = length(unique(gnd));
nKmeans = 10;
lambda = 100;
noise = 0.9;
feaNum = 25;

%print the setup information
disp(['Dataset: ',dataset]);
disp(['class_num=',num2str(nClass),',','num_kmeans=',num2str(nKmeans)]);

%Clustering using selected features
result_path = strcat(dataset);
rand('twister',5489);
arrACC = zeros(nKmeans,1);
arrNMI_sqrt = zeros(nKmeans,1);
arrPurity = zeros(nKmeans,1);
arrKappa = zeros(nKmeans,1);

% construct the affinity matrix for samples
Sa = Cubseg_Gen_adj_2D(fea,labelsA);
A_bar = Sa + speye(nSmp);
da = sum(A_bar);
da_sqrt = 1.0./sqrt(da);
da_sqrt(da_sqrt == Inf) = 0;
DHa = diag(da_sqrt);
DHa = sparse(DHa);
A_n = DHa * sparse(A_bar) * DHa;

result_path = strcat(dataset,'\','MGSR_Seg_',num2str(num_Pixel),'_noise_',num2str(noise),'_lambda_',num2str(lambda),'_result.mat');
mtrResult = [];
W = MGSR(fea, A_n, noise, lambda);
[junk, index] = sort(sum(W.*W,2),'descend');
newfea = fea(:,index);          

sel_fea = newfea(:,1:feaNum);
rand('twister',5489);
arrACC = zeros(nKmeans,1);
arrNMI_sqrt = zeros(nKmeans,1);
arrPurity = zeros(nKmeans,1);
arrKappa = zeros(nKmeans,1);
for i = 1:nKmeans
	label(:,i) = litekmeans(sel_fea,nClass,'Replicates',1);
	[arrACC(i), arrNMI_sqrt(i), arrPurity(i), arrKappa(i)] = evaluate_results_clustering(label(:,i), gnd);
end
ACCmean = mean(arrACC);         ACCstd = std(arrACC);
NMImean = mean(arrNMI_sqrt);    NMIstd = std(arrNMI_sqrt);
Puritymean = mean(arrPurity);   Puritystd = std(arrPurity);
Kappamean = mean(arrKappa);     Kappastd = std(arrKappa);
mtrResult = [mtrResult,[feaNum,ACCmean,NMImean,Puritymean,Kappamean]'];
save(result_path,'mtrResult','index');      

f = 1;
