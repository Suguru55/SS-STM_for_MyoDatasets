# SS-STM_for_MyoDatasets

This sample scripts and datasets are described in the paper "Semi-supervised style transfer mapping-based framework for sEMG-based pattern recognition with 1- or 2-DoF forearm motions" submitted to XXXX.<br />

__\<Description\>__<br />
After changing your directories in set_config.m and downloading getxxfeat.m, you can use this codes.<br />
This project has three folders:<br />
1. data<br />
   - 22-class (1-DoF 8-class and 2-DoF 14-class) EMG data from 25 subjects<br />
        - The detail is described in Table 1.<br />
   - csv files (each data has 5-s information)<br />
   - M means the motion label (e.g., M1 means resting state and M2 means wrist flexion)<br />
   - T means the number of trials<br />
   - After applying preprocessing.m, Raw_F_c_1dof.mat and Raw_F_c_2dof.mat will be added in this folder.<br />

2. code<br />
   this folder has one main m.file named main_script that uses:<br />
   - set_config<br />
   - preprocessing<br />
        - load_1dof_data<br />
        - load_2dof_data<br />
        - extract_1dof_epochs<br />
        - extract_2dof_epochs<br />
        - extract_features<br />
        you can get the following m.files from <a href="http://www.sce.carleton.ca/faculty/chan/index.php?page=matlab" target="_blank">here</a><br />
            - getrmsfeat<br />
            - getmavfeat<br />
            - getzcfeat<br />
            - getsscfeat<br />
            - getwlfeat<br />
            - getarfeat<br />
    - evaluate_lda_series<br />
    - evaluate_svm_series<br />
        you can make the m scripts, svmtrain.m and svmpredict.m from <a href="https://www.csie.ntu.edu.tw/~cjlin/libsvm/#download" target="_blank">here</a><br />
        - svmtrain (LIBSVM)<br />
        - svmpredict (LIBSVM)<br />
        - supervised_STM<br />
            - find_target<br />
            - calculate_A_b<br />
        - semi-supervised_STM<br />
            - find_target<br />
            - calculate_A_b<br />
            - confidence<br />
    - visualization<br />
        
3. resuts<br />
   this folder will store results_lda.mat, results_svm.mat, results.fig and results.jpg.<br />

__\<Environments\>__<br />
Windows 10<br />
MATLAB R2020a<br />
 1. Signal Processing Toolbox<br />
 2. Statics and Machine Learning Toolbox<br />