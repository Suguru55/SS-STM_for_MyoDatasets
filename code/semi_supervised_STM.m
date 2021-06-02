function [S_transfered] = semi_supervised_STM(train_x, train_y, S_cal, L_cal, S_val, nb_init, svm, config)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Style transfer mapping in semi-supervised way

% train_x, train_y       : used to find prototypes and train subject-free classifiers
% beta_coeff, gamma_coeff: hyper-parameters to control the tradeoff between
%                          nontransfer and overtransfer (0:0.2:3)
% iter_num               : iteration number for self_training (semisupervised learning)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set local config
beta_coeff = config.beta;
gamma_coeff = config.gamma;
iter_num = config.STM_iter_num;

[nb_cal, m] = size(S_cal);
[nb_val, ~] = size(S_val);
T_cal = zeros(nb_cal, m);        % target of labeled data
T_val = zeros(nb_val, m);        % target of unlabeled data
f_cal = ones(nb_cal,1);          % confidence of labeled data (in supervised STM, all values are 1)
f_val = ones(nb_val,1);          % confidence of unlabeled data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find prototype (cluster center) of each class %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%m_lib = zeros(config.mov_num,nb_init,size(S_cal,2));
m_lib = cell(1, config.mov_num);
u_lib = zeros(config.mov_num, size(S_cal,2));
opts = statset('UseParallel', 1);

parfor i = 1:config.mov_num
    [id, ~] = find(train_y(:)==i);
    temp_train_x = train_x(id,:);
    u_lib(i,:) = mean(temp_train_x,1);
    [~, m_lib{i}] = kmeans(temp_train_x, nb_init, 'MaxIter', 1000, 'Replicates', 10, 'Option', opts);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% learn a supervised STM {A0, b0} with labeled data %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parfor i = 1:nb_cal
    temp_S_cal = S_cal(i,:);
    T_cal(i,:) = find_target(temp_S_cal, squeeze(m_lib{L_cal(i)}));
end

[A0, b0] = calculate_A_b(S_cal, T_cal, f_cal, beta_coeff, gamma_coeff);

% transform all S data by A0 and b0
S_cal_trans = zeros(nb_cal, m);    % labeled data transformed by A0, b0
S_val_trans = zeros(nb_val, m);    % unlabeled data transformed by A0, b0

parfor i = 1:nb_cal
    S_cal_trans(i,:) = (A0*S_cal(i,:)' + b0)';
end

parfor i = 1:nb_val
    S_val_trans(i,:) = (A0*S_val(i,:)' + b0)';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% semisupervised learning %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update T_cal and reset the confidence as a
parfor i = 1:nb_cal
    temp_S_cal = S_cal_trans(i,:);
    T_cal(i,:) = find_target(temp_S_cal,squeeze(m_lib{L_cal(i)}));
end

f_cal = config.a*f_cal;

% begin self training
A = eye(m,m);
b = zeros(m,1);

for iter = 1:iter_num
    parfor i = 1:nb_val 
        temp_S_val = S_val_trans(i,:);       % a sample in S_val_trans
        mapped_S_val = (A*temp_S_val' + b)';
        [y_arrow, ~, ~] = svmpredict(1,mapped_S_val, svm, '-q');
        
        T_val(i,:) = find_target(temp_S_val, squeeze(m_lib{y_arrow}));
        f_val(i) = confidence(mapped_S_val, u_lib);
    end
    S_trans = [S_cal_trans; S_val_trans];
    T = [T_cal; T_val];
    f = [f_cal; f_val];
    
    [A, b] = calculate_A_b(S_trans, T, f, beta_coeff, gamma_coeff);
end

S_transfered = zeros(nb_cal+nb_val, m);

parfor i = 1:nb_cal+nb_val
    S_transfered(i,:) = (A*S_trans(i,:)' + b)';
end
