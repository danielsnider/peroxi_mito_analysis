log_msg(sprintf('[%s]: %s', mfilename(), 'Getting middle slice for each stack...'));

%% Get middle slice for each stack
% Loop over stack types
for typ=fields(s)'
  typ=typ{:};
  % Loop over stacks of this type
  for sid=1:length(s.(typ))
    z_mid = uint16(round(size(s.(typ)(sid).mito,3)/2));
    s_mid.(typ).mito(:,:,sid) = s.(typ)(sid).mito(:,:,z_mid);
    s_mid.(typ).pero(:,:,sid) = s.(typ)(sid).pero(:,:,z_mid);
  end
end

