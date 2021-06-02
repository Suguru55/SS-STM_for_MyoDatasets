function struct = set_config(dir)

% dir
struct.data_dir = [dir, '\data'];
struct.code_dir = [dir, '\code'];
struct.save_dir = [dir, '\results'];

cd(struct.code_dir);

% parameters
struct.age = [27; 31; 24; 26; 23; 26; 30; 27; 29; 27;...  % 1-10th sub 
              28; 21; 23; 22; 21; 23; 21; 22; 24; 23;...  % 11-20th sub
              20; 23; 23; 23; 24];    % 21-25th sub
          
struct.sex = [0; 0; 0; 0; 0; 0; 1; 0; 0; 0;...
              1; 1; 0; 0; 1; 0; 0; 1; 0; 0;...
              1; 0; 0; 1; 0]; % 0: M, 1: F
          
struct.dhand = [0; 0; 0; 0; 0; 0; 0; 0; 0; 0;...
                1; 0; 1; 0; 1; 0; 0; 0; 0; 0;...
                1; 0; 1; 0; 0]; % Right: 0, Left: 1 (Regardless of the dominant arm, we set myo device on the right forearm)

struct.sub_num = 25;
struct.mov_1dof_num = 8;
struct.mov_2dof_num = 14;
struct.fs = 200;
struct.process_dur = 1.5;         % analysis window (1.5 s)
struct.ch_num = 8;
struct.trial_num = 5;
struct.dataset_num = 2;

struct.fs_pass = 15;
struct.fil_order = 5;

struct.dim = 2;                   % dimension for modified sample entropy
struct.samp_win = 8;              % window size for modified sample entropy (40 ms)
struct.samp_th = 0.4;             % threshold for normalized samp_en
struct.trial_dur = 6;             % 1 trial needs 6 s

struct.win_size = 50;             % 250ms window
struct.win_inc = 10;              % 50ms overlap
struct.win_num = 26;              % the number of features per trial
struct.feat_dim_num = 11;         % 11 dimensions per 1 chennel

struct.C = 10;
struct.kernel_para = 10^-3;

% source selection
struct.nb_senator = 15;

% transfer learning
struct.tau = 0.5;
struct.lambda = 0.1;

struct.beta = 0.2;
struct.gamma = 0;
struct.cv_num = 4;                % parameter tuning
struct.nb_init = 15;
struct.STM_iter_num = 5;
struct.a = 0.8;                   % confedence of labeled data