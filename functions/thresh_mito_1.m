log_msg(sprintf('[%s]: %s', mfilename(), 'Thresholding mito...'));

%% Threshold Mito
% Loop over stack types
for typ=fields(s_mid)'
  typ=typ{:};
  % Loop over stacks of this type
  s_mito = s_mid.(typ).mito;
  for z=1:size(s_mito,3)
    mito = s_mito(:,:,z);
    if sum(sum(s_mid.(typ).mito(:,:,z))) < MIN_INTENSITY_MAP(typ)
      msg = sprintf('Not enough signal (%d) in image of type=%s, one_z=%d. Must be at least %d.', sum(sum(s_mid.(typ).mito(:,:,z))), typ, z, MIN_INTENSITY_MAP(typ))
      warning(msg);
      zeros_ = zeros(size(mito));
      mito = zeros_;
    end

    % Smooth
    mito = imgaussfilt(mito,1);

    % Thresh
    mito = mito>prctile(mito(:),thresh_mito_prctile);
    
    % Remove objects that are too small or too large
    mito = bwareaopen(mito,50);
  
    % Store result
    s_mid.(typ).mito_thresh(:,:,z) = mito;

    if ONE_ONLY
      break
    end
  end
end