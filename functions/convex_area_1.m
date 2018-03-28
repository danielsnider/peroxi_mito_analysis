log_msg(sprintf('[%s]: %s', mfilename(), 'Convex area mito...'));

%% Threshold Mito
% Loop over stack types
for typ=fields(s_mid)'
  typ=typ{:};
  % Loop over stacks of this type
  for z=1:size(s_mito,3)
    mito_thresh = s_mid.(typ).mito_thresh(:,:,z);
    pero_thresh = s_mid.(typ).pero_thresh(:,:,z);
    mask = or(mito_thresh,pero_thresh);
    stats = regionprops('table',uint8(mask),'ConvexArea','ConvexHull');

    % Store result
    if ~isempty(stats)
      s_mid.(typ).ConvexAreaPX(z) = stats.ConvexArea;
      s_mid.(typ).ConvexHull(z) = stats.ConvexHull;
      if strfind(typ,'zoom')
        scale_factor = 48; % nm per pixel
      else
        scale_factor = 90; % nm per pixel
      end
      s_mid.(typ).ConvexAreaSqrUM(z) = (s_mid.(typ).ConvexAreaPX(z)*scale_factor)/1000/1000;
    end

    if ONE_ONLY
      return
    end
  end
end