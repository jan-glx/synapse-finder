%load('F:\\JanResults\\Trainingsets\\sampled walls context cues\\sampled.mat')
[fm,~,~,~,~,~] = makefilterbank (em);

bbox=[390, 966, 1352];
bbox=[bbox;bbox+[200,200,1]-1];
%%
fprintf('loading rawdata...\\n');tic;
x=single(em.readRoi(bbox.'+[-fm.maxSiz;fm.maxSiz].'));
if all(~x)
    error('nothing red! ls %s: %s',em.dataPath,system(sprintf('ls %s',em.dataPath)));
end
toc

fprintf('remoove noise\\n');tic;
x=removeSaltAndPepper(x,3);
toc;

%% compute feature map
fprintf('computing fm...\\n');tic
fm.compute(x);
toc

%%
outpath=fullfile(ppath,'figures','features');
if exist(outpath,'dir')
    rmdir(outpath,'s');
    pause(1);
end
mkdir(outpath);
tic
for iF=1:size(fm.X,4)
    imwrite(scaler(fm.X(:,:,iF)),fullfile(outpath,sprintf('feature%03u.png',iF)));
end
toc
fprintf('finished\n')


%% generata latex code


% fprintf('\\begin{figure}\n\\newcommand{\\thisfigwith}{0.16\\textwidth}\n\\centering\n');
% tmp=fm.getNames;
% for  iF=1:size(fm.X,4)
%     fprintf('\\subcaptionbox{%s\\label{fig:feature%03u}}\n{\\includegraphics[width=\\thisfigwith]{features/feature%03u.png}}\n',tmp{iF},iF,iF);
% end
% fprintf('\\caption{\\figcap{Feature channels used for training.}\n\\label{fig:allfeatures}}\n\\end{figure}\n');
% 
fprintf('\\begin{figure}\n\\newcommand{\\thisfigwith}{0.16\\textwidth}\n\\centering\n');
tmp=fm.getNames;
for  iF=1:size(fm.X,4)
    fprintf('\\subcaptionbox{\\label{fig:feature%03u}}\n{\\includegraphics[width=\\thisfigwith]{features/feature%03u.png}}\n',iF,iF);
end
fprintf('\\caption{\\figcap{Feature channels used for training.} \\subref{fig:feature001}, Identety. \\subref{fig:feature002}-\\subref{fig:feature004}, Gaussian smoothed. \\subref{fig:feature005}-\\subref{fig:feature009}, Laplacian of Gaussians. \n\\label{fig:allfeatures}}\n\\end{figure}\n');



















