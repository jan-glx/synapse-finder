file={'natalia100.nml' 'irisnatalias100.nml' 'jannatalias100.nml' 'alexnatalias100.nml'};
N=numel(file);
pre=cell(N,1);
cleft=cell(N,1);
id=cell(N,1);
post=cell(N,1);
bbox=cell(N,1);
for i=1:N
    [pre{i},cleft{i},id{i},post{i}, bbox{i}] = getSynapsesFromNml_preAllpost(file{i},true);
    if strcmp(file{i},'natalia100.nml')
        tmp=pre{i};
        pre{i}=post{i};
        post{i}=tmp;
    end        
end

%%
cleftIdx=cleft;
includeoverlap=round(em.nm2voxel(300));
excludeoverlap=round(em.nm2voxel(300));
bbox0=round([max([bbox{1}(1,:);bbox{2}(1,:);bbox{3}(1,:)]);min([bbox{1}(2,:);bbox{2}(2,:);bbox{3}(2,:)])]);
inbbox0=cellfun(@(cleftIdx)(all(bsxfun(@ge,cleftIdx,bbox0(1,:)),2)&all(bsxfun(@le,cleftIdx,bbox0(2,:)),2)),cleftIdx,'UniformOutput',false);
cleftIdx0=cellfun(@(cleftIdx,inbbox0)cleftIdx(inbbox0,:),cleftIdx,inbbox0,'UniformOutput',false);
cleftIdxnm0=cellfun(@(cleftIdx)em.idx2nm(cleftIdx),cleftIdx0,'UniformOutput',false);
bboxnm0=em.idx2nm(bbox0);

bboxc=bbox0+bsxfun(@times,[-1 1].',includeoverlap);
cubesize=diff(bboxc)+1;nD=numel(cubesize);
inbboxc=cellfun(@(cleftIdx)(all(bsxfun(@ge,cleftIdx,bboxc(1,:)),2)&all(bsxfun(@le,cleftIdx,bboxc(2,:)),2)),cleftIdx,'UniformOutput',false);
cleftIdxc=cellfun(@(cleftIdx,inbboxc)cleftIdx(inbboxc,:),cleftIdx,inbboxc,'UniformOutput',false);
cleftIdxnmc=cellfun(@(cleftIdx)em.idx2nm(cleftIdx),cleftIdxc,'UniformOutput',false);
inbbox0ofinbboxc=cellfun(@(inbbox0,inbboxc)inbbox0(inbboxc),inbbox0,inbboxc,'UniformOutput',false);

bboxex=bbox0+bsxfun(@times,[-1 1].',excludeoverlap);
bboxexnm=em.idx2nm(bboxex);

%%
wallem=emData.readKNOSSOSconf('F:\datasets\walls',[],'uint16');
wallem.overlap=10;

fprintf('loading walls...\n');tic;
walls=~wallem.readRoi(bboxc.');
toc
fprintf('segmenting using walls...\n');tic;
segments=bwlabeln(~walls,26);
toc
[ wallidxi,uneighboursID] = getContactIdxi( segments,walls );
%%
wallidx=shft(ind2suba(cubesize,wallidxi),bboxc(1,:)-1);
wallidxnm=em.idx2nm(wallidx);
fprintf('constructing search tree...\n');tic;
wallidxnmTree = KDTreeSearcher(wallidxnm);
toc
%%
searchRes=cellfun(@(cleftIdxnmc)knnsearch(wallidxnmTree,cleftIdxnmc),cleftIdxnmc,'UniformOutput',false);
foundneighbourIDs=cellfun(@(searchRes)uneighboursID(searchRes,:),searchRes,'UniformOutput',false);
%%
goodwallidx=(all(bsxfun(@ge,wallidxnm,bboxexnm(1,:)),2)&all(bsxfun(@le,wallidxnm,bboxexnm(2,:)),2));
[contacts, iA, iC]=unique(uneighboursID,'rows');
goodcontacts=accumarray(iC,goodwallidx)./histc(iC,1:max(iC))>0.5;

gcontacts=contacts(goodcontacts,:);

found=false(size(gcontacts,1),N);
foundi=nan(size(gcontacts,1),N);
for i=1:N
    [found(:,i), foundi(:,i)]=ismember(gcontacts,foundneighbourIDs{i},'rows');
end
%%
helper=repmat(1:size(found,2),size(found,1),1);
scleftIdxnmc = cellfun(@(cleftIdxnmc)size(cleftIdxnmc,1),cleftIdxnmc);
cscleftIdxnmc = [0;cumsum(scleftIdxnmc)];
onlyone=arrayfun(@(a,b)cscleftIdxnmc(a)+b,helper(bsxfun(@and,found,sum(found,2)==1)), foundi(bsxfun(@and,found,sum(found,2)==1)));
cleftIdxnmc2=cat(1,cleftIdxnmc{:});
onlyoneL=false(size(cleftIdxnmc2,1),1);onlyoneL(onlyone)=true;
[~,ddd]=knnsearch(cleftIdxnmc2(~onlyoneL,:),cleftIdxnmc2(onlyoneL,:));
figure,hist(ddd,30)
%%
K=0:N;
Kp=sum(found,2);
Kn=N-Kp;
KperTracer=nan(size(found));
kperTracer=nan(N+1,N);
for i=1:N
    %KperTracer(:,i)=[Kp(found(:,i))];%; Kn(~found(:,i))];
    KperTracer=[Kp(found(:,i))];%; Kn(~found(:,i))];
    kperTracer(:,i)=histc(KperTracer,K,1);
end
%kperTracer=histc(KperTracer,K,1);
%%
k=histc(Kp,K).';

tol=1E-10;
lb=[tol,tol,zeros(size(k))];
ub=[1-tol,1-tol,k];
x0=[0.1,0.9,0,k(2:end)*2/3];
options = optimoptions('fmincon');
options = optimoptions(options,'FunValCheck', 'on');
options = optimoptions(options,'Algorithm', 'active-set');
[x,fval,exitflag,output,lambda,grad,hessian] = ...
fmincon(@(x)-LikelyMe3(x(1),x(2),x(3:end),k),x0,[],[],[],[],lb,ub,[],options);
t0=x(1);
t1=x(2);
k1=x(3:end);
n1=sum(k1);
n=sum(k);
n0=n-n1;

fprintf('fpr: %f tpr: %f precision: %f recall: %f\n',t0,t1,n1*t1/(n1*t1+n0*t0),t1);
%%
lw=2;
figure,scatter(K,k,'o','MarkerEdgeColor','k','LineWidth',lw);
xlabel('# of times a contact was marked as synapse');ylabel('counts');
hold on, hold all

scatter(K,x(3:end),'+','MarkerEdgeColor','b','LineWidth',lw);
scatter(K,k-x(3:end),'x','MarkerEdgeColor','g','LineWidth',lw);
scatter(K,binopdf(K,N,t1)*n1,'d','MarkerEdgeColor','b','LineWidth',lw);
scatter(K,binopdf(K,N,t0)*n0 ,'s','MarkerEdgeColor','g','LineWidth',lw);
legend('# of contacts (measured)','# of synapse contacts (pred.)',...
    '# of no synapse contacts (pred.)','# of synapse contacts (exp.)','# of no synapse contacts (exp.)')
ylimMin(0)
xlimMin(0)
%set(gca,'YScale','log');

h = get(gca,'children');
set(h, 'sizedata', 100)

%fpr: 0.001456 tpr: 0.685043 precision: 0.781791 recall: 0.685043
%fpr: 0.001636 tpr: 0.634356 precision: 0.749779 recall: 0.634356
%fpr: 0.003820 tpr: 0.656781 precision: 0.651478 recall: 0.656781
%fpr: 0.001240 tpr: 0.698420 precision: 0.822648 recall: 0.698420
%fpr: 0.001240 tpr: 0.698420 precision: 0.822648 recall: 0.698420
%fpr: 0.001287 tpr: 0.754995 precision: 0.815543 recall: 0.754995



