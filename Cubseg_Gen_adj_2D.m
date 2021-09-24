    function [S] = Cubseg_Gen_adj_2D(data2D,labels)
    %   Cubseg_Gen_adj ���ݹ����ĳ����طָ�ͼ����Ȩ�ؾ���
    %  data2D  n*d
    %  labels  n*1   
    %Sij=exp(-(||Xi-Xj||2/lamda^2)) Xi��Xjͬ��һ��������Ϊ0
    data_col=data2D;
    [m,~]=size(data_col);
    %ͳ����ȡ�������𼰷ֲ�
    gt_col=labels;
    gt_cla=unique(gt_col);
    gt_num = length(gt_cla);

    dist_seg=[];
    i_seg=[];
    j_seg=[];
    for i=1:gt_num
       % fprintf('���ڴ���ָ�����; %d\n',i);
        [v]=find(gt_col==gt_cla(i));   %���ǩ
        %  ci = length(find(gt_col==gt_cla(i)));   %��Ϊi�ĸ���
        ci = length(v);   %��Ϊi�ĸ���
        if ci==1
            continue
        end
        datai = data_col(v,:); %dataiΪdata_col����ĿֵΪi���δ������
        dist_seg_temp=[];%��һ�������dist
        for j=1:ci
            % fprintf('����: %d  ����: %d\n', i,j);
            temp=datai(j,:);
            %��ŷʽ���� 
            [dist_temp]=temp.^2*ones(size(datai'))+ones(size(temp))*(datai').^2-2*temp*datai';
            dist_temp(dist_temp<0)=0;
            dist_temp(j)=0;
            dist_temp=sqrt(dist_temp);
            dist_seg_temp=[dist_seg_temp,dist_temp];%��������
            i_seg_tmp=[];
            i_seg_tmp(1:ci)=v(j);
            i_seg=[i_seg i_seg_tmp];
            j_seg=[j_seg v'];
        end
        temp=[];
        if ci>1
            dist_a=var(dist_seg_temp);%���㵱ǰ����ķ���
            temp=exp(-(dist_seg_temp.^2)./(2*dist_a^2));
        else
            temp=dist_seg_temp;
        end
        dist_seg=[dist_seg,temp];%Ȩ������
    end
    S=sparse(i_seg,j_seg,dist_seg,m,m);
    S = max(S, S');
        if  numel(find(isnan(S)))== 0 && sum(sum((S==S')==0))==0
            disp('�ڽӾ��󹹽��ɹ�');
         else
            disp('�ڽӾ��󹹽���������');
        end
    end
