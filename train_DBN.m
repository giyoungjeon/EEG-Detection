addpath(genpath('./'));
train_path = './data/train/';
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
for cidx = 1:y_dim
    dbn.sizes = [100 100];
    opts.numepochs =   10;
    opts.batchsize = 100;
    opts.momentum  =   0;
    opts.alpha     =   0.1;
    model{cidx} = dbnsetup(dbn, zeros(1,32), opts);
end

for batch = 1:size(rand_idx)
    train_data = read_data_csv(strcat(train_path,data_list{rand_idx(batch)}));
    parfor midx = 1:y_dim
        model{midx} = dbntrain(model{midx}, train_data, opts);
    end
end

save('./dbn_pretrained.mat','model');


parfor midx = 1:y_dim
    model{midx} = dbnunfoldtonn(model{midx}, 2);
    model{midx}.activation_function = 'sigm';
end

for batch = 1:size(rand_idx)
    train_data = read_data_csv(strcat(train_path,data_list{rand_idx(batch)}));
    train_label = read_label_csv(strcat(train_path,event_list{rand_idx(batch)}));
    parfor midx = 1:y_dim
        model{midx} = nntrain(model{midx}, train_data, train_label(:,midx), opts);
    end
end

save('./nn_trained.mat','model');

% parfor midx = 1:y_dim
%     pred(:,midx) = nnpredict(model{midx}, test_x);
% end
% 
% save('./prediction.mat','pred');
% csvwrite('./prediction.csv','pred');