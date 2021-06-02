function evaluate_svm_series(config)

%%%%%%%%%%%%%%%%
% local config %
%%%%%%%%%%%%%%%%
data_dir = config.data_dir;
code_dir = config.code_dir;
save_dir = config.save_dir;
sub_num = config.sub_num;
nb_senator = config.nb_senator;
dataset_num = config.dataset_num;
win_num = config.win_num;
nb_init = config.nb_init;
C = config.C;
kernel_para = config.kernel_para;
beta = config.beta;
gamma = config.gamma;

%%%%%%%%%%
% buffer %
%%%%%%%%%%
acc_svm = zeros(dataset_num, sub_num);
acc_svm_transfered_1 = zeros(dataset_num, sub_num);
acc_svm_transfered_2 = zeros(dataset_num, sub_num);

for dataset_ind = 1:dataset_num
    if dataset_ind == 1
        config.mov_num = config.mov_1dof_num;
        mov_num = config.mov_1dof_num;
    else
        config.mov_num = config.mov_2dof_num;
        mov_num = config.mov_2dof_num;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % load features, labels, and optimized parameters %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cd(data_dir);
    load(['Raw_F_c_', num2str(dataset_ind), 'dof.mat']);
    cd(code_dir);
    
    % local buffer
    local_z_mu = zeros(sub_num, size(F, 3));
    local_z_sigma = zeros(sub_num, size(F, 3));
    SVMs = [];
    
    %%%%%%%%%%%%%%%%%
    % train 25 SVMs %
    %%%%%%%%%%%%%%%%%
    for sub_ind = 1:sub_num
        % preparation
        data = squeeze(F(sub_ind, :, :));
        label = c(sub_ind, :)';
        cmd = ['-q -s 0 -t 2 -b 1 -c ', num2str(C), '-g ', num2str(kernel_para)]; % RBF kernel (with probability estimates)
        
        % normalization
        [ZF, local_z_mu(sub_ind, :), local_z_sigma(sub_ind, :)] = zscore(data);
        
        % train model
        SVMs = [SVMs; svmtrain(label, ZF, cmd)];
    end
    
    disp(['train ', num2str(sub_num), ' SVMs done'])
    
    %%%%%%%%%%%%%%
    % evaluation %
    %%%%%%%%%%%%%%
    for sub_ind = 1:sub_num
        % preparation
        sub_ind_seq = 1:1:sub_num;
        sub_ind_seq(sub_ind) = [];
        
        target = squeeze(F(sub_ind,:,:));
        target_L = c(sub_ind,:)';

        % data separation (in this case, we don't need validation data)
        S_cal = target(1:mov_num*win_num,:); % 1st trial
        L_cal = target_L(1:mov_num*win_num);
        S_tes = target(1+mov_num*win_num*2:end,:); % 3rd-5th trials
        L_tes = target_L(1+mov_num*win_num*2:end,:);
    
        [nb_cal, ~] = size(S_cal);
        [nb_tes, ~] = size(S_tes);
        
        % calculate performance of each SVM classifier for calibration data
        weights = zeros(sub_num-1, 1);
        
        for i = 1:sub_num-1
            % normalization
            S_cal_dammy = (S_cal - local_z_mu(sub_ind_seq(i), :)) ./ local_z_sigma(sub_ind_seq(i), :);
        
            % SVM
            [pred, ~, ~] = svmpredict(L_cal, S_cal_dammy, SVMs(sub_ind_seq(i)), '-q');
            weights(i) = sum(pred==L_cal)/length(L_cal);
        end
        
        [~, senator_index] = sort(weights,'descend');    

        naive_prob = zeros(length(L_tes), mov_num);
        transfered_1_prob = zeros(length(L_tes), mov_num); % STM
        transfered_2_prob = zeros(length(L_tes), mov_num); % SS-STM
        
        for nb_senator_ind = 1:nb_senator         
            % collect source data
            source = squeeze(F(sub_ind_seq(senator_index(nb_senator_ind)), :, :));
            source_L = c(sub_ind_seq(senator_index(nb_senator_ind)), :)';
            
            % normalization
            S_cal_dammy = (S_cal - local_z_mu(sub_ind_seq(senator_index(nb_senator_ind)), :)) ./ local_z_sigma(sub_ind_seq(senator_index(nb_senator_ind)), :);
            S_tes_dammy = (S_tes - local_z_mu(sub_ind_seq(senator_index(nb_senator_ind)), :)) ./ local_z_sigma(sub_ind_seq(senator_index(nb_senator_ind)), :);
            [source, ~, ~] = zscore(source);
            
            % naive performance
            [~, ~, temp_prob] = svmpredict(L_tes, S_tes_dammy, SVMs(sub_ind_seq(senator_index(nb_senator_ind))), '-q -b 1');
            naive_prob = naive_prob + temp_prob*weights(senator_index(nb_senator_ind));
 
            % transfer to make S_val more familiar to source SVM
            train_x = source;
            train_y = source_L;
        
            % STM
            [S_transfered_1] = supervised_STM(train_x, train_y, S_cal_dammy, L_cal, S_tes_dammy, nb_init, mov_num, beta, gamma);
            [~, ~, temp_prob] = svmpredict([L_cal; L_tes], S_transfered_1, SVMs(sub_ind_seq(senator_index(nb_senator_ind))), '-q -b 1');
            temp_prob = temp_prob(nb_cal+1:nb_cal+nb_tes,:);
            transfered_1_prob = transfered_1_prob + temp_prob*weights(senator_index(nb_senator_ind));

            % SS-STM
            config.beta = beta;
            config.gamma = gamma;
            [S_transfered_2] = semi_supervised_STM(train_x, train_y, S_cal_dammy, L_cal, S_tes_dammy, nb_init, SVMs(sub_ind_seq(senator_index(nb_senator_ind))), config);
            [~, ~, temp_prob] = svmpredict([L_cal; L_tes], S_transfered_2, SVMs(sub_ind_seq(senator_index(nb_senator_ind))), '-q -b 1');
            temp_prob = temp_prob(nb_cal+1:nb_cal+nb_tes,:);
            transfered_2_prob = transfered_2_prob + temp_prob*weights(senator_index(nb_senator_ind));
        end
        
        % ensemble strategy-based recognition
        [~, pred_naive_temp] = max(naive_prob');
        acc_svm(dataset_ind, sub_ind) = sum(pred_naive_temp'==L_tes)/length(L_tes);
       
        [~, pred_transfered_1_temp] = max(transfered_1_prob');
        acc_svm_transfered_1(dataset_ind, sub_ind) = sum(pred_transfered_1_temp'==L_tes)/length(L_tes); 
        
        [~, pred_transfered_2_temp] = max(transfered_2_prob');
        acc_svm_transfered_2(dataset_ind, sub_ind) = sum(pred_transfered_2_temp'==L_tes)/length(L_tes); 

        disp(['dataset ', num2str(dataset_ind), ' sub ', num2str(sub_ind)])
        disp(['Naive acc (SVM) = ', num2str(acc_svm(dataset_ind, sub_ind)), ', STM acc = ', num2str(acc_svm_transfered_1(dataset_ind, sub_ind)), ', SS-STM acc = ', num2str(acc_svm_transfered_2(dataset_ind, sub_ind))]);
    end
end

%%%%%%%%%%%%%%%%
% save results %
%%%%%%%%%%%%%%%%
cd(save_dir);
filename = 'results_svm';
save(filename,'acc_svm', 'acc_svm_transfered_1','acc_svm_transfered_2');
cd(code_dir);