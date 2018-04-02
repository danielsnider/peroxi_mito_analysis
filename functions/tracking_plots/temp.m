
n = 0;
aspects = struct();
n = n + 1;
aspects(n).title = sprintf('Number of Peroxisomes within 1 px of Mitochondria');
aspects(n).ylabel_left = 'Number of Contacts';
aspects(n).ylabel_right = 'Distance (px)';


for aspect_num=1:length(aspects)
  aspect = aspects(aspect_num);
  count = 1;
  means = [];
  medians = [];
  percent_out_of_contact = [];
  bar_data = [];
  legend_names = {['In Contact (within 1 px )'],'Out of Contact'};

  fig = figure;
  % clf('reset')

  cmap=cbrewer('seq', 'PuBu', 2);
  cmap=[cmap(2,:); cmap(1,:)];
  left_color = [.1 .1 0];
  right_color = [0 .5 .5];
  % set(gcf,'defaultAxesColorOrder',[cmap(1,:).*.8; right_color]);


  % Loop over stack types
  for cell_id=1:size(all_contact_durations,1)
    Values = all_in_contact_bool{cell_id};
    % if strfind(typ,'zoom') 
    %   scale_factor = 48; % nm per pixel
    % else
    %   scale_factor = 90; % nm per pixel
    % end
    % Values = Values .* scale_factor;
    means = [means mean(Values)];
    medians = [medians median(Values)];
    not_touching_count = length(Values);
    touching_count = sum(Values);
    percent_out_of_contact = [percent_out_of_contact not_touching_count/(not_touching_count + touching_count)*100 ];
    Values = [touching_count not_touching_count];
    bar_data(count,:) = Values;

    count = count+1;
  end

  yyaxis left
  
  bh = bar(bar_data,'stacked');
  hold on

  ylabel(aspect.ylabel_left, 'Interpreter','none','FontName','Yu Gothic UI');

  % Set Style for bars
  for cid=1:length(bh)
    set(bh(cid), 'LineWidth',2,'FaceColor',cmap(cid,:),'EdgeColor',cmap(cid,:).*.6);
  end

  % Put count of each type at top
  for n=1:length(percent_out_of_contact)
    yyaxis left
    txt = sprintf('%.0f%%', percent_out_of_contact(n));
    x=n
    y=sum(bar_data(n,:))-15
    h = text(x, y,txt,'Color',[.1 .1 .1],'FontSize',14,'FontName','Yu Gothic UI Light','HorizontalAlignment','center');
    % Lower bar percentage
    txt = sprintf('%.0f%%', 100-percent_out_of_contact(n));
    h = text(x, y-bar_data(n,2),txt,'Color',[.1 .1 .1],'FontSize',14,'FontName','Yu Gothic UI Light','HorizontalAlignment','center');

    % Median line
    yyaxis right
    txt = sprintf('median=%.0fnm', medians(n));
    h = text(x, medians(n)+10,txt,'Color',[1 .125 .05],'FontSize',14,'FontName','Yu Gothic UI Light','HorizontalAlignment','center');
    % Mean line
    txt = sprintf('mean=%.0fnm', means(n));
    h = text(x, means(n)+10,txt,'Color',[1 .125 .05],'FontSize',14,'FontName','Yu Gothic UI Light','HorizontalAlignment','center');
  end

  % Plot Average (using a right side y axis)
  yyaxis right 
  for n=1:length(medians)
    % h = plot([n-0.5 n+0.5], [medians(n) medians(n)],'-','Color',right_color+.2,'LineWidth',2); % special color
    h = plot([n-0.4 n+0.4], [medians(n) medians(n)],'-r','Color',[.85 .325 .098],'LineWidth',2);
    if n>1
      set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
  end
  for n=1:length(means)
    % h = plot([n-0.5 n+0.5], [means(n) means(n)],'-','Color',right_color+.2,'LineWidth',2); % special color
    h = plot([n-0.4 n+0.4], [means(n) means(n)],'--r','Color',[.85 .325 .098],'LineWidth',2);
    if n>1
      set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
  end
  legend_names{length(legend_names)+1} = 'Median Distance';
  legend_names{length(legend_names)+1} = 'Mean Distance';

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
  % set(gca,'XTickLabels',type_names);
  

  ylim([0 max(means(:)*2)]);

  title(aspect.title,'Interpreter','none','FontName','Yu Gothic UI Light');

  % Set y values in nanometers
  % yt=yticks;
  % a=sprintfc('%dpx',yt);
  % c=sprintfc('%.2fnm',yt.*1/48);
  % b=sprintfc('%.2fnm(zoom)',yt.*1/90);
  % a = strcat(a, ", ", c);
  % a = strcat(a, ", ", b);
  % ticklabels = cellstr(a);
  % yticklabels(ticklabels);
  % set(gca,'TickLabelInterpreter','none');
  % ytickangle(-45);
  yt=yticks;
  ticklabels=sprintfc('%dnm',yt);
  yticklabels(ticklabels);
  set(gca,'TickLabelInterpreter','none');
  % ytickangle(-45);

  % Make smaller tick names;
  Fontsize2 = 15;
  ylabel(aspect.ylabel_right, 'Interpreter','none','FontName','Yu Gothic UI');
  xl = get(gca,'YLabel');
  xlFontSize = get(xl,'FontSize')
  xAY = get(gca,'YAxis');
  set(xAY,'FontSize', Fontsize2)
  set(xl, 'FontSize', xlFontSize);
  yyaxis left
  xl = get(gca,'YLabel');
  xAY = get(gca,'YAxis');
  set(xl, 'FontSize', xlFontSize);
 
  % Make smaller tick names;
  xlabel('Cell','FontName','Yu Gothic UI');
  Fontsize1 = 15;
  xl = get(gca,'XLabel');
  xlFontSize = get(xl,'FontSize');
  xAX = get(gca,'XAxis');
  set(xAX,'FontSize', Fontsize1)
  set(xl, 'FontSize', xlFontSize);




  if SAVE_TO_DISK
    fig_name = ['3_bar_plot_within_contact'];
    export_fig([fig_save_path fig_name '.png'],SAVE_FIG_MAG);
  end
end