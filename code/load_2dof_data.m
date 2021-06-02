function data = load_2dof_data(config, sub_ind)

eval(sprintf('sub_dir = [''\\sub%d'']',sub_ind));
cd([config.data_dir, sub_dir]);

data = cell(config.mov_2dof_num, config.trial_num);
    
for mov_ind = 1:config.mov_2dof_num
    for trial_ind = 1:config.trial_num
        eval(sprintf('filename = [''M%dT%d.csv'']', mov_ind+config.mov_1dof_num, trial_ind));
        data{mov_ind, trial_ind} = csvread(filename);
    end
end

cd(config.code_dir);