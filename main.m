clear all
close all

USE_SLICE = 'middle'; % first, middle, or last

thresh_mito_prctile = 93; 
thresh_pero_prctile = 99.5; 
min_area = 5;
max_area = 5000;

ONE_ONLY = false;
TEST_ONE_FIG = false;
SAVE_TO_DISK = true;
SAVE_FIG_MAG = '-m1';
SAVE_NAME_PREFIX = 'from_edge_';

EDGE_TO_EDGE_DISTANCE = true;
CONTACT_DIST_NM = 150;

MIN_INTENSITY_MAP = containers.Map;
MIN_INTENSITY_MAP('raw') = 0; % 1500000
MIN_INTENSITY_MAP('decon') = 0; % 300000000
MIN_INTENSITY_MAP('zoom_raw') = 0; % 2000000
MIN_INTENSITY_MAP('zoom_decon') = 0; % 350000000

type_namemap = containers.Map;
type_namemap('raw') = 'Raw';
type_namemap('decon') = 'Deconvolved';
type_namemap('zoom_raw') = 'Zoomed Raw';
type_namemap('zoom_decon') = 'Zoomed Deconvolved';
type_names = {'Raw', 'Deconvolved', 'Zoomed Raw', 'Zoomed Deconvolved'};


% Load all image data
addpath('bfmatlab')
data = bfopen('LD_pmMCS_19-2 50000 Matrix 2018-03-01.lif');

% Setup 
set(0,'DefaultFigureWindowStyle','docked');
addpath(genpath('functions'));
addpath('C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\plugins\segmentation\watershed\')
addpath('C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\plugins\segmentation\spot\')

% Setup
date_str = datestr(now,'yyyymmddTHHMMSS');
save_dir = 'saved_figs';
fig_save_path = sprintf('%s/%s/', save_dir, date_str);
mkdir(fig_save_path);
fig_save_path = sprintf('%s/%s', fig_save_path, SAVE_NAME_PREFIX);

% Pick a stack
series_id = 1; % OME starts at 0
series_mid = series_id+1; % matlab starts at 1

% Load images for stack
% im_mito = data{series_mid}{2};
% im_pero = data{series_mid}{1};

%% Get OME Metadata
any_series_id = 1;
omeMeta = data{any_series_id,4};
% Image Name
omeMeta.getImageName(series_id);
% Pixel Size
omeMeta.getPixelsPhysicalSizeX(series_id).value(ome.units.UNITS.NANOMETER);

%% Image size
x_res = size(data{1}{1},1);
y_res = size(data{1}{1},2);
NUM_CHANS = 2;
% Note z resolution varies.

%% Organizing
organize_4_types_of_stacks
s_all = s;
num_stacks = length(s.raw);
get_one_slice_for_each_stack

% Segmenting
thresh_mito_1
thresh_pero_1
convex_area_1
segment_pero_seed_watershed

% Calculating
measure_dist_pero_to_mito

break_

% V1 V2
% montage_pero_ws_shuffle_on_grey
% montage_mito_red_outline_on_grey
% visualize_pero_and_mito_with_distances

% visualize_pero_and_mito
% montage_overview_pero_mito
% montage_thresh_bw_loop

% plot_ksdensity_distance (old)
% plot_ksdensity_histogram_distance
% plot_ksdensity_histogram_distance_scaled
% plot_bar_grouped_by_type (less useful)
% plot_bar_stacked_num_contacts; beep
% plot_bar_stacked_percent_contacts; beep

% plot_ksdensity_pero_area_and_intensity
% plot_bar_grouped_by_type_mtotal_div_ptotal
% plot_scatter_pero_intensity_vs_dist;beep

% % Save stats
% save_table_pero



%% V3
%montage_pero_ws_shuffle_on_grey
%montage_mito_red_outline_on_grey
visualize_pero_and_mito_with_distances
plot_ksdensity_histogram_distance
plot_bar_grouped_by_type_num_pero
plot_bar_grouped_by_type_mtotal_div_ptotal
plot_bar_num_pero_div_convex_mito_area
plot_bar_stacked_num_contacts
plot_bar_stacked_percent_contacts
plot_ksdensity_pero_area_and_intensity
save_table_pero