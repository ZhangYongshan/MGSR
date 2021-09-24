    function [S] = Cubseg_Gen_adj_2D(data2D,labels)
    %   Cubseg_Gen_adj 根据构建的超像素分割图构建权重矩阵
    %  data2D  n*d
    %  labels  n*1   
    %Sij=exp(-(||Xi-Xj||2/lamda^2)) Xi和Xj同属一区域，其他为0
    data_col=data2D;
    [m,~]=size(data_col);
    %统计所取区域的类别及分布
    gt_col=labels;
    gt_cla=unique(gt_col);
    gt_num = length(gt_cla);

    dist_seg=[];
    i_seg=[];
    j_seg=[];
    for i=1:gt_num
       % fprintf('正在处理分割区域; %d\n',i);
        [v]=find(gt_col==gt_cla(i));   %存标签
        %  ci = length(find(gt_col==gt_cla(i)));   %求为i的个数
        ci = length(v);   %求为i的个数
        if ci==1
            continue
        end
        datai = data_col(v,:); %datai为data_col里项目值为i依次存的数据
        dist_seg_temp=[];%存一个区域的dist
        for j=1:ci
            % fprintf('区域: %d  特征: %d\n', i,j);
            temp=datai(j,:);
            %算欧式距离 
            [dist_temp]=temp.^2*ones(size(datai'))+ones(size(temp))*(datai').^2-2*temp*datai';
            dist_temp(dist_temp<0)=0;
            dist_temp(j)=0;
            dist_temp=sqrt(dist_temp);
            dist_seg_temp=[dist_seg_temp,dist_temp];%距离向量
            i_seg_tmp=[];
            i_seg_tmp(1:ci)=v(j);
            i_seg=[i_seg i_seg_tmp];
            j_seg=[j_seg v'];
        end
        temp=[];
        if ci>1
            dist_a=var(dist_seg_temp);%计算当前区域的方差
            temp=exp(-(dist_seg_temp.^2)./(2*dist_a^2));
        else
            temp=dist_seg_temp;
        end
        dist_seg=[dist_seg,temp];%权重向量
    end
    S=sparse(i_seg,j_seg,dist_seg,m,m);
    S = max(S, S');
        if  numel(find(isnan(S)))== 0 && sum(sum((S==S')==0))==0
            disp('邻接矩阵构建成功');
         else
            disp('邻接矩阵构建存在问题');
        end
    end
