log_msg(sprintf('[%s]: %s', mfilename(), 'Plotting ksdensity distances...'));

type_namemap = containers.Map;
type_namemap('raw') = 'Raw';
type_namemap('decon') = 'Deconvolved';
type_namemap('zoom_raw') = 'Zoomed Raw';
type_namemap('zoom_decon') = 'Zoomed Deconvolved';
type_names = {'Raw', 'Deconvolved', 'Zoomed Raw', 'Zoomed Deconvolved'};

n = 0;
aspects = struct();
n = n + 1;
aspects(n).title = 'Total Mitochondria Area / Total Peroxisome Area';
aspects(n).value = 'NumPero';
aspects(n).ylabel = 'Area Ratio (px)';

for aspect_num=1:length(aspects)
  figure;
  count = 1;
  aspect = aspects(aspect_num);

  all_axis = [];
  means = [];
  cmap=cbrewer('qual', 'Set2', num_stacks);


  bar_data = [];
  legend_names = {};

  % Loop over stack types
  for typ=fields(s_mid)'
    typ=typ{:};
    PeroArea_Sums_PerType = cellfun(@sum,s_mid.(typ).PeroArea);
    MitoArea_Sums_PerType = cellfun(@sum,s_mid.(typ).MitoArea);
    Values = MitoArea_Sums_PerType./PeroArea_Sums_PerType;
    bar_data(count,:) = Values;
    legend_names{length(legend_names)+1} = type_namemap(typ);
    means = [means mean(Values)];

    count = count+1;
  end
  
  bh = bar(bar_data);
  for n=1:length(bh)
    set(get(get(bh(n),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  end
  hold on

  for cid=1:length(cmap)
    set(bh(cid), 'LineWidth',0.1,'FaceColor',cmap(cid,:),'EdgeColor',cmap(cid,:));
  end


  % Plot Average
  for n=1:length(means)
    % xlims = xlim;
    plot([n-0.5 n+0.5], [means(n) means(n)],'r','LineWidth',.75);
    % legend_names{length(legend_names)+1} = 'Mean';
  end

  % Style
  set(gca,'FontSize',20);
  set(gca,'Color',[1 1 1 ]);
  set(gcf,'Color',[1 1 1 ]);
  set(gca,'XTick',[1:4]);
  set(gca,'XTickLabels',type_names);
  ylabel(aspect.ylabel, 'Interpreter','none');
  axis tight;
  set(gca,'TickLength',[0 0])
  box off;
  hL = legend({'Group Mean'});
 
  title(aspect.title,'Interpreter','none');

  fig_name = ['5_plot_bar_grouped_by_type_mtotal_div_ptotal_'];
  export_fig([fig_save_path fig_name '.png'],'-m2');

end