balance=0.01;
datafile='F:\JanResults\vesicleBOut\volume.mat';%'F:\JanResults\Trainingsets\contacts close undirected\contacts.mat';%'F:\JanResults\irisnatalias100.nmlOut\sampled.mat';%'F:\JanResults\Trainingsets\contacts close undirected\contacts.mat';%'F:\JanResults\Trainingsets\voxelwise\volume.mat';%'F:\JanResults\Trainingsets\contacts close undirected\contacts.mat';%'F:\JanResults\Trainingsets\sampled walls context cues\sampled.mat';%'F:\JanResults\irisnatalias100.nmlOut\contacts.mat';%
k=5;
LearnRate=[];%0.1;%[];%
cost=[];%[0 100; 1 0 ];
selectedFeatures=[];%1:27;%
nTrees=1000;
method='AdaBoostM1';%'RobustBoost';%'AdaBoostM1';%'RUSBoost';%'RobustBoost';%'AdaBoostM1';%'RobustBoost';%'Bag';%
nprint=1;
RobustErrorGoal=[];0.15;
MinLeaf=[];
freesample=[];%0.01;
resample='off';
visib='off';
load(fullfile(datafile));

prior='empirical';
if balance
    fprintf('balancing...\n');tic    
    prior=sum(yy)/numel(yy);% I know I am dooing it wrong... I should do this on the cv portions
    prior=[prior 1-prior];
    selected=rand(size(yy))<yy*(prior(2)/balance/prior(1))+~yy*(prior(1)*balance/prior(2));
    if balance<1
        selected=rand(size(yy))<balance;
        prior='empirical';
    end
    y=yy(selected);
    x=xx(selected,:);
    fprintf('randomly picked %u positive and %u negative examples.\n',sum(yy(selected)),sum(~yy(selected)));
    toc
else
    x=xx;
    y=yy;
end
if ~isempty(selectedFeatures)
    names=names(selectedFeatures);
    x=x(:,selectedFeatures);
end

weakLearner='tree';
if exist('MinLeaf','var')&&~isempty(MinLeaf)
    weakLearner= ClassificationTree.template('MinLeaf',MinLeaf);
end
%%
fprintf('train forrest...\n');tic;
ens = fitensemble(x,y,method,nTrees,'tree','LearnRate',LearnRate,'RobustErrorGoal',RobustErrorGoal,'nprint',nprint,'prior',prior,'classnames',[true, false],'crossval','on','k',k,'cost',cost,'type','classification','fresample',freesample,'resample',resample);%,'PredictorNames',names
% C(i,j) is the cost of classifying a point into class j if its true class is i.
toc,
fprintf('done learning\n');
%%
fprintf('saving training...\n');tic;
savepath=fullfile(savePath, [datestr(now,'yyyy-mm-dd-HH-MM-SS-') sprintf('%05i',randi(1E6,1)-1)]);
fprintf('Generate Folder: %s \n',savepath);
mkdir(savepath);
toSave={'ens','names','f','prior','datafile','balance','freesample','resample','cost','MinLeaf','selectedFeatures'};
if exist('rinclude','var')
    toSave=cat(2,toSave,{'rinclude','res'});
end
if exist('fR','var')
    toSave=cat(2,toSave,{'fR','cues','cuesF','rexclude','additionalborder'});
end
save(fullfile(savepath,'ens.mat'),toSave{:},'-v7.3');
toc
%%
testquanti

fprintf('saving results...\n');tic;
resumary={...
    'savepath',savepath,...
    'datafile',datafile,...
    'AUCROC_mean',AUCROC(1),...
    'AUCROC_low',AUCROC(2),...
    'AUCROC_high',AUCROC(3),...
    'AUCPREREC_mean',AUCPREREC(1),...
    'AUCPREREC_low',AUCPREREC(2),...
    'AUCPREREC_high',AUCPREREC(3),...
    'balance',balance,...
    'k',ens.KFold,...
    'nTrees',mat2str(ens.NTrainedPerFold),...
    'method',ens.CrossValidatedModel,...
    'LearnRate',ens.Trainable{1, 1}.ModelParams.LearnRate,...
    'MinLeaf',MinLeaf,...
    'cost',mat2str(cost),...
    'selectedFeatures',mat2str(selectedFeatures)...
    'freesample',freesample,...
    'resample',resample
    };
header=resumary(1:2:end);
content=resumary(2:2:end);
cell2csv(fullfile(savePath,'all.csv'),header, true,',');
cell2csv(fullfile(savePath,'all.csv'), content, true,',');
toc

fprintf('send email with results...\n');tic;
saveas(fig, 'tmp.png'); sendmail(myaddress, 'finished learning', evalc(['disp(reshape(resumary,2,[]))']),'tmp.png'); delete('tmp.png');

toc,

%fig=MyPlots.roc(fpr,tpr);set(fig,'Visible','on')









