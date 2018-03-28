
count = 0;

% Loop over stack types
for typ={'zoom_decon'}
  typ=typ{:};
  % Loop over stacks of this type
  for sid=1:length(s_all.(typ))
    count=count+1;
    s = [];
    s.(typ) = s_all.(typ)(sid);
    stack_id = sid;

%     % Skip if user wants to
%     num_timepoints = size(s.(typ).pero_mid,3);
%     txt = sprintf('Do you wish to analyze: Type=%s, StackNum=%d, Count=%d, Timepoints=%d\n(y/n): ',typ,sid,count,num_timepoints);
%     user_command = input(txt,'s');
%     if ismember(user_command,{'n','no',''})
%       continue
%     end

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

    % Visualize (v4 - Tracking 1st)
    visualize_pero_and_mito_with_distances_2DT
    
    % Save Table
    save_table_pero_2DT

    % Plot 
    bar_contact_duration
    frame_to_frame_changes_distance_vs_time

%     pause
%     pause
    close all
  end
end