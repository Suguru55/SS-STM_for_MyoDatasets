function epochs = extract_1dof_epochs(config, all_data)

epochs = cell(config.mov_1dof_num, config.trial_num);

% fifth-order Buttorworth high-pass filter (cutoff freq.: 15 Hz) for EMG
Wn = config.fs_pass/(config.fs/2);           
n = config.fil_order;
[b, a] = butter(n, Wn, 'high');

for mov_ind = 1:config.mov_1dof_num
    for trial_ind = 1:config.trial_num
        data = all_data{mov_ind, trial_ind};
        
        % apply high-pass filter
        for i = 1:config.ch_num
            data(:, i) = filtfilt(b, a, data(:, i));  
        end   
        
        % extract epochs by modified muliscale sample entropy
        if mov_ind == 1 
            % if motion label is 'rest', onset detection can be avoided 
            epochs{mov_ind, trial_ind} = data(1+config.fs:config.fs+config.fs*1.5, :);
        else
            % detect onset point from 1 to 3 s
            dammy_data = data(1+config.fs*1:config.fs+config.fs*2, :);
            samp_en = zeros(config.ch_num, length(dammy_data)-config.samp_win);
            
            for ch_ind = 1:config.ch_num
                for n = 1:length(dammy_data)-config.samp_win
                    input = dammy_data(1+(n-1):config.samp_win+(n-1), ch_ind);  % 5ms shifting
                    r = 0.25 * std(input);                                      % tolerance
                    
                    correl = zeros(1, 2);
                    inputMat = zeros(config.dim+1, config.samp_win-config.dim);
                    
                    for i = 1:config.dim+1
                        inputMat(i, :) = input(i:config.samp_win-config.dim+i-1);
                    end
                    
                    for m = config.dim:config.dim+1
                        count = zeros(1, config.samp_win-config.dim);
                        tempMat = inputMat(1:m, :);
                       
                        for i = 1:config.samp_win-m
                            % calculate Chebyshev distance extcuding
                            % self-matching case
                            dist = max(abs(tempMat(:, i+1:config.samp_win-config.dim)-repmat(tempMat(:,i), 1, config.samp_win-config.dim-i)));
                           
                            % calculate Heaviside function of the distance
                            %D = (dist < r);
                            D = 1./(1 + exp((dist-0.5)/r)); % Sigmoid function
                            count(i) = sum(D)/(config.samp_win-config.dim);
                        end
                        correl(m-config.dim+1) = sum(count)/(config.samp_win-config.dim);
                    end
                    
                    samp_en(ch_ind, n) = log(correl(1)/correl(2));
                end
            end
            
            [maxvec, ~] = max(samp_en);
            [maxval, column] = max(maxvec);
            temp_samp = samp_en(samp_en(:, column)==maxval,:);
                
            [A, ~] = max(temp_samp, [], 2);
            temp_samp = temp_samp./repmat(A, 1, length(temp_samp));
                
            [~, col] = find(temp_samp > config.samp_th);
            if(size(col, 1)==0)
                col(1, 1) = 1; 
            end
            epochs{mov_ind, trial_ind} = data(col(1, 1)+config.fs:config.fs+(config.fs*1.5-1)+col(1, 1), :);            
        end
    end
end