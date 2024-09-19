clear all
%unico set colonne

% Copyright 2014 The MathWorks, Inc.
% Automating File Import
% Select folder containing data interactively 
%Location = uigetdir;
% Identify where to search for files
% Store the name of all .xls files as a vector D
D = dir([pwd, '\*.mat']);
% Extract the file names
filenames = {D(:).name}.';
data = cell(length(D),1);
%opts.SelectedVariableNames  = ['B151:D163','H151:M163', 'Q151:V163M', 'Z151:AB163M','I151:AK163M'  ];
bin=20;
for ii = 1:length(D) 
    % Create the full file name and partial filename
    fullname = [pwd filesep D(ii).name];
    load(D(ii).name)

binwidth=1:bin:length(raster_data)+1;

  for b=1:length(binwidth)
        if b==length(binwidth)
        elseif b==1
            bincount(:,b)=sum(raster_data(: ,binwidth(b):binwidth(b+1)-1),2);
        else
                       bincount(:,b)=sum(raster_data(:,binwidth(b):binwidth(b+1)-1),2);

        end
  end

Spk_Count_rate=((1/bin)*1000).*bincount; %spike count over trials
Spk_Count_rate=[[mean(Spk_Count_rate(1:30,:),1)] [mean(Spk_Count_rate(31:60,:),1)]];

    % Read in the data
    data1{ii} = Spk_Count_rate; 

clearvars bincount Spk_Count_rate
end



 a=data1';
 
 matrix_epochs=cell2mat(a([1:end]));



 matrix_epochs2=matrix_epochs(:,[[26:115] [141:end]] );

 matrix_epochs2(:,[51:60 141:150])=[];


 matrix_base=matrix_epochs(:,[[1:25] [116:140]]);




for qk=1:size(matrix_epochs,1)

    
 matrix_epochs2(qk,:)=matrix_epochs2(qk,:)-mean(matrix_base(qk,:));


end

% 

%

% %%%%%%%%%%%  HIERCHICAL CLUSTERING OF PC SCORES BASED ON KNEE VALUE OF
% %%%%%%%%%%%  CUMULATIVE EXPLAINED VARIANCE DISTRIBUTION
gruppi(1:25,:)=repmat(["cue red"],25,1); %nome condizione, ordine excel

gruppi(26:50,:)=repmat(["porta red"],25,1); %nome condizione, ordine excel
gruppi(51:80,:)=repmat(["behavioral response red"],30,1); %nome condizione, ordine excel
gruppi(81:105,:)=repmat(["cue green"],25,1); %nome condizione, ordine excel
gruppi(106:130,:)=repmat(["porta green"],25,1); %nome condizione, ordine excel
gruppi(131:160,:)=repmat(["behavioral response green"],30,1); %nome condizione, ordine excel




[coeff,score,latent,tsquared,explained,mu]  = pca(matrix_epochs2');
% 
[res_x,idx_of_result]=knee_pt(explained);
figure

%explained(:,2)=cumsum(explained);
%idx=length(explained(explained(:,2)<85));
[d,p,stats] = manova1(score(:,1:idx_of_result-1),gruppi);
%[d,p,stats] = manova1(score(:,1:idx),gruppi);





stats.gmdist=stats.gmdist./(idx_of_result-1);
%stats.gmdist=stats.gmdist./idx;

dend=manovacluster_leaf_order(stats,'average');
set(dend, 'LineWidth',2)

% 



%%%%%%%%%%%%%optional, not used
% 
%  %K MEANS OR HIERARCHICAL CLUSTERING OF PC SCORES BASED ON  OPTIMAL K
%  %VALUE -3D
%  [coeff,score,latent,tsquared,explained,mu]  = pca(matrix_epochs2');
% %rng('default') % For reproducibility
% eva = evalclusters(score(:,1:3),'kmeans','CalinskiHarabasz','KList',1:6);
% 
% T=kmeans(score(:,1:3),eva.OptimalK, 'Replicates',1000,'Options',statset('UseParallel',1));
% %T = clusterdata(score(:,1:3),'linkage','average','maxclust',eva.OptimalK);
% 
% % % 
% % % %
% % % 
% % % 
% % 
% colors = [repmat([255, 0, 0]/255,25,1);repmat([204, 85, 0]/255,25,1);repmat([110, 38, 14]/255,30,1);repmat([0, 255, 0]/255,25,1);repmat([50,205,50]/255,25,1);repmat([53, 94, 59]/255,30,1)];
% shape ={{"o"}, {"+"}, {"*"},{"x"},{"square"},{"diamond"},{"v"},{"pentagram"}};
% 
% 
% figure
% for kk=1:160
% scatter3(score(kk,1),score(kk,2),score(kk,3),50, 'MarkerEdgeColor', colors(kk, :), 'MarkerFaceColor', colors(kk, :), 'Marker', shape{ 1,T(kk,1)}{1, 1})
% hold on
% 
% 
% 
% end
% hold off;
% hold on
% 
% colors = [[[255, 0, 0]/255];[[204, 85, 0]/255];[[110, 38, 14]/255];[[0, 255, 0]/255];[[50,205,50]/255];[[53, 94, 59]/255]];
% 
% for jj=1:6
% 
%     legendHandles(jj)= scatter3(NaN,NaN, NaN,1, 'MarkerEdgeColor', colors(jj, :), 'MarkerFaceColor', colors(jj, :)); % Use 'o' as a placeholder
% end
% legend(legendHandles,'cue red','porta red', 'final phase red','cue green' ,'porta green','final phase green')
% 
% %K MEANS OR HIERARCHICAL CLUSTERING OF PC SCORES BASED ON  OPTIMAL K
%  %VALUE -2D
% eva = evalclusters(score(:,1:2),'kmeans','CalinskiHarabasz','KList',1:6);
% 
% T=kmeans(score(:,1:2),eva.OptimalK, 'Replicates',1000,'Options',statset('UseParallel',1));
% %T = clusterdata(score(:,1:3),'linkage','average','maxclust',eva.OptimalK);
% 
% % % 
% % % %
% % % 
% % % 
% % 
% colors = [repmat([255, 0, 0]/255,25,1);repmat([204, 85, 0]/255,25,1);repmat([110, 38, 14]/255,30,1);repmat([0, 255, 0]/255,25,1);repmat([50,205,50]/255,25,1);repmat([53, 94, 59]/255,30,1)];
% shape ={{"o"}, {"+"}, {"*"},{"x"},{"square"},{"diamond"},{"v"},{"pentagram"}};
% 
% 
% figure
% for kk=1:160
% scatter(score(kk,1),score(kk,2),50, 'MarkerEdgeColor', colors(kk, :), 'MarkerFaceColor', colors(kk, :), 'Marker', shape{ 1,T(kk,1)}{1, 1})
% hold on
% 
% 
% 
% end
% hold off;
% hold on
% 
% colors = [[[255, 0, 0]/255];[[204, 85, 0]/255];[[110, 38, 14]/255];[[0, 255, 0]/255];[[50,205,50]/255];[[53, 94, 59]/255]];
% 
% for jj=1:6
% 
%     legendHandles(jj)= scatter(NaN,NaN,1, 'MarkerEdgeColor', colors(jj, :), 'MarkerFaceColor', colors(jj, :)); % Use 'o' as a placeholder
% end
% legend(legendHandles,'cue red','porta red', 'final phase red','cue green' ,'porta green','final phase green')
% 
% 
% 
% 
