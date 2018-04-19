
n = 0;
aspects = struct();
n = n + 1;
aspects(n).title = {sprintf('Percentage of Peroxisomes in Contact'),''};
aspects(n).ylabel_left = '% In Contact';
aspects(n).ylabel_right = 'Contact Dwell Time (timepoints)';


for aspect_num=1:length(aspects)
  aspect = aspects(aspect_num);
  count = 1;
  means = [];
  medians = [];
  percent_out_of_contact = [];
  bar_data = [];
  legend_names = {['In Contact (within 1 px )'],'Out of Contact'};

  fig = figure;
  subplot(1,2,1)

  % clf('reset')

  cmap=cbrewer('seq', 'PuBu', 2);
  cmap=[cmap(2,:); cmap(1,:)];
  left_color = [.1 .1 0];
  right_color = [0 .5 .5];
  % set(gcf,'defaultAxesColorOrder',[cmap(1,:).*.8; right_color]);


  % Loop over stack types
  for cell_id=1:length(all_contact_durations)
    Values = all_in_contact_bool{cell_id};
    not_touching_count = length(Values);
    touching_count = sum(Values);
    percent_out_of_contact = not_touching_count/(not_touching_count + touching_count)*100 ;
    bar_data(count) = 100-percent_out_of_contact;

    count = count+1;
  end

  % Plot bars
  bh = bar(bar_data,'stacked');
  set(get(get(bh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  hold on


  %% Plot scatter
  yyaxis right
  for cell_id=1:length(all_contact_durations)
    % x = zeros(length(all_contact_durations{cell_id}))+cell_id;  % ex. 1,1,1,1,1
    x=-1/4+cell_id+rand(length(all_contact_durations{cell_id}),1)/1.7;
    y=all_contact_durations{cell_id} + rand(length(all_contact_durations{cell_id}),1)'*.15;
    h = plot(x,y,'o', 'Color', [.6 .6 .6],'MarkerSize', 15,'MarkerFaceColor',[.9 .9 .9],'MarkerEdgeColor', [205/255 94/255 39/255],'LineWidth',2);
    for hh=h'
      set(get(get(hh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    h = plot(cell_id,mean(all_contact_durations{cell_id}),'x', 'Color', [.6 .6 .6],'MarkerSize', 15,'MarkerFaceColor',[.9 .9 .9],'MarkerEdgeColor', [1 0 0],'LineWidth',2);
    h = plot(cell_id,median(all_contact_durations{cell_id}),'+', 'Color', [.6 .6 .6],'MarkerSize', 15,'MarkerFaceColor',[.9 .9 .9],'MarkerEdgeColor', [1 0 0],'LineWidth',2);
    h = plot(cell_id,mode(all_contact_durations{cell_id}),'p', 'Color', [.6 .6 .6],'MarkerSize', 15,'MarkerFaceColor',[.9 .9 .9],'MarkerEdgeColor', [1 0 0],'LineWidth',2);
  end




  yyaxis left
  ylabel(aspect.ylabel_left, 'Interpreter','none','FontName','Yu Gothic UI');

  % Set Style for bars
  for cid=1:length(bh)
    yyaxis left
    set(bh(cid), 'LineWidth',2,'FaceColor',cmap(cid,:),'EdgeColor',cmap(cid,:).*.6);
  end

  % Put count of each type at top
  for n=1:length(bar_data)
    yyaxis left

    x=n
    % h = text(x, y,txt,'Color',[.1 .1 .1],'FontSize',14,'FontName','Yu Gothic UI Light','HorizontalAlignment','center');
    % Lower bar percentage
    txt = sprintf('%.3g%%', bar_data(n));
    v_offset = max(ylim)*.02
    h = text(x, bar_data(n)+v_offset,txt,'Color',[.1 .1 .1],'FontSize',20,'FontName','Yu Gothic UI','HorizontalAlignment','center');
    % uistack(h, 'top')
    CellTable = ResultsTable(ResultsTable.CellNum==n,:);
    total_pero = height(CellTable);
    unique_pero = length(unique(CellTable.Trace));
    total_contacts = sum(all_in_contact_bool{n});
    unique_contacts = length(all_contact_durations{n});
    txt = sprintf(['unique pero = %d\n' ...
                  'total pero = %d\n' ...
                  'unique contacts = %d\n' ...
                  'total contacts = %d\n'], ...
                  unique_pero, total_pero, unique_contacts, total_contacts);
    h = text(x, 0,txt,'Color',[.1 .1 .1],'FontSize',12,'FontName','Yu Gothic UI Light','HorizontalAlignment','center','Interpreter','none','VerticalAlignment','top');
    % uistack(h, 'top')

    % Median line
    % txt = sprintf('median=%.0fnm', medians(n));
    % h = text(x, medians(n)+10,txt,'Color',[1 .125 .05],'FontSize',14,'FontName','Yu Gothic UI Light','HorizontalAlignment','center');
    % % Mean line
    % txt = sprintf('mean=%.0fnm', means(n));
    % h = text(x, means(n)+10,txt,'Color',[1 .125 .05],'FontSize',14,'FontName','Yu Gothic UI Light','HorizontalAlignment','center');
  end

  yyaxis right 
  yticklabels(yticks())


  % Style
  set(gca,'FontSize',20);
  set(gcf,'Color',[1 1 1 ]);
  set(gca,'Color',[.95 .95 .95 ]);
  grid on
  % axis equal;
  % set(gca,'TickLength',[0 0])
  box off;
  set(gca,'GridAlpha',1);
  set(gca,'GridColor',[1 1 1]);
  set(gca,'LineWidth',2);
  legend_names = {'Mean', 'Median', 'Mode'};
  hL = legend(legend_names);
  % set(gca,'XTickLabels',type_names);
  

  % ylim([0 max(means(:)*2)]);

  title(aspect.title,'Interpreter','none','FontName','Yu Gothic UI Light');
  % text(.5,1.08,'within 1 px of Mitochondria at any given time.','FontSize', 17, 'FontName','Yu Gothic UI Light','HorizontalAlignment', 'center', 'Units','normalized', 'Interpreter','none');
  text(.5,1.025,'within 1 px of Mitochondria at any given time.','FontSize', 17, 'FontName','Yu Gothic UI Light','HorizontalAlignment', 'center', 'Units','normalized', 'Interpreter','none');

  yyaxis left
  yt=yticks
  ticklabels=sprintfc('%g%%',yt)
  yticklabels(ticklabels);
  set(gca,'TickLabelInterpreter','none');
  yyaxis right

  yt=yticks
  ticklabels=sprintfc('%g',yt)
  yticklabels(ticklabels);
  set(gca,'TickLabelInterpreter','none');


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
  xlabel({'','','Cells'},'FontName','Yu Gothic UI');
  Fontsize1 = 15;
  xl = get(gca,'XLabel');
  xlFontSize = get(xl,'FontSize');
  xAX = get(gca,'XAxis');
  set(xAX,'FontSize', Fontsize1)
  set(xl, 'FontSize', xlFontSize);
  xticklabels([])

  if SAVE_TO_DISK
    fig_name = ['/3_bar_scatter_contact'];
    export_fig([fig_save_path fig_name '.png'],SAVE_FIG_MAG);
  end

  % Save summary stats
  iterPeroSummaryTable = table();
  iterPeroSummaryTable.CellNum = stack_id;
  iterPeroSummaryTable.ImageProcessingType = {IMAGE_PROCESSING_TYPE};
  iterPeroSummaryTable.total_pero = total_pero;
  iterPeroSummaryTable.unique_pero = unique_pero;
  iterPeroSummaryTable.total_contacts = total_contacts;
  iterPeroSummaryTable.unique_contacts = unique_contacts;
  PeroSummaryTable = [PeroSummaryTable; iterPeroSummaryTable];

end
