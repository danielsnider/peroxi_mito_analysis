% clear all
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

USE_SLICE = 'middle'; % first, middle, or last
thresh_mito_prctile = 93;
thresh_pero_prctile = 99.7;
min_area = 25;
max_area = 5000;

ONE_ONLY = false;
TEST_ONE_FIG = false;
SAVE_TO_DISK = true;
SAVE_FIG_MAG = '-m0.5';

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

%% Organizing
organize_2DT
get_one_slice_for_each_stack
s_all = s;

% One Stack at a time
analyse_one_stack_at_a_time_2DT