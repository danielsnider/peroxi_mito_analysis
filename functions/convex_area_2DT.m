log_msg(sprintf('[%s]: %s', mfilename(), 'Convex area mito...'));

%% Threshold Mito
% Loop over stack types
for typ=fields(s)'
  typ=typ{:};
  % Loop over stacks of this type
  for sid=1:length(s.(typ))
    % Loop over timepoints
    for tid=1:size(s.(typ)(sid).mito_thresh,3)
      mito_thresh = s.(typ)(sid).mito_thresh(:,:,tid);
      pero_thresh = s.(typ)(sid).pero_thresh(:,:,tid);
      mask = or(mito_thresh,pero_thresh);
      stats = regionprops('table',uint8(mask),'ConvexArea','ConvexHull');

      % Store result
      if ~isempty(stats)
        s.(typ)(sid).ConvexAreaPX(tid) = stats.ConvexArea;
        s.(typ)(sid).ConvexHull(tid) = stats.ConvexHull;
        if strfind(typ,'zoom')
          scale_factor = 48; % nm per pixel
        else
          scale_factor = 90; % nm per pixel
        end
        s.(typ)(sid).ConvexAreaSqrUM(tid) = (s.(typ)(sid).ConvexAreaPX(tid)*scale_factor)/1000/1000;
      end

    end
    if ONE_ONLY
      return
    end
  end
end