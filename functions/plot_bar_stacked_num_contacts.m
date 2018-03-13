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
aspects(n).title = 'Number of Contacts';
aspects(n).value = 'Distances';
aspects(n).ylabel_left = 'Number of Contacts';
aspects(n).ylabel_right = 'Median Distance';

for aspect_num=1:length(aspects)
  aspect = aspects(aspect_num);
  count = 1;
  means = [];
  medians = [];
  counts = [];
  bar_data = [];
  legend_names = {'In Contact','Out of Contact'};

  % fig = figure(2);
  clf('reset')

  cmap=cbrewer('seq', 'PuBu', 2);
  cmap=[cmap(2,:); cmap(1,:)];
  left_color = [.1 .1 0];
  right_color = [0 .5 .5];
  % set(gcf,'defaultAxesColorOrder',[cmap(1,:).*.8; right_color]);



  % Loop over stack types
  for typ=fields(s_mid)'
    typ=typ{:};
    num_stacks = length(s_mid.(typ).(aspect.value));
    Values = cell2mat(s_mid.(typ).(aspect.value));
    means = [means mean(Values)];
    medians = [medians median(Values)];
    counts = [counts length(Values)];
    not_touching_count = sum(Values > 3);
    touching_count = length(Values) - not_touching_count;
    Values = [touching_count not_touching_count];
    bar_data(count,:) = Values;

    count = count+1;
  end
  
  yyaxis left
  bh = bar(bar_data,'stacked');
  hold on
  % for n=1:length(bh)
  % end
  ylabel(aspect.ylabel_left, 'Interpreter','none');

  for cid=1:length(bh)
    set(bh(cid), 'LineWidth',2,'FaceColor',cmap(cid,:),'EdgeColor',cmap(cid,:).*.6);
  end

  % Put count of each type at top
  for n=1:length(counts)
    txt = sprintf('n = %d', counts(n));
    x=n
    y=sum(bar_data(n,:))-35
    h = text(x, y,txt,'Color',[.1 .1 .1],'FontSize',12,'FontName','Yu Gothic UI Light','HorizontalAlignment','center');

  end

  % Plot Average (using a right side y axis)
  yyaxis right 
  % for n=1:length(means)
  %   h = plot([n-0.5 n+0.5], [means(n) means(n)],'-','Color',right_color,'LineWidth',2);
  %   if n>1
  %     set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  %   end
  % end
  % legend_names{length(legend_names)+1} = 'Mean Distance';

  for n=1:length(medians)
    % h = plot([n-0.5 n+0.5], [medians(n) medians(n)],'-','Color',right_color+.2,'LineWidth',2); % special color
    h = plot([n-0.4 n+0.4], [medians(n) medians(n)],'-r','Color',[ 0.8500    0.3250    0.0980],'LineWidth',2);
    if n>1
      set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
  end
  legend_names{length(legend_names)+1} = 'Median Distance';

  % Style
  set(gca,'FontSize',20);
  set(gcf,'Color',[1 1 1 ]);
  set(gca,'Color',[.95 .95 .95 ]);
  grid on
  axis equal;
  % set(gca,'TickLength',[0 0])
  box off;
  set(gca,'GridAlpha',1);
  set(gca,'GridColor',[1 1 1]);
  set(gca,'LineWidth',2);
  hL = legend(legend_names);
  set(gca,'XTickLabels',type_names);

  ylim([0 max(means(:)*2)]);

  title(aspect.title,'Interpreter','none');

  % Set y values in nanometers
  yt=yticks;
  a=sprintfc('%dpx',yt);
  c=sprintfc('%.2fnm',yt.*1/48);
  b=sprintfc('%.2fnm(zoom)',yt.*1/90);
  a = strcat(a, ", ", c);
  a = strcat(a, ", ", b);
  ticklabels = cellstr(a);
  yticklabels(ticklabels);
  set(gca,'TickLabelInterpreter','none');
  ytickangle(-45);

  Fontsize2 = 10;
  ylabel(aspect.ylabel_right, 'Interpreter','none');
  xl = get(gca,'YLabel');
  xlFontSize = get(xl,'FontSize')
  xAY = get(gca,'YAxis');
  set(xAY,'FontSize', Fontsize2)
  set(xl, 'FontSize', xlFontSize);
  yyaxis left
  xl = get(gca,'YLabel');
  xAY = get(gca,'YAxis');
  set(xl, 'FontSize', xlFontSize);
 
  % axes;
  xlabel('Experiment')
  Fontsize1 = 15;
  xl = get(gca,'XLabel');
  xlFontSize = get(xl,'FontSize');
  xAX = get(gca,'XAxis');
  set(xAX,'FontSize', Fontsize1)
  set(xl, 'FontSize', xlFontSize);





  fig_name = ['bar_plot'];
  %export_fig([fig_save_path fig_name '.png'],'-m2');

end