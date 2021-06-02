function evaluate_lda_series(config)

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
tau = config.tau;
lambda = config.lambda;

%%%%%%%%%%
% buffer %
%%%%%%%%%%
acc_lda = zeros(dataset_num, sub_num);
acc_lda_transfered = zeros(dataset_num, sub_num);

for dataset_ind = 1:dataset_num
    if dataset_ind == 1
        mov_num = config.mov_1dof_num;
    else
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
    LDAs = cell(1, sub_num);
    
    %%%%%%%%%%%%%%%%%
    % train 25 LDAs %
    %%%%%%%%%%%%%%%%%
    for sub_ind = 1:sub_num
        % preparation
        data = squeeze(F(sub_ind, :, :));
        label = c(sub_ind, :)';
    
        % normalization
        [ZF, local_z_mu(sub_ind, :), local_z_sigma(sub_ind, :)] = zscore(data);
        
        % train model
        LDAs{sub_ind} =  fitcdiscr(ZF, label, 'DiscrimType', 'linear');
    end
    
    disp(['train ', num2str(sub_num), ' LDAs done'])

    %%%%%%%%%%%%%%
    % evaluation %
    %%%%%%%%%%%%%%
    for sub_ind = 1:sub_num
        % preparation
        sub_ind_seq = 1:1:sub_num;
        sub_ind_seq(sub_ind) = [];
        
        target = squeeze(F(sub_ind, :, :));
        target_L = c(sub_ind, :)';
        
        % data separation (in this case, we don't need validation data)
        S_cal = target(1:mov_num*win_num, :); % 1st trial
        L_cal = target_L(1:mov_num*win_num);
        S_tes = target(1+mov_num*win_num*2:end, :); % 3rd-5th trials
        L_tes = target_L(1+mov_num*win_num*2:end);
        
        % prepare within subject classifier
        [ZF, ~, ~] = zscore(S_cal);
        model_targ = fitcdiscr(ZF, L_cal, 'DiscrimType', 'linear');
    
        % calculate performance of each LDA classifier for calibration data
        weights = zeros(sub_num-1, 1);
        
        for i = 1:1:sub_num-1
            % normalization
            S_cal_dammy = (S_cal - local_z_mu(sub_ind_seq(i), :)) ./ local_z_sigma(sub_ind_seq(i), :);
             
            % LDA
            pred = predict(LDAs{sub_ind_seq(i)}, S_cal_dammy);
            weights(i) = sum(pred==L_cal)/length(L_cal);             
        end
        
        [~, senator_index] = sort(weights,'descend');    

        naive_prob = zeros(length(L_tes), mov_num);
        transfered_prob = zeros(length(L_tes), mov_num);
        
        for nb_senator_ind = 1:nb_senator
            % normalization
            S_tes_dammy = (S_tes - local_z_mu(sub_ind_seq(senator_index(nb_senator_ind)), :)) ./ local_z_sigma(sub_ind_seq(senator_index(nb_senator_ind)), :);
            
            % naive prediction
            naive_mu = LDAs{sub_ind_seq(senator_index(nb_senator_ind))}.Mu;
            naive_sigma = LDAs{sub_ind_seq(senator_index(nb_senator_ind))}.Sigma;
            
            for j = 1:mov_num
                temp_prob = S_tes_dammy*pinv(naive_sigma')*naive_mu(j, :)' - (1/2)*naive_mu(j, :)*pinv(naive_sigma')*naive_mu(j, :)' - log(2);
                naive_prob(:, j) = naive_prob(:, j) + temp_prob*weights(senator_index(nb_senator_ind));
            end
            
            % covariate shift adaptation
            transfered_mu = (1-tau).*naive_mu + tau.*model_targ.Mu;
            transfered_sigma = (1-lambda).*naive_sigma + lambda.*model_targ.Sigma;
        
            for j = 1:mov_num
                temp_prob = S_tes_dammy*pinv(transfered_sigma')*transfered_mu(j, :)' - (1/2)*transfered_mu(j, :)*pinv(transfered_sigma')*transfered_mu(j, :)' - log(2);
                transfered_prob(:, j) = transfered_prob(:, j) + temp_prob*weights(senator_index(nb_senator_ind));
            end
        end
            
        % ensemble strategy-based recognition
        [~, pred_naive_temp] = max(naive_prob');
        acc_lda(dataset_ind, sub_ind) = sum(pred_naive_temp'==L_tes)/length(L_tes);      

        [~, pred_transfered_temp] = max(transfered_prob');
        acc_lda_transfered(dataset_ind, sub_ind) = sum(pred_transfered_temp'==L_tes)/length(L_tes); 
        
        disp(['dataset ', num2str(dataset_ind), ' sub ', num2str(sub_ind)])
        disp(['Naive acc (LDA) = ', num2str(acc_lda(dataset_ind, sub_ind)), ', Transfered acc = ', num2str(acc_lda_transfered(dataset_ind, sub_ind))]);        
    end
end

%%%%%%%%%%%%%%%%
% save results %
%%%%%%%%%%%%%%%%
cd(save_dir);
filename = 'results_lda';
save(filename,'acc_lda', 'acc_lda_transfered');
cd(code_dir);