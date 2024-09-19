%%%% QUESTO CODICE è STATO CREATO PER FARE IL DECODING SULLA SINGOLA
%%%% CONDIZIONE: ES. O SOLO SULLA VARIABILE OGGETTO O SULLA VARIABILE CUE
%%%% UDITIVA (PUò ESSERE ADATTATO A QUALSIASI TASK CHE PREVEDE PRESENTAZIONE DI STIMOLI IN ALMENO DUE CONDIZIONI ES. POSIZIONE, GO/NOGO, ETC.)

% % Performing a decoding analyses involves several steps:

% % 1) creating a datasource (DS) object that generates training and test splits of the data.
% % 2) optionally creating feature-preprocessor (FP) objects that learn parameters froCLEm the training data, and preprocess the training and test data.
% % 3) creating a classifier (CL) object that learns the relationship between the training data and training labels, and then evaluates the strength of this relationship on the test data.
% % 4) running a cross-validator object that using the datasource (DS), the feature-preprocessor (FP) and the classifier (CL) objects to do a cross-validation procedure that estimates the decoding accuracy.

clear all;
close all;
clc;
 
%%%  Adding the path to the toolbox: add the path to the NDT so add_ndt_paths_and_init_rand_generator can be called
 toolbox_basedir_name = 'Z:\programmi\MATLAB\ndt.1.0.4\ndt.1.0.4'; %% inserire il percorso della cartella in cui è contenuta la cartella con tutti i dati che si devono analizzare oltre a tutte le funzioni del NDT
 addpath(toolbox_basedir_name);
 add_ndt_paths_and_init_rand_generator

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

raster_file_directory_name = pwd; %% inserire il percorso della cartella in cui sono presenti i dati da analizzare
decoding='accuracy';                
classifier=1;
error='yes';
colorplot='yes';
bin_width = 60;                            save_prefix_name = 'data';            %% inserire il nome che si vuole assegnare ai dati normalizzati


%% dimensione del bin
step_size = 20;                                     %% dimensione dello shift
shuffle=1;                                          %% 1 se si vuole testare l'ipotesi nulla, oppure 0 se si vuol fare il decoding
specific_label_name_to_use = 'object';   %% will decode the identity of which object/or cue was shown (regardless of its position/or object)
%specific_label_name_to_use = 'combined_object_condition  ';   %% will decode the identity of which object/or cue was shown (regardless of its position/or object)

                                                   
stim={'Cube','Cylinder','Sphere'};
%stim={'Red_cube','Red_cylinder','Red_sphere'};
simultaneous_recording=0;                      %%% se la registrazione è stata fatta simultaneamente per tutti i neuroni mettere 1 altrimenti 0;
% pvalue=0.001;                                                  
                                                   
ntrials=60;                 %% rappresenta il numero massimo di trials in cui ogni neurone è stato testato. 
num_cv_splits=20;           %% rappresenta il cross-validation split che può arrivare al numero massimo di trials per condizione 
runs=1000;                    %% set how many times the outer 'resample' loop is run, generally we use more than 2 resample runs which will give more accurate results


xlimit=([0 2300]);  %% determina la lunghezza dell'asse x del deoding basic plot 
ylimit=([10 100]);  %% determina il range di accuracy sull'asse y del decoding basic plot
significant_event_times=[500 1000 1500 1900]; %% inserisce nei plot (deconding basic plot e TCT) delle linee in corrispondeza degli eventi

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% crea un'array di dati normalizzati%%%%%%%
create_binned_data_from_raster_data(raster_file_directory_name,['Binned_' save_prefix_name], bin_width, step_size);

%%% Determining how many times each condition was repeated e select which neurons have been tested k times;

load(['Binned_' save_prefix_name '_' num2str(bin_width) 'ms_bins_' num2str(step_size) 'ms_sampled.mat']);

for k=1:ntrials; 
    inds_of_sites_with_at_least_k_repeats = find_sites_with_k_label_repetitions(eval(['binned_labels.' specific_label_name_to_use]), k);
    num_sites_with_k_repeats(k) = length(inds_of_sites_with_at_least_k_repeats);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the name of the file that has the data in binned-format
binned_format_file_name = ['Binned_' save_prefix_name '_' num2str(bin_width) 'ms_bins_' num2str(step_size) 'ms_sampled.mat'];

ds=basic_DS(binned_format_file_name, specific_label_name_to_use, num_cv_splits,classifier); % MODIFICATO DA POISSON A CLASSIFIER
ds.create_simultaneously_recorded_populations=simultaneous_recording;    %%% se metti 1 significa che la tua popolazione è stata registrata simultaneamente  
ds.label_names_to_use=stim;
ds.randomly_shuffle_labels_before_running=shuffle;          %%% se metti 1 crei le condizioni per un'ipotesi nulla

%%%%%% create a feature preprocessor that z-score normalizes each neuron 

% if poisson==0;
%     the_classifier = max_correlation_coefficient_CL;
% %     the_feature_preprocessors{1} = zscore_normalize_FP;
%     fp{1} = zscore_normalize_FP;
% elseif poisson==1;
%     the_classifier = poisson_naive_bayes_CL;
% %     the_feature_preprocessors{1} = select_pvalue_significant_features_FP;  
% %     the_feature_preprocessors{1,1}.pvalue_threshold=0.5;
%     fp{1} =select_pvalue_significant_features_FP; 
%     fp{1,1}.pvalue_threshold=0.5;
% end;

if classifier==0;
    the_classifier = max_correlation_coefficient_CL;
%     the_feature_preprocessors{1} = zscore_normalize_FP;
    fp{1} = zscore_normalize_FP;
elseif classifier==1;
    the_classifier = poisson_naive_bayes_CL;
%     the_feature_preprocessors{1} = select_pvalue_significant_features_FP;  
%     the_feature_preprocessors{1,1}.pvalue_threshold=0.5;
    fp{1} =select_pvalue_significant_features_FP; 
    fp{1,1}.pvalue_threshold=0.5;
 elseif classifier==2;
     the_classifier= libsvm_CL
       svm.kernel='rbf'
       svm.gaussian_gamma=0.1
    end


%fp{1}.pvalue_threshold = pvalue;
% the_feature_preprocessors{1}.save_extra_info = 1;


% the_classifier=max_correlation_coefficient_CL;      % create the CL object
the_cross_validator = standard_resample_CV(ds, the_classifier); % create the CV object RICORDA CHE C'E fp
the_cross_validator.num_resample_runs = runs; % set how many times the outer 'resample' loop is run generally we use more than 2 resample runs which will give more accurate results
% the_cross_validator.save_results.extended_decision_values = 1;
% the_cross_validator.display_progress.normalized_rank = 1;
% the_cross_validator.display_progress.decision_values = 1;

%%%%%%%% run the decoding analysis %%%%%%%%%%
DECODING_RESULTS = the_cross_validator.run_cv_decoding;

 
save_file_name=[save_prefix_name '_results']; 
 
save(save_file_name, 'DECODING_RESULTS','-v7.3');


%%%%%%%%%%%%%%%%%%%%%% PLOT DEI RISULTATI %%%%%%%%%%%%%%%%%%%%%%%%%%%%

result_names{1} = save_file_name;  

plot_obj = plot_standard_results_object(result_names); % create the plot results object
if contains(decoding,'accuracy');
    plot_obj.result_type_to_plot=1;
elseif contains(decoding,'roc');
    plot_obj.result_type_to_plot=4;
elseif contains(decoding,'norm_rank');
    plot_obj.result_type_to_plot=2;
elseif contains(decoding,'decision_value');
    plot_obj.result_type_to_plot=3;
elseif contains(decoding,'mutual_information');
    plot_obj.result_type_to_plot=7;
elseif contains(decoding,'');
    fprintf 'ERROR! you should insert type of plot';
end;


plot_obj.significant_event_times=significant_event_times;
% put a line at the time when the stimulus was shown
if contains(error,'yes')
    plot_obj.errorbar_file_names=1;       %%% 
elseif contains(error,'no');
    plot_obj.errorbar_file_names=0;       %%%
end;
% 
% plot_obj.errorbar_type_to_plot = 1; % 1: over_resamples, 2: over_CVs, 3: over_CVs_combined_over_resamples, 4: all_single_CV_vals_combined, 5: all_single_CV_vals, 6: over_classes
% plot_obj.errorbar_stdev_multiplication_factor =1;
% plot_obj.errorbar_transparency_level = 0.2;
% plot_obj.errorbar_edge_transparency_level = 0.2; 
plot_obj.plot_results;% display the results

xlim(xlimit);
ylim(ylimit);

 saveas(gcf,['Decoding_' save_prefix_name],'fig');
 saveas(gcf,['Decoding_' save_prefix_name],'jpg');

if contains(colorplot,'yes')      
    % create the plot results object
    % note that this object takes a string in its constructor not a cell array
    plot_obj = plot_standard_results_TCT_object(save_file_name);
    plot_obj.significant_event_times = significant_event_times; % put a line at the time when the stimulus was shown
    plot_obj.plot_results;                % display the results
    close;
    colormap jet
    caxis([50 100]);
    saveas(gcf,['Decoding_colorplot_' save_prefix_name],'fig');
    saveas(gcf,['Decoding_colorplot_' save_prefix_name],'jpg');
elseif contains(colorplot,'no')      
      %nothingelse
end;
 
clear all;
clc;

