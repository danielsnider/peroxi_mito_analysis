log_msg(sprintf('[%s]: %s', mfilename(), 'Thresholding mito...'));

%% Threshold Mito
% Loop over stack types
for typ=fields(s)'
  typ=typ{:};
  % Loop over stacks of this type
  for sid=1:length(s.(typ))
    s_mito = s.(typ)(sid).mito_mid;
    % Loop over timepoints
    for tid=1:size(s_mito,3)
      mito = s_mito(:,:,tid);
      if sum(mito(:)) < MIN_INTENSITY_MAP(typ)
        msg = sprintf('Not enough signal (%d) in image of type=%s, one_z=%d. Must be at least %d.', sum(mito(:)), typ, tid, MIN_INTENSITY_MAP(typ))
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
      s.(typ)(sid).mito_thresh(:,:,tid) = mito;

    end
    if ONE_ONLY
      return
    end
  end
end