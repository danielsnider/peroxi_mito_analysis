log_msg(sprintf('[%s]: %s', mfilename(), 'Montage overview...'));


%% Make montages
montages_to_make = {...
  'pero', ...
  'mito', ...
}
% Loop over stack types
for typ=fields(s)'
  % Loop over stacks of this type
  typ=typ{:};
  for sid=1:length(s.(typ))
    % Loop over kinds of montages
    for montage_name=montages_to_make
      montage_name=montage_name{:};
      m = s.(typ)(sid).(montage_name);
      m = reshape(m,[size(m,1), size(m,2), 1, size(m,3)]);
      figure
      montage(m,'DisplayRange',[0 prctile(m(:),99.5)]);
      hold on
      fig_name = sprintf('bw montage %s stack %03d %s',typ, sid, montage_name);
      text(0.01,.99,fig_name,'FontSize',14,'Units','normalized','Interpreter','none','Color','white','HorizontalAlignment','left','VerticalAlignment','top');
      if SAVE_TO_DISK
        export_fig([fig_save_path fig_name '.png'],'-m2');
        close all
      end
    end
  end
end