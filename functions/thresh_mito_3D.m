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

      % Smooth
      mito = imgaussfilt(mito,3);

      % Thresh
      mito = mito>10000;
      % mito = mito>prctile(mito(:),thresh_mito_prctile);
      
      % Remove objects that are too small or too large
      mito = bwareafilt(mito,[100 Inf]);
    
      % Store result
      s.(typ)(sid).mito_thresh(:,:,tid) = mito;

    end
    if ONE_ONLY
      return
    end
  end
end