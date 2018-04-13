
% clear all
clear T
close all

set(0,'DefaultFigureWindowStyle','docked');
addpath(genpath('functions'));

EDGE_TO_EDGE_DISTANCE = true;
SAVE_NAME_PREFIX = 'from_edge';
date_str = datestr(now,'yyyymmddTHHMMSS');
save_dir = 'saved_figs';
fig_save_path = sprintf('%s/%s/', save_dir, date_str);
mkdir(fig_save_path);
fig_save_path = sprintf('%s/%s', fig_save_path, SAVE_NAME_PREFIX);
mkdir(fig_save_path);

% Load all image data
addpath('bfmatlab')
% data = bfopen('LD_pmMCS_19-2 50000 Matrix 2018-03-01.lif');
% data = bfopen('C:\Users\Daniel\Downloads\Laura DiGiovanni - PO-Mito Live Hyvolution 2018-03-07.lif');
% data = bfopen('Z:\DanielS\Images\LauraD PeterK\Set 2 - Timelapse\Laura DiGiovanni - PO-Mito Live Hyvolution 2018-03-07.lif');

% Pick a stack
series_id = 1; % OME starts at 0
series_id_matlab = series_id+1; % matlab starts at 1

% Load images for stack
% im_mito = data{series_mid}{2};
% im_pero = data{series_mid}{1};

%% Get OME Metadata
any_series_id = 1;
omeMeta = data{any_series_id,4};

%% Image size
NUM_CHANS = 2;

% if exist('done') && done == true
%   txt = sprintf('Detected results already exist. Overwrite?\n');
%   user_command = input(txt,'s');
%   if ~ismember(user_command,{'y','yes'})
%     ok_stopping_now
%   end
% end

ONE_ONLY = false;
TEST_ONE_FIG = false;
SAVE_TO_DISK = true;
SAVE_FIG_MAG = '-m1.5';

CONTACT_DIST_NM = 150;

type_namemap = containers.Map;
type_namemap('raw') = 'Raw 512';
type_namemap('decon') = 'Deconvolved 512';
type_namemap('zoom_raw') = 'Zoomed Raw 1024';
type_namemap('zoom_decon') = 'Zoomed Deconvolved 1024';
type_names = {'Raw', 'Deconvolved', 'Zoomed Raw', 'Zoomed Deconvolved'};

thresh_mito_prctile = 93;
thresh_pero_prctile = 99.6;
min_area = 25;
max_area = 5000;

ResultsTable = table();
all_contact_durations = {}; % one row per cell. Each value is a length of timepoints for contact that took place
all_in_contact_bool = {}; % one row per cell. Each value is whether a pero is in contact or not

organize_2DT
s_all = s;
clear s_all2

% Loop over stack types
count = 0;
for typ={'zoom_decon'}
  typ=typ{:};
  % Loop over stacks of this type
  for sid=2:length(s_all.(typ))
    count=count+1;
    s = [];
    s.(typ) = s_all.(typ)(sid);
    stack_id = sid;
    clear T

    % Skip if user wants to
    % num_timepoints = size(s.(typ).pero_mid,3);
    % txt = sprintf('Do you wish to analyze: Type=%s, StackNum=%d, Count=%d, Timepoints=%d\n(y/n): ',typ,sid,count,num_timepoints);
    % user_command = input(txt,'s');
    % if ismember(user_command,{'n','no',''})
    %   continue
    % end

    % % Limit timepoints for quick debugging
    % s.(typ).pero_mid = s.(typ).pero_mid(:,:,end-1:end);
    % s.(typ).mito_mid = s.(typ).mito_mid(:,:,end-1:end);
    % s.(typ).timepoints = 2;

    % Segmenting
    thresh_mito_3DT
    % montage_mito_red_outline_on_grey_2DT
    thresh_pero_3DT
    % montage_pero_red_outline_on_grey_2DT
     
    %close all
    segment_pero_seed_watershed_3DT
    %visualize_pero_and_mito
    % visualize_pero_and_mito_3D
    % view3d_stacks

    % Calculating
    measure_and_visualize_distance_3DT

    % Create Table
    create_table_pero_3DT

    %% CALC DIFFERENCES BETWEEN FRAMES
    [raw_differences, normalized_differences, composite_differences] = DifferentialMeasurements(T);

    %% TRACK CELLS
    [T,DiffTable] = cell_tracking_v1_simple(T, composite_differences);

    % Visualize (v4 - Tracking 1st)
    measure_and_visualize_distance_3DT
    
    % Save Table
    save_table_pero_2DT
    ResultsTable = [ResultsTable; T];

    % % Plot 
    calc_contact_durations
    frame_to_frame_changes_distance_vs_time

    close all
    s_all2.(typ)(sid) = s.(typ);
  end
end


plot_bar_scatter_contacts_per_cell_2DT


save('ResultsTable.mat','ResultsTable')
save('all_contact_durations.mat','all_contact_durations')
save('all_in_contact_bool.mat','all_in_contact_bool')
s_all = s_all2;
save('s_all2.mat','s_all2')
save('s_all.mat','s_all')

done = true;

