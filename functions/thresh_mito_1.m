log_msg(sprintf('[%s]: %s', mfilename(), 'Thresholding mito...'));

%% Threshold Mito
% Loop over stack types
for typ=fields(s_mid)'
  typ=typ{:};
  % Loop over stacks of this type
  s_mito = s_mid.(typ).mito;
  for z=1:size(s_mito,3)
    mito = s_mito(:,:,z);

    % Smooth
    mito = imgaussfilt(mito,1);

    % Thresh
    mito = mito>prctile(mito(:),85);
    
    % Remove objects that are too small or too large
    mito = bwareaopen(mito,100);
  
    % Store result
    s_mid.(typ).mito_thresh(:,:,z) = mito;
  end
end