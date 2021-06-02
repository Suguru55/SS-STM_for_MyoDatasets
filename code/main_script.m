%% main script
% Objective: 
%  To assess the efficiency of support vector machine with transfer learning for sEMG pattern recognition
%
% Dataset:
%  An 22-motion dataset recorded from 25 subjects 
%   - Stimulus frequencies        : 22 types of motions (we separate the motions into 8 and 14 classes)
%   - # of channels               : 8
%   - # of trials                 : 5
%   - Data length of epochs       : 1.5 seconds (onset points were detected by sample entropy)
%   - Device                      : Myo Gesture Control Armband
%   - Sampling rate               : 200 Hz
%
% Features:
%  - TDAR features 
%     - Dimension of feature        : 11 per channel (total 88)
%     - Window size                 : 250 ms
%     - Shifting size of the window : 50 ms
%
% Transfer leanring techniques:
%  - CSA
%  - STM
%
% Classifiers:
%  - LDA
%  - SVM
%
% Author:
%  Suguru Kanoga, 2-June-2021
%  Artificial Intelligence Research Center, National Institute of Advanced
%  Industrial Science and Technology
%  E-mail: s.kanouga@aist.go.jp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Clear workspace
clear all
close all

% clc
% help main

%% Set config
main_dir = 'C:\Users\eyed164\Documents\GitHub\SS-STM_for_MyoDatasets'; % change to your directory
config = set_config(main_dir);
addpath('C:\toolbox\libsvm-master\matlab'); % change to your directory

%% Preprocessing stream (once you processed this section, you can skip this section)
% load data, segmentation, and feature extraction
preprocessing(config);

%% Main loop
% calculate recognition accuracies
evaluate_lda_series(config);
evaluate_svm_series(config);

% visualize the results
visualization(config);