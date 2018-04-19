
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

% 2.5D Settings
PROJECTION_TYPE = 'sum';
PROJECTION_SLICES = 3:4;
USE_SLICE='3 and 4'; % for text in figure only

% TIMEPOINT_LIMIT = 1:12;
TIMEPOINT_LIMIT = 1:2;

ONE_ONLY = false;
ONLY_ONE_NEW = true;
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
thresh_pero_prctile = 99.5;
min_area = 25;
max_area = 5000;

MitoTable = table();
DwellTable = table();
ResultsTable = table();
PeroSummaryTable = table();
all_contact_durations = {}; % one row per cell. Each value is a length of timepoints for contact that took place
all_in_contact_bool = {}; % one row per cell. Each value is whether a pero is in contact or not

organize_2DT
limit_timepoints_and_z
s_all = s;
clear s_all2

IMAGE_PROCESSING_TYPE = '3D';

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
    clear T

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
    RENDER_PERO = true; % visualize shape of pero in 3d instead of scatter3 sphere
    SAVE_TO_DISK = false;
    measure_and_visualize_distance_3DT
    SAVE_TO_DISK = true;

    % Create Table
    create_table_pero_3DT

    %% CALC DIFFERENCES BETWEEN FRAMES
    [raw_differences, normalized_differences, composite_differences] = DifferentialMeasurements(T);

    %% TRACK CELLS
    [T,DiffTable] = cell_tracking_v1_simple(T, composite_differences);

    % Visualize (v4 - Tracking 1st)
    DO_DIST_CALC = false;
    measure_and_visualize_distance_3DT
    DO_DIST_CALC = true;
    
    % Calculate more stats
    calc_contact_durations

    % Save Table
    %save_table_pero_2DT
    ResultsTable = [ResultsTable; T];

    close all
    s_all2.(typ)(sid) = s.(typ);
  end
end

plot_bar_scatter_contacts_per_cell_2DT

save('s_all2-3d.mat','s_all2')
save('s_all-3d.mat','s_all')


log_msg(sprintf('[%s]: %s', mfilename(), '2.5D'));

all_contact_durations = {}; % one row per cell. Each value is a length of timepoints for contact that took place
all_in_contact_bool = {}; % one row per cell. Each value is whether a pero is in contact or not


organize_2DT
get_projection
s_all = s;

IMAGE_PROCESSING_TYPE = '2.5D';

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

    % Limit timepoints to one minute
    s.(typ).pero_mid = s.(typ).pero_mid(:,:,TIMEPOINT_LIMIT);
    s.(typ).mito_mid = s.(typ).mito_mid(:,:,TIMEPOINT_LIMIT);
    s.(typ).timepoints = length(TIMEPOINT_LIMIT);

    % Segmenting
    thresh_mito_2DT
    thresh_pero_2DT
    convex_area_2DT
    segment_pero_seed_watershed_2DT

    % Calculating
    measure_dist_pero_to_mito_2DT

    % Create Table
    create_table_pero_3DT

    %% CALC DIFFERENCES BETWEEN FRAMES
    [raw_differences, normalized_differences, composite_differences] = DifferentialMeasurements(T);

    %% TRACK CELLS
    [T,DiffTable] = cell_tracking_v1_simple(T, composite_differences);

    %% Remove Short Tracks
    %remove_short_tracks

    % Visualize (v4 - Tracking 1st)
    visualize_pero_and_mito_with_distances_2DT
    
    % Calculate more stats
    calc_contact_durations

    % Save Table
    %save_table_pero_2DT
    T.CellConvexAreaPX = [];
    T.TraceUsed = [];
    ResultsTable = [ResultsTable; T];

    close all
    s_all2.(typ)(sid) = s.(typ);
  end
end


% Save Table
filename = sprintf('%s/peroxisome_stats all cells.csv',fig_save_path);
writetable(ResultsTable,filename);


save('s_all2-25d.mat','s_all2')
save('s_all-25d.mat','s_all')

plot_line_mito_area
plot_line_pero_count


save('ResultsTable.mat','ResultsTable')
