clear; clc; close all;
%% Script that identifies stable data points and calculates the stability index
real_path='Z:\LAVORI\MAPPATURA\Mappatura_mot_video_statici\Decoding_x_area\Due_scimmie\Middle_46v\Object_DueM\True\data_results.mat'
shuff_path='Z:\LAVORI\MAPPATURA\Mappatura_mot_video_statici\Decoding_x_area\Due_scimmie\Middle_46v\Object_DueM\Shuffled_1000_perm\data_results.mat'
DECODING_RESULTS_REAL=load(real_path);%path to \Extended_data_Fig_4_5_6.mat file 
DECODING_RESULTS_SHUFF=load(shuff_path);%path to \Extended_data_Fig_4_5_6.mat file 

colormap_CTD= {[0.5,1; 0.5,1], ...
    [0.3, 1; 0.3, 1]};

Time= [1:2100];
Time_window=Time(1):20:(Time(end));
%f_cell_types= {'broad', 'narrow'};
%f_tasks = {'NOVMAP', 'FAMMAP', 'NOVA_NOVB_RESPONSE', 'NOVA_NOVB_STIMULI', 'NOV_FAM_BROAD', 'NOV_FAM_NARROW'};

ic=1;
ita=2; %put 2 if object
    
real_results=DECODING_RESULTS_REAL.DECODING_RESULTS.ZERO_ONE_LOSS_RESULTS.mean_decoding_results;  %%%after loading real results

crit_perc=99.9; %%set to 99 for 0.01 or to 95 for 0.05
pval=0.001;
%%%%%%removing bad bins

real_results=real_results([1:23 26:48 51:73 76:93 96:113],[1:23 26:48 51:73 76:93 96:113] );  %%%after loading real results



a=mean(DECODING_RESULTS_SHUFF.DECODING_RESULTS.ZERO_ONE_LOSS_RESULTS.decoding_results,2);%%after loading shuffled results
a=squeeze(a);%%after loading shuffled results
shuffle_3D_data=permute(a,[2 3 1]);
shuffle_3D_data=shuffle_3D_data([1:23 26:48 51:73 76:93 96:113],[1:23 26:48 51:73 76:93 96:113],: );

%shuffle_3D_data=DECODING_RESULTS.ZERO_ONE_LOSS_RESULTS.mean_decoding_results; %%after loading shuffled results

%shuffle_3D_data= f_dat.data.(f_tasks{ita}).shuffled_data_map.(f_cell_types{ic});
%real_results = f_dat.data.(f_tasks{ita}).accuracy_cross_temporal_decoding.(f_cell_types{ic});
       

 [sign_time_point_H1, sign_time_point_H2, sign_time_point_H3]= compute_H123_(real_results, shuffle_3D_data, 0,crit_perc,pval);

        Stability_index_map_noboot_raw= (1-sign_time_point_H1) .* (1-sign_time_point_H2) .* sign_time_point_H3; 
        sign_diag_point= diag(sign_time_point_H3);
        Stability_index_map_noboot= zeros(size(sign_time_point_H3,1), size(sign_time_point_H3,2));
        [r,c]= find(Stability_index_map_noboot_raw == 1);
        for ksign= 1:length(r)
            if Stability_index_map_noboot_raw(r(ksign),c(ksign)) == 1 && (sign_diag_point(r(ksign)) == 1 && sign_diag_point(c(ksign)) == 1 )
                Stability_index_map_noboot(r(ksign),c(ksign))= 1;
            end
        end

        index_diag = 1 : size(sign_time_point_H3, 1)+ 1 : size(sign_time_point_H3,1) * size(sign_time_point_H3,2);  
        Stability_index_map_noboot(index_diag)= 0;

        Stability_index= make_mean_index(Stability_index_map_noboot, 1);
        Stability_index_all{ic}= Stability_index;

        % %% BOOTSTRAP
        % 
        % a=mean(DECODING_RESULTS.ZERO_ONE_LOSS_RESULTS.decoding_results,2);%%after loading shuffled results
        % 
        %     bootstrap_results_CTD_mat_all= f_dat.data.(f_tasks{ita}).bootstrap_map_real.(f_cell_types{ic});
        %     bootstrap_shuffling_CTD_mat_all= f_dat.data.(f_tasks{ita}).bootstrap_map_shuffled.(f_cell_types{ic});
        % 
        % 
        % bootstrap_IND_Stability= [];
        % bootstrap_3D_data= [];
        % for iboot= 1:length(bootstrap_results_CTD_mat_all)
        % 
        %     [sign_time_point_H1_boot, sign_time_point_H2_boot, sign_time_point_H3_boot]= compute_H123_(bootstrap_results_CTD_mat_all{iboot}, bootstrap_shuffling_CTD_mat_all{iboot}, 1);
        % 
        %     Stability_index_map_raw= (1-sign_time_point_H1_boot) .* (1-sign_time_point_H2_boot) .* sign_time_point_H3_boot; 
        %     sign_diag_point= diag(sign_time_point_H3_boot);
        %     Stability_index_map_boot= zeros(size(sign_time_point_H3_boot,1), size(sign_time_point_H3_boot,2));
        %     [r,c]= find(Stability_index_map_raw == 1);
        %     for ksign= 1:length(r)
        %         if Stability_index_map_raw(r(ksign),c(ksign)) == 1 && (sign_diag_point(r(ksign)) == 1 && sign_diag_point(c(ksign)) == 1 )
        %             Stability_index_map_boot(r(ksign),c(ksign))= 1;
        %         end
        %     end
        % 
        %     index_diag = 1 : size(sign_time_point_H3_boot, 1)+ 1 : size(sign_time_point_H3_boot,1) * size(sign_time_point_H3_boot,2); 
        %     Stability_index_map_boot(index_diag)= 0;
        % 
        %     Stability_index_boot= make_mean_index(Stability_index_map_boot, 1);
        % 
        %     bootstrap_IND_Stability(iboot,:)= Stability_index_boot;
        %     bootstrap_3D_data(:,:,iboot)= bootstrap_results_CTD_mat_all{iboot};
        % 
        % end
        % 
        % Stability_index_std = squeeze(std(bootstrap_IND_Stability,'omitnan'));
        % Stability_index_std_all{ic}= Stability_index_std;

        make_plot_index(Time_window, Stability_index, colormap_CTD{ita}(ic,:), ...
            real_results, Stability_index_map_noboot, ...
         sign_time_point_H3);

    

   % figure('units','normalized','outerposition',[0 0 1 1]);


    
   

