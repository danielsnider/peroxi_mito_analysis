log_msg(sprintf('[%s]: %s', mfilename(), 'Viewing stacks...'));
close all
%% Threshold Mito
% Loop over stack types
for typ=fields(s)'
  typ=typ{:};

  % Loop over stacks of this type
  for sid=1:size(s.(typ),2)
    s_mito = s.(typ)(sid).mito;
    s_pero = s.(typ)(sid).pero;
    fig_name = sprintf('%s %d mito', typ, sid);
    figure('name',fig_name, 'NumberTitle','off');imshow3Dfull(squeeze(s_mito(:,:,sid,:)))
    axis on
    fig_name = sprintf('%s %d pero', typ, sid);
    figure('name',fig_name, 'NumberTitle','off');imshow3Dfull(squeeze(s_pero(:,:,sid,:)))
    axis on
    pause

    if ONE_ONLY
      break
    end
  end
end