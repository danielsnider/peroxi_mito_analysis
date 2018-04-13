log_msg(sprintf('[%s]: %s', mfilename(), 'Thresholding pero...'));

%% Threshold pero
% Loop over stack types
for typ=fields(s)'
  typ=typ{:};

  % Loop over stacks of this type
  for sid=1:length(s.(typ))
    s_pero = s.(typ)(sid).pero;
    % Loop over timepoints
    for tid=1:size(s_pero,4)
      % Loop over timepoints
      for zid=1:size(s_pero,3)
        pero = s_pero(:,:,zid,tid);

        % Smooth
        pero = imgaussfilt(pero,1);

        % Thresh
        pero = pero>12000;

        % Remove objects that are too small or too large
        pero = bwareafilt(pero,[10 Inf]);

        % Store result
        s.(typ)(sid).pero_thresh(:,:,zid,tid) = pero;
      end
    end
    if ONE_ONLY
      return
    end
  end
end