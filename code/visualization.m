function visualization(config)

cd(config.save_dir);
load('results_lda')
load('results_svm')
cd(config.code_dir);
colors = [255, 0, 102; 0, 51, 204]/255;
x = [1,2, 4,5,6];

% bar表示させたい
h = figure(1);
subplot(1,2,1)
bar(x(1), mean(acc_lda(1,:)), 'FaceColor', colors(1,:), 'FaceAlpha', 0.6);hold on
bar(x(2), mean(acc_lda_transfered(1,:)), 'FaceColor', colors(1,:), 'FaceAlpha', 1);
bar(x(3), mean(acc_svm(1,:)), 'FaceColor', colors(2,:), 'FaceAlpha', 0.6);
bar(x(4), mean(acc_svm_transfered_1(1,:)), 'FaceColor', colors(2,:), 'FaceAlpha', 0.8);
bar(x(5), mean(acc_svm_transfered_2(1,:)), 'FaceColor', colors(2,:), 'FaceAlpha', 1);
errorbar(x(1), mean(acc_lda(1,:)), std(acc_lda(1,:)), 'k');
errorbar(x(2), mean(acc_lda_transfered(1,:)), std(acc_lda_transfered(1,:)), 'k');
errorbar(x(3), mean(acc_svm(1,:)), std(acc_svm(1,:)), 'k');
errorbar(x(4), mean(acc_svm_transfered_1(1,:)), std(acc_svm_transfered_1(1,:)), 'k');
errorbar(x(5), mean(acc_svm_transfered_2(1,:)), std(acc_svm_transfered_2(1,:)), 'k');hold off
grid on
title('1 DoF')
set(gca,'FontName','Times New Roman','FontSize',20)
ylim([0.3 1])
ylabel('Accuracy (%)')
subplot(1,2,2)
bar(x(1), mean(acc_lda(2,:)), 'FaceColor', colors(1,:), 'FaceAlpha', 0.6);hold on
bar(x(2), mean(acc_lda_transfered(2,:)), 'FaceColor', colors(1,:), 'FaceAlpha', 1);
bar(x(3), mean(acc_svm(2,:)), 'FaceColor', colors(2,:), 'FaceAlpha', 0.6);
bar(x(4), mean(acc_svm_transfered_1(2,:)), 'FaceColor', colors(2,:), 'FaceAlpha', 0.8);
bar(x(5), mean(acc_svm_transfered_2(2,:)), 'FaceColor', colors(2,:), 'FaceAlpha', 1);
errorbar(x(1), mean(acc_lda(2,:)), std(acc_lda(2,:)), 'k');
errorbar(x(2), mean(acc_lda_transfered(2,:)), std(acc_lda_transfered(2,:)), 'k');
errorbar(x(3), mean(acc_svm(2,:)), std(acc_svm(2,:)), 'k');
errorbar(x(4), mean(acc_svm_transfered_1(2,:)), std(acc_svm_transfered_1(2,:)), 'k');
errorbar(x(5), mean(acc_svm_transfered_2(2,:)), std(acc_svm_transfered_2(2,:)), 'k');hold off
grid on
title('2 DoFs')
set(gca,'FontName','Times New Roman','FontSize',20)
ylim([0.3 1])
ylabel('Accuracy (%)')    
legend('LDA','LDA with CSA','SVM','SVM with STM','SVM with SS-STM')
h.WindowState = 'maximized';
cd(config.save_dir);
figname = 'results';
saveas(gcf,figname,'fig');
saveas(gcf,figname,'jpg');
cd(config.code_dir);