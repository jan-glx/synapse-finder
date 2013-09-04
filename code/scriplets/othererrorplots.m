



fig=figure('Visible', visib,'units','normalized','outerposition',[0 0 1 1]);
plot(fpr,tpr);
xlabel('False Positive Rate');
ylabel('True Positive Rate');
saveas(fig,fullfile(savepath,'ROC.png'));
fig=figure('Visible', visib,'units','normalized','outerposition',[0 0 1 1]);
plot(t,[1-fpr,tpr]);
xlabel('Treshold');
ylabel('Performance');
legend('Specificity','Sensitfity');






%% aply an unused data in correct realtions
if(balance)
notselected=selected;
notselected(selected)=ens.Partition.training(1);
nyu=sum(ens.Y(ens.Partition.training(1)));
pyu=sum(~ens.Y(ens.Partition.training(1)));
leftn=nyu/prior(2)*prior(1)-pyu;
tmp=notselected(~notselected);
tmp(randperm(numel(tmp),round(leftn)))=true;
notselected(~notselected)=tmp;
notselected=~notselected;
xt2=xx(notselected,:);
yt2=yy(notselected);
else
    xt2=ens.X(ens.Partition.test(1),:);
    yt2=ens.Y(ens.Partition.test(1));
end
[sy1,s2]=predict(ens.Trainable{1},xt2);
 s2=s2(:,2);
[ss2, idx]=sort(s2);

per2sco=@(per)interp1((0:numel(ss2)-1)/(numel(ss2)-1), ss2,per);
sco2per=@(sco)interp1(ss2([diff(ss2)>0;true]),subIdx((0:numel(ss2)-1)/(numel(ss2)-1),[diff(ss2)>0;true]),sco);

syt2=yt2(idx);
%%


fw=figure
[tp,tn,t] = perfcurve(y3,s3,true,'xCrit','TP','yCrit','TN');
n=max(tp)+max(tn);

t2=t;%sco2per(t);

hold on;                                     %# Add to the plot
h1 = fill(t2([1 1:end end]),...        %# Plot the first filled polygon
          [0; tn; 0],...
          'b','EdgeColor','none');
set(h1,'DisplayName','True Negatives')

h2 = fill(t2([1 1:end end]),...        %# Plot the second filled polygon
          [n ;n-tp ;n],...
          'g','EdgeColor','none');
set(h2,'DisplayName','True Positves')

h1 = fill(t2([1 1:end end]),...        %# Plot the first filled polygon
          [max(tn); tn; max(tn)],...
          [1 0.5 0],'EdgeColor','none');
set(h1,'DisplayName','False Positves') 

h1 = fill(t2([1 1:end end]),...        %# Plot the first filled polygon
          [max(tn); n-tp; max(tn)],...
          'r','EdgeColor','none');
set(h1,'DisplayName','False Negatives')

h0=plot(t2,max(tn).*ones(size(t2)),'k');  %# Plot the red line
set(get(get(h0,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

xlim([min(t2) max(t2)])
ylim([0 n])
legend('Location','SouthEast');
xlabel('threshold');
ylabel('number of test cases');



%%



[tp,tn,t] = perfcurve(y1,s1,true,'xCrit','TP','yCrit','TN');
p=max(tp);
n=max(tn);
n=p+n;

[ss1, idx]=sort(s1);
sy1=y1(idx);

fw=figure
cs1=cumsum(sy1);
plot(1:numel(y1),[cumsum(~sy1) cs1(end:-1:1)])

%%
xt2=ens.X(ens.Partition.test(1),:);
    yt2=ens.Y(ens.Partition.test(1));
t = ClassificationTree.template('minleaf',5);
tic
rusTree = fitensemble(ens.X(ens.Partition.training(1),:),ens.Y(ens.Partition.training(1)),'RUSBoost',1000,t,...
    'LearnRate',0.1,'nprint',1);
toc
%%
[y3,s3]=predict(rusTree,ens.X(ens.Partition.test(1),:));
 s3=s3(:,2);
 Y3=ens.Y(ens.Partition.test(1));
 %%
 [ss3, idx3]=sort(s3);
sy3=y3(idx3);
sY3=Y3(idx3);

 cm=confusionmat(y3,sy3)

%%


npb=200
bsy2=sum(reshape(ssy3(1:floor(numel(ssy3)/npb)*npb),npb,[]),1);

k=bsy2;
n=npb;
j=(1+k)./(2+n);

%err=sqrt(((1 + k) .*(n - k.* n + 3.* n.^2 + k.* n.^2))/((2 + n) .*(3 + n)) - (((1 + k).* n)/(2 + n)).^2);

err=sqrt((2 + k + n - k .* n + n.^2 )  .* arrayfun(@(k)nchoosek(n,k),k) ./ ( (n+1) .* (n+2) .* (n+3) .* arrayfun(@(k)nchoosek(n+1,k+1),k)));
%Sqrt[((1 + k) (n - k n + 3 n^2 + k n^2))/((2 + n) (3 + n)) - (((1 + k) n)/(2 + n))^2]
fw=figure;
hEV=errorbar((0:numel(k)-1)/(numel(k)), j,err);
xlim([0 1])
ylim([0 1])
xlabel('population of contacts');
ylabel('propability for synapse');
cV=[0 0 1];
set(hEV                             , ...
                'LineStyle'       , 'none'      , ...
                'Marker'          , '.'         ,...      
                'LineWidth'       , 1           , ...
                'Color'           , cV          ,...  
                'Marker'          , 'o'         , ...
                'MarkerSize'      , 6           , ...
                'MarkerEdgeColor' , cV  , ...
                'MarkerFaceColor' , cV ...  
            );
        
%%
[fpr,tpr,t] = perfcurve(y3,s3,true);

fig=figure('Visible', visib,'units','normalized','outerposition',[0 0 1 1]);
plot(fpr,tpr);
xlabel('False Positive Rate');
ylabel('True Positive Rate');
saveas(fig,fullfile(savepath,'ROC.png'));
fig=figure('Visible', visib,'units','normalized','outerposition',[0 0 1 1]);
plot(t,[1-fpr,tpr]);
xlabel('Treshold');
ylabel('Performance');
legend('Specificity','Sensitfity');

%%
[tp,fn,t] = perfcurve(y3,s3,true,'xCrit','TP','yCrit','FP');
fig=figure('Visible', visib,'units','normalized','outerposition',[0 0 1 1]);
plot(fn,tp);
xlabel('false positves');
ylabel('true positives');
%%
figure
plot(ss3(end:-1:1),[cumsum(sY3(end:-1:1)),cumsum(~sY3(end:-1:1))])
legend('true positves','false positives');
xlabel('threshold');
ylabel('#');
%%



cm=confusionmat(y1,sy1)

tab = tabulate(yV);
fprintf('class errors:\n');
preacc=bsxfun(@rdivide,confusionmat(yV,YfitV),cell2mat(tab(:,2)))
cmV=confusionmat(yV,YfitV);
cmT=confusionmat(yT,YfitT);
fprintf('Valid.: precision: %f, recall: %f, informdness: %f\n',precision(cmV),recall(cmV),informedness(cmV));

fprintf('Train.: precision: %f, recall: %f, informdness: %f\n',precision(cmT),recall(cmT),informedness(cmT));
%dlmwrite(fullfile(savepath,'classAcc.csv'),preacc);
fprintf('feature Importance\n');
imp=predictorImportance(ens)

cell2csv(fullfile(savePath,'all.csv'), cat(2,{savepath,datafile,informedness(cmV,realprior./prior),informedness(cmV,1./prior),precision(cmV),recall(cmV)},num2cell(cmV(:).'),{nWorkers,limit,balance,xval,nTrees,typ},num2cell(prior(:).')), true,',');
fig=figure('Visible', visib,'units','normalized','outerposition',[0 0 1 1]);
bar(imp);
set(gca, 'XTickLabel',namespp, 'XTick',1:numel(namespp))
rotateXLabels( gca(), 90 );
saveas(fig,fullfile(savepath,'featureimportance.png'))

save(fullfile(savepath,'ens.mat'),'ens','preacc','imp','names','cues','namespp','f');
%MyPlots.perfover(ntrain(1:nj),precisionV,recallV,f1V)



