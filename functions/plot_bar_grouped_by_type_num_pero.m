log_msg(sprintf('[%s]: %s', mfilename(), 'Plotting ksdensity distances...'));

n = 0;
aspects = struct();
n = n + 1;
aspects(n).title = 'Number of Peroxisomes';
aspects(n).value = 'NumPero';
aspects(n).ylabel = 'Number of Peroxisomes';

for aspect_num=1:length(aspects)
  figure;
  count = 1;
  aspect = aspects(aspect_num);

  means = [];
  cmap=cbrewer('qual', 'Set2', num_stacks);


  bar_data = [];
  legend_names = {};

  % Loop over stack types
  for typ=fields(s_mid)'
    typ=typ{:};
    Values = cell2mat(s_mid.(typ).(aspect.value));
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

  if SAVE_TO_DISK
    fig_name = ['01_bar_plot_by_type'];
    export_fig([fig_save_path fig_name '.png'],'-m2');
  end
end