set(0,'DefaultFigureWindowStyle','docked');
addpath(genpath('functions'));
addpath('C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\plugins\segmentation\watershed\')
addpath('C:\Users\daniel snider\Dropbox\Kafri\Projects\GUI\plugins\segmentation\spot\')

% Load all image data
addpath('bfmatlab')
%data = bfopen('LD_pmMCS_19-2 50000 Matrix 2018-03-01.lif')

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
omeMeta.getImageName(series_id)
% Pixel Size
omeMeta.getPixelsPhysicalSizeX(series_id).value(ome.units.UNITS.NANOMETER)





NUM_CHANS = 2;


%% Organize the images!
stack_raw = [];
stack_decon = [];
stack_zoom_raw = [];
stack_zoom_decon = [];

% Loop over series
for series_id=1:omeMeta.getImageCount
  dat = data{series_id};
  im_res_x = size(dat{1},1);
  im_res_y = size(dat{1},2);
  im_res_z = length(dat)/NUM_CHANS;
  stack_mito = zeros(im_res_x, im_res_y, im_res_z);
  stack_pero = zeros(im_res_x, im_res_y, im_res_z);
  % Loop over planes
  for plane_id=1:NUM_CHANS:length(dat)
    stack_pero(:,:,uint16(round(plane_id/NUM_CHANS))) = dat{plane_id,1}; % note: {1,2} would be the name of this plane
    stack_mito(:,:,uint16(round(plane_id/NUM_CHANS))) = dat{plane_id+1,1};
  end
  % Save seperated stacks for this series
  if mod(series_id,4)==1
    idx = length(stack_raw)+1;
    stack_raw(idx).mito = stack_mito;
    stack_raw(idx).pero = stack_pero;
  elseif mod(series_id,4)==2
    idx = length(stack_decon)+1;
    stack_decon(idx).mito = stack_mito;
    stack_decon(idx).pero = stack_pero;
  elseif mod(series_id,4)==3
    idx = length(stack_zoom_raw)+1;
    stack_zoom_raw(idx).mito = stack_mito;
    stack_zoom_raw(idx).pero = stack_pero;
  elseif mod(series_id,4)==0
    idx = length(stack_zoom_decon)+1;
    stack_zoom_decon(idx).mito = stack_mito;
    stack_zoom_decon(idx).pero = stack_pero;
  end
end






% histogram of intensities across all images

% thresh_param 
% smooth_param 
% debug_level
% seeds = spot(plugin_name, plugin_num, img, thresh_param, smooth_param, debug_level)

% im_ws_img = watershed_plugin('plugin_name', 'plugin_num', im_mito, seeds, threshold_smooth_param, watershed_smooth_param, thresh_param, min_area, max_area, debug_level)

% figure;
% imshow(im_mito,[]);
% figure;
% imshow(im_pero,[]);
