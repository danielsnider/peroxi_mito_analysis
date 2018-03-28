log_msg(sprintf('[%s]: %s', mfilename(), 'Thresholding pero...'));

%% Threshold pero
% Loop over stack types
for typ=fields(s)'
  typ=typ{:};
  % Special Threshold Values
  if strcmp(typ,'raw')
    thresh_pero_prctile = 99.7;
  elseif strcmp(typ,'zoom_raw')
    thresh_pero_prctile = 99.7;
  end
  thresh_pero_prctile

  % Loop over stacks of this type
  for sid=1:length(s.(typ))
    s_pero = s.(typ)(sid).pero_mid;
    % Loop over timepoints
    for tid=1:size(s_pero,3)
      pero = s_pero(:,:,tid);
      % if sum(pero(:)) < MIN_INTENSITY_MAP(typ)
      %   msg = sprintf('Not enough signal (%d) in image of type=%s, one_z=%d. Must be at least %d.', sum(pero(:)), typ, tid, MIN_INTENSITY_MAP(typ))
      %   warning(msg);
      %   zeros_ = zeros(size(mito));
      %   pero = zeros_;
      % end

      % Smooth
      pero = imgaussfilt(pero,1);

      % Thresh
      pero = pero>prctile(pero(:),thresh_pero_prctile);
      
      % Store result
      s.(typ)(sid).pero_thresh(:,:,tid) = pero;

    end
  end
  if ONE_ONLY
    return
  end
end