# SS-STM_for_MyoDatasets

This sample scripts and datasets are described in the paper XXXXXXXX submitted to XXXX.

__\<Description\>__<br />
After changing your directories in set_config.m and downloading getxxfeat.m, you can use this codes.<br />
This project has four folders:<br />
1. data<br />
   - 22-class (1-DoF 8-class and 2-DoF 14-class) EMG data from 25 subjects
   - csv files (each data has 5-s information)
   - M means the motion label (e.g., M1 means resting state and M2 means wrist flexion)
   - T means the number of trials

2. code (Incomplete)<br />
   this folder has one main m.file named main_script that uses:<br />
   - set_config<br />
   - preprocessing<br />
        - extract_feature<br />
        you can get the following m.files from <a href="http://www.sce.carleton.ca/faculty/chan/index.php?page=matlab" target="_blank">here</a><br />
            - getrmsfeat<br />
            - getmavfeat<br />
            - getzcfeat<br />
            - getsscfeat<br />
            - getwlfeat<br />
            - getarfeat<br />
    - intraday<br />
        - plot_figure6_and_figure7<br />
    - interday<br />
        - labeling<br />
        - interday_recog<br />
        - plot_figure8<br />
    - interday_sub<br />
        - plot_figure9<br />
        
3. resuts <br />
   this folder will store all results (but this main script requires about 10GB for saving result data, please take care before using it)

__\<Environments\>__<br />
MATLAB R2020a<br />
 1. Signal Processing Toolbox
 2. Statics and Machine Learning Toolbox
 3. 
