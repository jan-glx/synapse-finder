if exist('ens','var')
    warning('variable ens already exists, skipping loading...\n')
else
    load(fullfile(savepath,'ens.mat'))
    if ~exist('prior','var')
        warining('setting prior to ''empirical'' ');
        prior='empirical';
    end
end
%% test
fprintf('computing loss over trees...\n');tic;
cumlossT=nan(ens.Trainable{1}.NTrained,ens.KFold);
lossT=nan(1,ens.KFold);
cumlossV=nan(ens.Trainable{1}.NTrained,ens.KFold);
lossV=nan(1,ens.KFold);
scoreT=cell(1,ens.KFold);
yT=cell(1,ens.KFold);

for i=1:ens.KFold
    cumlossT(1:ens.NTrainedPerFold(i),i)=loss(ens.Trainable{i},ens.X(ens.Partition.training(i),:),ens.Y(ens.Partition.training(i)),'mode','cumulative');
    lossT(1,i)=loss(ens.Trainable{i},ens.X(ens.Partition.training(i),:),ens.Y(ens.Partition.training(i)));
    cumlossV(1:ens.NTrainedPerFold(i),i)=loss(ens.Trainable{i},ens.X(ens.Partition.test(i),:),ens.Y(ens.Partition.test(i)),'mode','cumulative');
    lossV(1,i)=loss(ens.Trainable{i},ens.X(ens.Partition.test(i),:),ens.Y(ens.Partition.test(i)));
    [~,scoreT{i}]=predict(ens.Trainable{i},ens.X(ens.Partition.test(i),:));
    scoreT{i}=scoreT{i}(:,2);
    yT{i}=ens.Y(ens.Partition.test(i));
end
% scoreT=cell2mat(scoreT);
% yT=cell2mat(yT);

toc,
%%
fprintf('computing ROC etc...\n');tic;
[fpr,tpr,troc,AUCROC] = perfcurve(yT,scoreT,true,'prior',prior);%TVals
[tp,tn,ttptn] = perfcurve(yT,scoreT,true,'xCrit','TP','yCrit','TN','prior',prior);
[reca, prec, tprerec,AUCPREREC] = perfcurve(yT,scoreT,true,'xCrit','reca','yCrit','prec','prior',prior);
%[prec, reca, ~,~] = perfcurve(yT,scoreT,true,'xCrit','prec','yCrit','reca','prior',prior);
prec(1,:)=1;
toc

%%

fig=MyPlots.classificationerrorovertrees(cumlossT,cumlossV);
%MyPlots.simplesave(fig,savepath,'classificationerroroverntrees');
ConvertPlot4Publication(fullfile(savepath,'classificationerroroverntrees'));
fig=MyPlots.roc(fpr,tpr,AUCROC);
%MyPlots.simplesave(fig,savepath,'roc');
ConvertPlot4Publication(fullfile(savepath,'roc'));
fig=MyPlots.precreca(reca,prec,AUCPREREC);
%MyPlots.simplesave(fig,savepath,'precreca');
ConvertPlot4Publication(fullfile(savepath,'prerec'));

%%
fprintf('computing ROC etc...\n');tic;
imp=nan(size(ens.X,2),ens.KFold);
for i=1:ens.KFold
    imp(:,i)=predictorImportance(ens.Trainable{i});
end
toc
boxplot(imp.')










