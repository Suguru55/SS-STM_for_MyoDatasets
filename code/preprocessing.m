function preprocessing(config)

%%%%%%%%%%%%%%%%%%%%
% set local config %
%%%%%%%%%%%%%%%%%%%%
sub_num = config.sub_num;
win_num = config.win_num;
trial_num = config.trial_num;
mov_1dof_num = config.mov_1dof_num;
mov_2dof_num = config.mov_2dof_num;
ch_num = config.ch_num;
feat_dim_num = config.feat_dim_num;
win_size = config.win_size;
win_inc = config.win_inc;
data_dir = config.data_dir;
code_dir = config.code_dir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data, segmentation, and feature extraction %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% for 1-DOF motions
F = zeros(sub_num, win_num*trial_num*mov_1dof_num, ch_num*feat_dim_num);
c = zeros(sub_num, win_num*trial_num*mov_1dof_num);
emg = cell(sub_num, mov_1dof_num, trial_num);

for sub_ind = 1:sub_num
    % load data
    s_data = load_1dof_data(config, sub_ind);
    
    % extract epochs using sample entropy;
    s_epochs = extract_1dof_epochs(config,s_data);
    
    % extract features and classes
    feat = []; class = [];
    
    for trial_ind = 1:trial_num
        for mov_ind = 1:mov_1dof_num 
            s_feat = extract_feature(s_epochs{mov_ind, trial_ind}, win_size, win_inc);
            s_class = ones(size(s_feat, 1), 1).*mov_ind;
            
            feat = [feat; s_feat];
            class = [class; s_class];
        end
    end
    % store filtered epochs, features, and classes
    F(sub_ind, :, :) = feat;
    c(sub_ind, :) = class;
    emg(sub_ind, :, :) = s_epochs;
    
    disp(['1-DOF sub', num2str(sub_ind), ' done'])
end

cd(data_dir);
filename = 'Raw_F_c_1dof';
save(filename, 'emg', 'F', 'c');
cd(code_dir);

%% for 2-DOF motions
F = zeros(sub_num, win_num*trial_num*mov_2dof_num, ch_num*feat_dim_num);
c = zeros(sub_num, win_num*trial_num*mov_2dof_num);
emg = cell(sub_num, mov_2dof_num, trial_num);

for sub_ind = 1:sub_num
    % load data
    s_data = load_2dof_data(config, sub_ind);
    
    % extract epochs using sample entropy;
    s_epochs = extract_2dof_epochs(config, s_data);
    
    % extract features and classes
    feat = []; class = [];
    
    for trial_ind = 1:trial_num
        for mov_ind = 1:mov_2dof_num 
            s_feat = extract_feature(s_epochs{mov_ind, trial_ind}, win_size, win_inc);
            s_class = ones(size(s_feat, 1), 1).*mov_ind;
            
            feat = [feat; s_feat];
            class = [class; s_class];
        end
    end
    % store filtered epochs, features, and classes
    F(sub_ind, :, :) = feat;
    c(sub_ind, :) = class;
    emg(sub_ind, :, :) = s_epochs;
    
    disp(['2-DOF sub',num2str(sub_ind),' done'])
end

cd(data_dir);
filename = 'Raw_F_c_2dof';
save(filename,'emg', 'F', 'c');
cd(code_dir);