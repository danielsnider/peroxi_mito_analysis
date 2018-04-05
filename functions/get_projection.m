log_msg(sprintf('[%s]: %s', mfilename(), 'Calculating projection for each stack...'));
s_mid = [];

%% Get middle slice for each stack
% Loop over stack types
for typ=fields(s)'
  typ=typ{:};
  % Loop over stacks of this type
  for sid=1:length(s.(typ))
    % if strcmp(USE_SLICE,'middle')
    %   z_mid = uint16(round(size(s.(typ)(sid).mito,3)/2));
    % elseif strcmp(USE_SLICE,'first')
    %   z_mid = 1;
    % elseif strcmp(USE_SLICE,'last')
    %   z_mid = size(s.(typ)(sid).mito,3);
    % end

    % PROJECTION_TYPE = 'sum';
    % PROJECTION_SLICES = 1:5;
    mito_stack = s.(typ)(sid).mito(:,:,PROJECTION_SLICES,:);
    pero_stack = s.(typ)(sid).pero(:,:,PROJECTION_SLICES,:);
    for tid=1:size(mito_stack,4)
      if strcmp(PROJECTION_TYPE,'max')
        s.(typ)(sid).mito_mid(:,:,tid) = max(mito_stack(:,:,:,tid), [], 3); % max in the z direction
        s.(typ)(sid).pero_mid(:,:,tid) = max(pero_stack(:,:,:,tid), [], 3); % max in the z direction
      elseif strcmp(PROJECTION_TYPE,'sum')
        s.(typ)(sid).mito_mid(:,:,tid) = sum(mito_stack(:,:,:,tid), 3); % max in the z direction
        s.(typ)(sid).pero_mid(:,:,tid) = sum(pero_stack(:,:,:,tid), 3); % max in the z direction
      elseif strcmp(PROJECTION_TYPE,'mean')
        s.(typ)(sid).mito_mid(:,:,tid) = mean(mito_stack(:,:,:,tid), 3); % max in the z direction
        s.(typ)(sid).pero_mid(:,:,tid) = mean(pero_stack(:,:,:,tid), 3); % max in the z direction
      end
    end


    
  end
end

