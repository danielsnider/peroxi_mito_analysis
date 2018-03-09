%% Make montages of threshold
montages_to_make = {...
  'pero_thresh', ...
  'mito_thresh', ...
}
  % 'pero', ...
  % 'mito', ...
% Loop over stack types
for typ=fields(s_mid)'
  % Loop over stacks of this type
  typ=typ{:};
  % Loop over kinds of montages
  for montage_name=montages_to_make
    montage_name=montage_name{:};
    m = s_mid.(typ)(1).(montage_name);
    m = reshape(m,[size(m,1), size(m,2), 1, size(m,3)]);
    figure
    montage(m,'DisplayRange',[0 prctile(m(:),99.5)]);
    hold on
    fig_name = [typ ' ' montage_name];
    text(0.01,.99,fig_name,'FontSize',14,'Units','normalized','Interpreter','none','Color','white','HorizontalAlignment','left','VerticalAlignment','top');
    %export_fig([fig_save_path fig_name '.png'],'-m2');
    %close all
  end
end