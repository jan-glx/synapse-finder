balance=[];
datafile='F:\JanResults\Trainingsets\contacts close undirected\contacts.mat';%'F:\JanResults\vesicleBOut\volume.mat';%'F:\JanResults\Trainingsets\contacts close undirected\contacts.mat';%'F:\JanResults\irisnatalias100.nmlOut\sampled.mat';%'F:\JanResults\Trainingsets\contacts close undirected\contacts.mat';%'F:\JanResults\Trainingsets\voxelwise\volume.mat';%'F:\JanResults\Trainingsets\contacts close undirected\contacts.mat';%'F:\JanResults\Trainingsets\sampled walls context cues\sampled.mat';%'F:\JanResults\irisnatalias100.nmlOut\contacts.mat';%
k=5;
LearnRate=[];%0.1;%[];%
cost=[0 100; 1 0 ];
selectedFeatures=[];%1:27;%
nTrees=10;
method='AdaBoostM1';%'RobustBoost';%'AdaBoostM1';%'RUSBoost';%'RobustBoost';%'AdaBoostM1';%'RobustBoost';%'Bag';%
nprint=1;
RobustErrorGoal=[];0.15;
vary='# training examples';
iV=[0.01 0.02 0.05 0.1 0.2 0.4 0.6 0.8 1];
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
switch(vary)
    case '# training examples'
        indp=iV*size(yy,1);
end
fprintf('train forrest...\n');tic;
lossT=nan(numel(iV),k);
lossV=nan(numel(iV),k);
nS=size(yy,1);
for iF=1:k
    for i=1:numel(iV)
        ii=true(nS,1);
        switch(vary)
            case '# training examples'
                ii=false(nS,1);
                ii(randperm(nS,round(iV(i)*nS)))=true;
        end
        ens = fitensemble(x(ii,:),y(ii),method,nTrees,'tree','LearnRate',LearnRate,'RobustErrorGoal',RobustErrorGoal,'nprint',nprint,'prior',prior,'classnames',[true, false],'crossval','off','k',[],'cost',cost,'type','classification','fresample',freesample,'resample',resample);%,'PredictorNames',names
        
        lossT(i,iF)=loss(ens,x(ii,:),y(ii));
        lossV(i,iF)=loss(ens,x(~ii,:),y(~ii));
    end% C(i,j) is the cost of classifying a point into class j if its true class is i.
end
toc,
clear ens xx x y yy;
fprintf('done learning\n');
%%
    
fig=MyPlots.classificationerrorover(lossT,lossV,indp,vary);set(fig,'visible','on');

fprintf('send email with results...\n');tic;
save('tmp.mat');
saveas(fig, 'tmp.png'); 
sendmail(myaddress, 'finished learning', evalc(['disp(reshape(resumary,2,[]))']),{'tmp.png','tmp.mat'}); 
delete('tmp.png');delete('tmp.mat');
toc,

%fig=MyPlots.roc(fpr,tpr);set(fig,'Visible','on')









