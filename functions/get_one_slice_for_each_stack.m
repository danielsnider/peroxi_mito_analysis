log_msg(sprintf('[%s]: %s', mfilename(), 'Getting one slice for each stack...'));

%% Get middle slice for each stack
% Loop over stack types
for typ=fields(s)'
  typ=typ{:};
  % Loop over stacks of this type
  for sid=1:length(s.(typ))
    if strcmp(USE_SLICE,'middle')
      z_mid = uint16(round(size(s.(typ)(sid).mito,3)/2));
    elseif strcmp(USE_SLICE,'first')
      z_mid = 1;
    elseif strcmp(USE_SLICE,'last')
      z_mid = size(s.(typ)(sid).mito,3);
    end
      
    s_mid.(typ).mito(:,:,sid) = s.(typ)(sid).mito(:,:,z_mid);
    s_mid.(typ).pero(:,:,sid) = s.(typ)(sid).pero(:,:,z_mid);
  end
end

