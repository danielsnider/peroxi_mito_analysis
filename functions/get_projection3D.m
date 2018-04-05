log_msg(sprintf('[%s]: %s', mfilename(), 'Calculating projection for each stack...'));
s_mid = [];

%% Get middle slice for each stack
% Loop over stack types
for typ=fields(s)'
  typ=typ{:};
  % Loop over stacks of this type
  for sid=1:length(s.(typ))
    num_timepoints = size(s.(typ)(sid).mito,4);
    z_depth = size(s.(typ)(sid).mito,3);

    for tid=1:num_timepoints
      for zid=1:z_depth-1
        two_mito_slices = s.(typ)(sid).mito(:,:,[zid zid+1],tid); % two z slices
        two_pero_slices = s.(typ)(sid).pero(:,:,[zid zid+1],tid); % two z slices
        s.(typ)(sid).mito_proj(:,:,zid,tid) = sum(two_mito_slices, 3); % sum the z slices
        s.(typ)(sid).pero_proj(:,:,zid,tid) = sum(two_pero_slices, 3); % sum the z slices
      end
    end
  end
end

s.(typ)(sid).mito_mid = s.(typ)(sid).mito_proj(:,:,:,1); % use first timepoint as the mid (the main variable that is operated on)
s.(typ)(sid).pero_mid = s.(typ)(sid).pero_proj(:,:,:,1); % use first timepoint as the mid (the main variable that is operated on)
