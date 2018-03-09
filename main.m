clear all
close all

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

% Pick a stack
series_id = 3; % OME starts at 0
series_mid = series_id+1; % matlab starts at 1

% Load images for stack
im_mito = data{series_mid}{2};
im_pero = data{series_mid}{1};

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

% Organizing
organize_4_types_of_stacks
montage_overview_pero_mito
get_middle_slice_for_each_stack

% Segmenting
thresh_mito_1
thresh_pero_1
segment_pero_seed_watershed

% Calculating
measure_dist_pero_to_mito

% Visualizing
%visualize_pero_and_mito
visualize_pero_and_mito_with_distances
% montage_thresh_bw_loop
%montage_pero_ws_shuffle_on_grey
%montage_mito_red_outline_on_grey

% Plotting
plot_ksdensity_distance
plot_bar_multi


