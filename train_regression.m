% Training EEG data using regression
%
% Written by Giyoung Jeon
% Probabilistic Artificial Intelligence Lab at UNIST
% v1.0 July, 14th, 2015

if(~exist('../Dataset/EEG_Detection/EEG_train.mat'))
    train_path = '../Dataset/EEG_detection/train/';
    subj_num = 12;
    series_num = 8;
    train_data = [];
    train_label = [];
    for sidx=1:subj_num
        for idx=1:series_num
            train_data = [train_data; read_data_csv(strcat(train_path,'subj',int2str(sidx),'_series',int2str(idx),'_data.csv'))];
            train_label = [train_label; read_label_csv(strcat(train_path,'subj',int2str(sidx),'_series',int2str(idx),'_events.csv'))];
        end
    end
    save('../Dataset/EEG_Detection/EEG_train.mat', 'train_data', 'train_label', '-v7.3');
    clear all;
end
disp('Loading Data...');
load('../Dataset/EEG_Detection/EEG_train.mat');

train_data_div = cell(1,size(train_label,2));
for idx = 1:size(train_label,2)
    train_data_div{idx} = train_data(train_label(:,idx)==1,:);
    train_data_div{idx} = bsxfun(@rdivide, bsxfun(@minus, train_data_div{idx}, mean(train_data_div{idx})), std(train_data_div{idx}));
end

if(~exist('./glm_model.mat'))
    disp('Start training regression...');
    glm_model = cell(1,size(train_label,2));
    for idx = 1:size(train_label,2)
        disp(sprintf('training label%d...',idx));
        glm_coeff = zeros(size(train_data,2));
        for jdx = 1:size(train_data,2)
            tmp_data = train_data_div{idx};
            tmp_target = tmp_data(:,jdx);
            tmp_data(:,jdx) = 1;
            glm_coeff(:,jdx) = glmfit(tmp_data, tmp_target,'normal','constant','off');
        end
        glm_model{idx} = glm_coeff;
    end
    save('./glm_model.mat','glm_model');
end