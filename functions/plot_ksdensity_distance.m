log_msg(sprintf('[%s]: %s', mfilename(), 'Plotting ksdensity distances...'));

type_namemap = containers.Map;
type_namemap('raw') = 'Raw';
type_namemap('decon') = 'Deconvolved';
type_namemap('zoom_raw') = 'Zoomed Raw';
type_namemap('zoom_decon') = 'Zoomed Deconvolved';

n = 0;
aspects = struct();
n = n + 1;
aspects(n).title = 'Pixel Distance to Mitochondria';
aspects(n).value = 'Distances';
aspects(n).xlabel = 'Euclidean Pixel Distance (Peroxisome —> Mitochondria)';
aspects(n).ylabel = 'Probability';

for aspect_num=1:length(aspects)
  figure;
  count = 1;
  aspect = aspects(aspect_num);
  all_axis = [];

  % Loop over stack types
  for typ=fields(s_mid)'
    ax = subplot(2,2,count);
    all_axis = [all_axis ax];

    count = count+1;
    typ=typ{:};
    num_stacks = length(s_mid.(typ).(aspect.value));
    cmap=cbrewer('qual', 'Set2', num_stacks)
    legend_names = {};
    all_Values = [];
    % Loop over images in this stack
    for sid=1:num_stacks
      Values = s_mid.(typ).(aspect.value){sid};
      all_Values = [all_Values Values];
      limits = linspace(double(prctile(Values(:),0.5)),double(prctile(Values(:),99.5)),100);
      [f,xi] = ksdensity(Values,limits);
      % cmap_index = round(size(cmap,1)/num_stacks)*z;
      % plot(xi,f,'LineWidth',1,'color',cmap(cmap_index,:))
      plot(xi,f,'LineWidth',1,'color',cmap(sid,:))
      hold on
      legend_names{sid} = sprintf('Stack %d', sid);
    end
    % Plot Average
    limits = linspace(double(prctile(all_Values(:),0.5)),double(prctile(all_Values(:),99.5)),100);
    [f,xi] = ksdensity(all_Values,limits);
    plot(xi,f,'r','LineWidth',1.5)
    legend_names{length(legend_names)+1} = 'Average';

    % Style
    set(gca,'FontSize',20);
    set(gca,'Color',[1 1 1 ]);
    set(gcf,'Color',[1 1 1 ]);
    title(type_namemap(typ),'Interpreter','none');
    xlabel(aspect.xlabel, 'Interpreter','none');
    ylabel(aspect.ylabel, 'Interpreter','none');
    set(gca,'TickLength',[0 0])
    axis tight;
    box off;
    legend(legend_names);
    xlim([0 100]);

  end

  % linkaxes(all_axis,'xy');
  h=suptitle(aspect.title)
  set(h,'FontSize',20);
  

  fig_name = ['ksdensity_plot'];
  export_fig([fig_save_path fig_name '.png'],'-m2');
end