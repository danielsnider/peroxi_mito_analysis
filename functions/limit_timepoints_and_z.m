log_msg(sprintf('[%s]: %s', mfilename(), 'Limiting each stack...'));
s_mid = [];

% Loop over stack types
for typ=fields(s)'
  typ=typ{:};
  % Loop over stacks of this type
  for sid=1:length(s.(typ))
    s.(typ)(sid).pero = s.(typ)(sid).pero(:,:,PROJECTION_SLICES,TIMEPOINT_LIMIT); % limit z and timepoints respectively
    s.(typ)(sid).mito = s.(typ)(sid).mito(:,:,PROJECTION_SLICES,TIMEPOINT_LIMIT);
    s.(typ)(sid).z_depth = 2;
    s.(typ)(sid).timepoints = 12;
  end
end

