log_msg(sprintf('[%s]: %s', mfilename(), 'Organizing the images...'));

keepers = {...
  '512x512 700 speed 5 sec stack 2 min 1/Series011', ...
  '512x512 700 speed 5 sec stack 2 min 1/Series011_decon', ...
  '512x512 700 speed 5 sec stack 2 min 2/Series012', ...
  '512x512 700 speed 5 sec stack 2 min 2/Series012_decon', ...
  'Good 1024x1024 1000speed 5sec stack 2 min 1/Series007', ...
  'Good 1024x1024 1000speed 5sec stack 2 min 1/Series007_decon', ...
  'Good 1024x1024 1000speed 5sec stack 2 min 2/Series008', ...
  'Good 1024x1024 1000speed 5sec stack 2 min 2/Series008_decon', ...
  'Good 1024x1024 1000 speed 5sec stack 2 min 3/Series009', ...
  'Good 1024x1024 1000 speed 5sec stack 2 min 3/Series009_decon', ...
};

%% Organize the images!
s = struct();
s.raw = [];
s.decon = [];
s.zoom_raw = [];
s.zoom_decon = [];
% Loop over series
for series_id=1:omeMeta.getImageCount
  dat = data{series_id};
  stack_name = dat{1,2}
  if ~contains(stack_name,keepers)
    continue % Skip this stack is not a keeper
  end

  log_msg(sprintf('[%s]: Organizing the series %d of %d...', mfilename(), series_id, omeMeta.getImageCount));

  im_res_x = size(dat{1},1);
  im_res_y = size(dat{1},2);
  stack_ = [];
  % Loop over planes
  for plane_id=1:length(dat)
    name = dat{plane_id,2}; % example:     {'Z:\DanielS\Images\LauraD PeterK\Set 2 - Timelapse\Laura DiGiovanni - PO-Mito Live Hyvolution 2018-03-07.lif; HyVolution/Series003; plane 1/80; Z=1/5; C=1/2; T=1/8' }
    pos = regexp(name,' Z=(?<z>\d+).* C=(?<chan>\d+).* T=(?<time>\d+)','names');
    pos.z = str2num(pos.z);
    pos.time = str2num(pos.time);
    pos.chan = str2num(pos.chan);
    stack_(:,:,pos.z, pos.time, pos.chan) = dat{plane_id,1}; 
  end
  % Save seperated stacks for this series
  if contains(stack_name,'512x512 700 speed') && contains(stack_name,'_decon')
    typ = 'decon';
  elseif contains(stack_name,'Good 1024x1024 1000') && contains(stack_name,'_decon')
    typ = 'zoom_decon';
  elseif contains(stack_name,'512x512 700 speed')
    typ = 'raw';
  elseif contains(stack_name,'Good 1024x1024 1000')
    typ = 'zoom_raw';
  end
  idx = length(s.(typ))+1;
  s.(typ)(idx).pero = stack_(:,:,:,:,1);
  s.(typ)(idx).mito = stack_(:,:,:,:,2);
  s.(typ)(idx).series_id = series_id;
  s.(typ)(idx).z_depth = size(stack_,3);
  s.(typ)(idx).timepoints = size(stack_,4);
  s.(typ)(idx).chan_num = size(stack_,5);
end
