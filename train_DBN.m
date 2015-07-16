% Training EEG data using DBN
%
% Written by Giyoung Jeon
% Probabilistic Artificial Intelligence Lab at UNIST
% v1.0 July, 2nd, 2015

addpath(genpath('./'));
train_path = '../Dataset/EEG_detection/train/';
data_list = {};
event_list = {};
for sidx=1:12
    for idx=1:8
        dataname = strcat('subj',int2str(sidx),'_series',int2str(idx),'_data.csv');        
        eventname = strcat('subj',int2str(sidx),'_series',int2str(idx),'_events.csv');
        data_list{(sidx-1)*8+idx} = dataname;
        event_list{(sidx-1)*8+idx} = eventname;
    end
end

rand_idx = randperm(12*8);
x_dim = 32;
y_dim = 6;
disp('dbn setup...');
model = cell(1,y_dim);
for cidx = 1:y_dim
    dbn.sizes = [100 100];
    opts.numepochs =   10;
    opts.batchsize = 100;
    opts.momentum  =   0;
    opts.alpha     =   0.1;
    model{cidx} = dbnsetup(dbn, zeros(1,32), opts);
end

if(exist('./dbn_pretrained.mat'))
    disp('loading dbn...');
    load('./dbn_pretrained.mat');
else
    disp('dbn pretraining...');
    for batch = 1:size(rand_idx)
        train_data = read_data_csv(strcat(train_path,data_list{rand_idx(batch)}));
        train_data = train_data(1:(end-mod(size(train_data,1),100)),:);
        parfor midx = 1:y_dim
            model{midx} = dbntrain(model{midx}, train_data, opts);
        end
    end
    disp('dbn model saving...');
    save('./dbn_pretrained.mat','model');
end
if(exist('./nn_trained.mat'))
    disp('loading nn...');
    load('./nn_trained.mat');
else
    disp('nn training...');
    parfor midx = 1:y_dim
        model{midx} = dbnunfoldtonn(model{midx}, 2);
        model{midx}.activation_function = 'sigm';
    end

    for batch = 1:size(rand_idx)
        train_data = read_data_csv(strcat(train_path,data_list{rand_idx(batch)}));
        train_label = read_label_csv(strcat(train_path,event_list{rand_idx(batch)}));
        train_data = train_data(1:(end-mod(size(train_data,1),100)),:);
        train_label = train_label(1:(end-mod(size(train_label,1),100)),:);
        parfor midx = 1:y_dim
            model{midx} = nntrain(model{midx}, train_data, [~train_label(:,midx),train_label(:,midx)], opts);
        end
    end

    disp('nn model saving...');
    save('./nn_trained.mat','model');
end
% parfor midx = 1:y_dim
%     pred(:,midx) = nnpredict(model{midx}, test_x);
% end
% 
% save('./prediction.mat','pred');
% csvwrite('./prediction.csv','pred');