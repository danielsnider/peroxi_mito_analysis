
if exist('done') && done == true
  txt = sprintf('Detected results already exist. Overwrite?\n');
  user_command = input(txt,'s');
  if ~ismember(user_command,{'y','yes'})
    ok_stopping_now
  end
end

ONE_ONLY = false;
TEST_ONE_FIG = false;
SAVE_TO_DISK = true;
SAVE_FIG_MAG = '-m2';

thresh_mito_prctile = 93;
thresh_pero_prctile = 99.6;
min_area = 25;
max_area = 5000;

s_all=s;
ResultsTable = table();
all_contact_durations = {}; % one row per cell. Each value is a length of timepoints for contact that took place
all_in_contact_bool = {}; % one row per cell. Each value is whether a pero is in contact or not

organize_2DT
get_one_slice_for_each_stack
s_all = s;

% Loop over stack types
count = 0;
for typ={'zoom_decon'}
  typ=typ{:};
  % Loop over stacks of this type
  for sid=1:length(s_all.(typ))
    count=count+1;
    s = [];
    s.(typ) = s_all.(typ)(sid);
    stack_id = sid;

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
    thresh_mito_2DT
    thresh_pero_2DT
    convex_area_2DT
    segment_pero_seed_watershed_2DT
    % montage_mito_red_outline_on_grey_2DT
    % montage_pero_ws_shuffle_on_grey_2DT
    % view3d_stacks

    % Calculating
    measure_dist_pero_to_mito_2DT

    % Create Table
    create_table_pero_2DT

    %% CALC DIFFERENCES BETWEEN FRAMES
    [raw_differences, normalized_differences, composite_differences] = DifferentialMeasurements(T);

    %% TRACK CELLS
    [T,DiffTable] = cell_tracking_v1_simple(T, composite_differences);

    %% Remove Short Tracks
    remove_short_tracks

    % Visualize (v4 - Tracking 1st)
    visualize_pero_and_mito_with_distances_2DT
    
    % Save Table
    save_table_pero_2DT
    ResultsTable = [ResultsTable; T];

    % Plot 
    calc_contact_durations
    %bar_contact_duration
    frame_to_frame_changes_distance_vs_time

     % pause
     % pause
   close all
   s_all.(typ)(sid) = s.(typ);
  end
end

plot_bar_scatter_contacts_per_cell_2DT
done = true;