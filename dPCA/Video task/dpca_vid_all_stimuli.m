clear
%%%%% ALL_STIMULI
 %% INPUTS
ntrials=60;
dir=dir('*all_data.mat');
width=6; %smoothing
bin=20;
%timeEvents=[500 1000 2400 ];
timeEvents=[1];
Trials={[1:10] [11:20] [21:30] [31:40] [41:50] [51:60]} ;
%Epochs={[1:500] [501:1000] [1001:2400] [2401:2900]};

Epochs={[1:1400]}; %change to 1:500 for fix 1 or fix2
Epochtocut=1001:2400; %Change to 1:500 for baseline (-500 to fix appearance), 501:1000 for fix 1 (0 500 fix appearance)
% 1001:2400 for stimulus presentation(0 1400 stim appearance), 2401:2900 for fix 2(0 500 fix2 appearance)


%% Matrix creation for dpca

Epochs=cellfun(@rdivide, Epochs,repmat({bin}, 1,length(Epochs)),'UniformOutput',false);
Epochs=cellfun(@floor, Epochs,'UniformOutput', false);
Epochs=cellfun(@unique, Epochs,'UniformOutput', false);
Epochs=cellfun(@(x) x(2:end), Epochs, 'UniformOutput', false);

for n=1:length(dir)
    load(dir(n).name, 'raster_data')
           raster_data=raster_data(:,[Epochtocut]); %$%%%% if single epoch

    binwidth=1:bin:length(raster_data)+1;

    % binning activity in windows width=bin;

    for b=1:length(binwidth)
        if b==length(binwidth)
        else
            bincount(:,b)=sum(raster_data(:,binwidth(b):binwidth(b+1)-1),2);
        end
    end
    mat{n}=(bincount);
    Spk_Count_rate=((1/bin)*1000).*bincount; %spike count over single trial

%smoothing single trial activity over specific epoch bins 

    for t=1:length(Trials)
        for e=1:length(Epochs)
            k=Spk_Count_rate(Trials{t},Epochs{e});
            for sm=1:size(k,1)
                smoothed_firings(sm,:)=transpose(smoothdata(k(sm,:),'gaussian',width));
            end
            Spk_Count_rate(Trials{t},Epochs{e})=smoothed_firings;
            clearvars smoothed_firings
        end
    end
    mat_smooth{n}=Spk_Count_rate;      
    
end
%% define parameters 
% Base=(1:25);
% Cue=(26:50);
% Pres=(51:70);
% Go_NoGO=(71:90);
% Hold_Fix=(91:115);

% Time events of interest (e.g. stimulus onset/offset, cues etc.)
% They are marked on the plots with vertical lines

N = length(dir);       % number of neurons
T = size(mat{1},2);    % number of time points
S = 1;     % number of stimuli
D = 6;     % number of decisions
E = 10;    % maximal number of trial repetitions
time=1:T;
timeEvents=timeEvents./bin+1;
timeEventsNames={'IFix', 'Pres', 'IIFix'};
%% single-trial firingRates 4-d array
% firing rates of all the neurons are storaged in a 5d matrix with dimensions = matrix(N,S,D,T,E); 

trialNum=repmat(E,N,D);

for n=1:N
    all_trial_binned=mat_smooth{n};
    for s1=1:10
        spk_1=all_trial_binned(s1,:);
      
            firingRates(n,1,:,s1)=spk_1;
           
    end
    for s2=11:20
        spk_2=all_trial_binned(s2,:);
                  e=s2-10;

            firingRates(n,2,:,e)=spk_2;
           
    end
    for s3=21:30
        spk_3=all_trial_binned(s3,:);
            
            e=s3-20;
            firingRates(n,3,:,e)=spk_3;
       
    end
for s4=31:40
        spk_4=all_trial_binned(s4,:);
            
            e=s4-30;
            firingRates(n,4,:,e)=spk_4;
       
    end
     for s5=41:50
        spk_5=all_trial_binned(s5,:);
            
            e=s5-40;
            firingRates(n,5,:,e)=spk_5;
       
     end
     for s6=51:60
        spk_6=all_trial_binned(s6,:);
            
            e=s6-50;
            firingRates(n,6,:,e)=spk_6;
       
     end
    
end
     
%% firingRates trial averaged [N D T] 
 %how_to_calculate_averaged_activity=(((1/bin)*1000)*sum(bincount(1:10,1:25)))./10;
for n=1:N
    all_trial_binned=mat{n};
    for t=1:length(Trials)
        trials_average=((1/bin)*1000)*sum(all_trial_binned(Trials{t},:))./10; 
        for e=1:length(Epochs) 
            k=trials_average(1,Epochs{e}); 
            trials_average(1,Epochs{e})=smoothdata(k,'g',width);
        end
        if t==1
            firingRatesAverage(n,t,:)=trials_average;
        elseif t==2
            firingRatesAverage(n,t,:)=trials_average;
              elseif t==3
            firingRatesAverage(n,t,:)=trials_average;
                      elseif t==4
            firingRatesAverage(n,t,:)=trials_average;
               elseif t==5
            firingRatesAverage(n,t,:)=trials_average;
        else
            firingRatesAverage(n,t,:)=trials_average;
        end
    end
end  

%% Define parameter grouping

% *** Don't change this if you don't know what you are doing! ***
% firingRates array has [N S D T E] size; herewe ignore the 1st dimension 
% (neurons), i.e. we have the following parameters:
%    1 - stimulus 
%    2 - decision
%    3 - time
% There are three pairwise interactions:
%    [1 3] - stimulus/time interaction
%    [2 3] - decision/time interaction
%    [1 2] - stimulus/decision interaction
% And one three-way interaction:
%    [1 2 3] - rest
% As explained in the eLife paper, we group stimulus with stimulus/time interaction etc.:

%'decodingClasses'- specifies classes for each marginalization.
% E.g. for the three-parameter case with parameters
%    1: stimulus  (3 values)
%    2: decision  (2 values)
%    3: time
% and combinedParams as specified above:
% {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}}
% one could use the following decodingClasses:
% {[1 1; 2 2; 3 3], [1 2; 1 2; 1 2], [], [1 2; 3 4; 5 6]}
% Default value is to use separate class for each
% condition, i.e.
% {[1 2; 3 4; 5 6], [1 2; 3 4; 5 6], [], [1 2; 3 4; 5 6]}

combinedParams = {{1, [1 2]}, {2}};
decodingClasses = {[(1:D)'],[]};
% decodingClasses = {[1 1; 2 2; 3 3], [1 2 3; 1 2 3], [], [1 2 3 ; 4 5 6]};
margNames = {'Category', 'Main'};
margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% For two parameters (e.g. stimulus and time, but no decision), we would have
% firingRates array of [N S T E] size (one dimension less, and only the following
% possible marginalizations:
%    1 - stimulus
%    2 - time
%    [1 2] - stimulus/time interaction
% They could be grouped as follows: 
%    combinedParams = {{1, [1 2]}, {2}};

% Time events of interest (e.g. stimulus onset/offset, cues etc.)
% They are marked on the plots with vertical lines


%% Cross-validation to find lambda
ifSimultaneousRecording=false;
% This function takes some minutes to run. It will save the computations 
% in a .mat file with a given name. Once computed, you can simply load 
% lambdas out of this file:
%   load('tmp_optimalLambdas.mat', 'optimalLambda')

% Please note that this now includes noise covariance matrix Cnoise which
% tends to provide substantial regularization by itself (even with lambda set
% to zero).

optimalLambda = dpca_optimizeLambda(firingRatesAverage, firingRates, trialNum, ...
    'combinedParams', combinedParams, ...
    'numComps', [20 20], ...
    'simultaneous', ifSimultaneousRecording, ...
    'numRep', 10, ...  % increase this number to ~10 for better accuracy
    'filename', 'tmp_optimalLambdas.mat');

%% dPCA (with regularization and noise cov)

Cnoise = dpca_getNoiseCovariance(firingRatesAverage, ...
    firingRates, trialNum, 'simultaneous', ifSimultaneousRecording);

[W,V,whichMarg] = dpca(firingRatesAverage, 20, ...
    'combinedParams', combinedParams, ...
    'lambda', optimalLambda, ...
    'Cnoise', Cnoise);

explVar = dpca_explainedVariance_prova(firingRatesAverage, W, V, ...
    'combinedParams', combinedParams,  ...
     'Cnoise', Cnoise, 'numOfTrials', trialNum);

%% Optional: decoding

accuracy = dpca_classificationAccuracy(firingRatesAverage, firingRates, trialNum, ...
    'lambda', optimalLambda, ...
    'combinedParams', combinedParams, ...
    'decodingClasses', decodingClasses, ...
    'simultaneous', ifSimultaneousRecording, ...
    'numRep', 100);        % increase to 100
   
dpca_classificationPlot(accuracy, [], [], [], decodingClasses)

accuracyShuffle = dpca_classificationShuffled(firingRates, trialNum, ...
    'lambda', optimalLambda, ...
    'combinedParams', combinedParams, ...
    'decodingClasses', decodingClasses, ...
    'simultaneous', ifSimultaneousRecording, ...
    'numRep', 100, ...        % increase to 100
    'numShuffles',100, ...  % increase to 100 (takes a lot of time)
    'filename', 'tmp_classification_accuracy.mat');

dpca_classificationPlot(accuracy, [], accuracyShuffle, [], decodingClasses)

componentsSignif = dpca_signifComponents(accuracy, accuracyShuffle, whichMarg);

dpca_plot(firingRatesAverage, W, V, @dpca_plot_vid2, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours, ...
    'whichMarg', whichMarg,                 ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'timeMarginalization', 2,           ...
    'legendSubplot', 16,                ...
    'componentsSignif', componentsSignif);

dpca_plot(firingRatesAverage, W, V, @dpca_plot_vid2, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours, ...
    'whichMarg', whichMarg,                 ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'timeMarginalization', 2,           ...
    'legendSubplot', 16);


