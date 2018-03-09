log_msg(sprintf('[%s]: %s', mfilename(), 'Organizing the images...'));

%% Organize the images!
s = struct();
s.raw = [];
s.decon = [];
s.zoom_raw = [];
s.zoom_decon = [];
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
    idx = length(s.raw)+1;
    s.raw(idx).mito = stack_mito;
    s.raw(idx).pero = stack_pero;
  elseif mod(series_id,4)==2
    idx = length(s.decon)+1;
    s.decon(idx).mito = stack_mito;
    s.decon(idx).pero = stack_pero;
  elseif mod(series_id,4)==3
    idx = length(s.zoom_raw)+1;
    s.zoom_raw(idx).mito = stack_mito;
    s.zoom_raw(idx).pero = stack_pero;
  elseif mod(series_id,4)==0
    idx = length(s.zoom_decon)+1;
    s.zoom_decon(idx).mito = stack_mito;
    s.zoom_decon(idx).pero = stack_pero;
  end
end
