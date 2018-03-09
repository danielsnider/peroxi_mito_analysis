log_msg(sprintf('[%s]: %s', mfilename(), 'Thresholding pero...'));

%% Threshold pero
% Loop over stack types
for typ=fields(s_mid)'
  typ=typ{:};
  % Loop over stacks of this type
  s_pero = s_mid.(typ).pero;
  for z=1:size(s_pero,3)
    pero = s_pero(:,:,z);

    % Smooth
    pero = imgaussfilt(pero,1);

    % Thresh
    pero = pero>prctile(pero(:),98);
    
    % Remove objects that are too small or too large
    pero = bwareaopen(pero,10);
  
    % Store result
    s_mid.(typ).pero_thresh(:,:,z) = pero;
  end
end