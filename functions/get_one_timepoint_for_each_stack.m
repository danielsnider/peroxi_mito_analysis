log_msg(sprintf('[%s]: %s', mfilename(), 'Getting one timepoint each stack...'));

%% Get middle slice for each stack
% Loop over stack types
for typ=fields(s)'
  typ=typ{:};
  % Loop over stacks of this type
  for sid=1:length(s.(typ))
    s.(typ)(sid).mito_mid = s.(typ)(sid).mito(:,:,:,1); % use first timepoint as the mid (the main variable that is operated on)
    s.(typ)(sid).pero_mid = s.(typ)(sid).pero(:,:,:,1); % use first timepoint as the mid (the main variable that is operated on)
  end
end

