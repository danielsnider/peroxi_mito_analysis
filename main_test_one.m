for slice_pos={'middle'}
    %for slice_pos={'first','middle','last'}
  for n=10
    USE_SLICE = slice_pos; % first, middle, or last
    USE_STACK_NUM = n;
    thresh_mito_prctile = 93; % 95
    thresh_pero_prctile = 99.5; %99.5
    min_area = 5;
    max_area = 5000;


    s = s_all;
    s = rmfield(s,'raw');
    s = rmfield(s,'decon');
    s = rmfield(s,'zoom_raw');
    s.zoom_decon=s.zoom_decon(USE_STACK_NUM);

    clear s_mid
    get_one_slice_for_each_stack


    % Segmenting
    ONE_ONLY = true; 
    thresh_mito_1
    thresh_pero_1
    segment_pero_seed_watershed

    % Calculating
    measure_dist_pero_to_mito

    % Visualizing
    TEST_ONE_FIG = true;
    plot_ksdensity_histogram_distance_scaled
    montage_pero_ws_shuffle_on_grey
    montage_mito_red_outline_on_grey
    visualize_pero_and_mito_with_distances
  end
  %break
end