log_msg(sprintf('[%s]: %s', mfilename(), 'Plotting ksdensity distances...'));

% TEST_ONE_FIG = true;
% TEST_ONE_FIG = false;

type_namemap = containers.Map;
type_namemap('raw') = 'Raw';
type_namemap('decon') = 'Deconvolved';
type_namemap('zoom_raw') = 'Zoomed Raw';
type_namemap('zoom_decon') = 'Zoomed Deconvolved';

n = 0;
aspects = struct();

% Average Ksdensity Line Only 
n = n + 1;
aspects(n).title = 'Peroxisome Distance to Mitochondria (Scaled Histogram Bins)';
aspects(n).value = 'Distances';
aspects(n).xlabel = 'Distance Peroxisome to Nearest Mitochondria';
aspects(n).ylabel = 'Probability';
aspects(n).average_only = true;

% Ksdensity Line for each stack 
n = n + 1;
aspects(n).title = 'Peroxisome Distance to Mitochondria (Scaled Histogram Bins)';
aspects(n).value = 'Distances';
aspects(n).xlabel = 'Distance Peroxisome to Nearest Mitochondria';
aspects(n).ylabel = 'Probability';
aspects(n).average_only = false;


for aspect_num=1:length(aspects)
  if TEST_ONE_FIG
    figure;
    clf('reset')
  else
    figure;
  end
  count = 1;
  aspect = aspects(aspect_num);
  all_axis = [];

  % Loop over stack types
  for typ=fields(s_mid)'
    typ=typ{:};

    if strfind(typ,'zoom')
      scale_factor = 48; % nm per pixel
    else
      scale_factor = 90; % nm per pixel
    end
    
    if ~TEST_ONE_FIG
      ax = subplot(2,2,count);
    end
    count = count+1;

    num_stacks = length(s_mid.(typ).(aspect.value));
    cmap=cbrewer('qual', 'Set2', num_stacks);
    % cmap=cbrewer('qual', 'Dark2', num_stacks);
    legend_names = {};
    all_Values = [];
    % Loop over images in this stack
    for sid=1:num_stacks
      Values = s_mid.(typ).(aspect.value){sid};
      all_Values = [all_Values Values];
      limits = linspace(double(prctile(Values(:),0)),double(prctile(Values(:),99.5)),300);
      if ~aspect.average_only
        [f,xi] = ksdensity(Values+1/9e9,limits,'Support','positive','BoundaryCorrection','reflection','Bandwidth',0.55);
        % cmap_index = round(size(cmap,1)/num_stacks)*z;
        % plot(xi,f,'LineWidth',1,'color',cmap(cmap_index,:))
        plot(xi,f,'LineWidth',1,'color',cmap(sid,:))
        hold on
        legend_names{sid} = sprintf('Stack %d', sid);
      end
    end

    % Plot Average
    if aspect.average_only
      limits = linspace(double(prctile(all_Values(:),0)),double(prctile(all_Values(:),99.5)),300);
      [f,xi] = ksdensity(all_Values+1/9e9,limits,'Support','positive','BoundaryCorrection','reflection','Bandwidth',0.55);
      % [f,xi] = ksdensity(all_Values,limits,'Bandwidth',0.55,'Support','positive');
      plot(xi,f,'r','LineWidth',1.6)
      hold on
      legend_names{length(legend_names)+1} = 'All Stacks';
    end


    yyaxis left
    % Style
    set(gca,'FontSize',16);
    set(gca,'Color',[1 1 1 ]);
    set(gcf,'Color',[1 1 1 ]);
    title(type_namemap(typ),'Interpreter','none','FontName','Yu Gothic UI Light');
    xlabel(aspect.xlabel, 'Interpreter','none'),'FontName','Yu Gothic UI';
    ylabel(aspect.ylabel, 'Interpreter','none'),'FontName','Yu Gothic UI';
    % set(gca,'TickLength',[0 0])
    box off;
    legend(legend_names,'Interpreter','none');


    set(gca,'FontSize',16);
    set(gcf,'Color',[1 1 1 ]);
    set(gca,'Color',[.95 .95 .95 ]);
    grid on;
    axis equal;
    box off;
    set(gca,'GridAlpha',1);
    set(gca,'GridColor',[1 1 1]);
    set(gca,'LineWidth',1.5);


    yyaxis right;
    h=histogram(all_Values,'BinWidth',1);
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    h.Visible = 'off';
    xlims = xlim;
    bin_counts = h.Values./length(all_Values);
    bin_centers = [];
    bin_edges = h.BinEdges;
    for idx=1:length(h.Values)
      bin_count = h.Values(idx)/length(all_Values);
      bin_center = (h.BinEdges(idx) + h.BinEdges(idx+1)) / 2;
      %bin_counts = [bin_counts bin_count];
      %bin_centers = [bin_centers bin_center];
      
      if bin_center > 70
        break
      end
      % if bin_count == 0
      %   break
      % end

      % text(bin_center, bin_count+max(ylim)*.018, sprintf('%.2f',bin_count),'Color',[.1 .1 .1],'FontSize',12,'FontName','Yu Gothic UI Light','HorizontalAlignment','center');
    end

    h=histogram('BinEdges',bin_edges,'BinCounts',bin_counts)
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    hold on
    alpha .1;
    ylabel('Bin Count \div Total Count','Interpreter','tex','FontName','Yu Gothic UI')
    h.FaceColor = [0 0.5 0.5];
    h.EdgeColor = [.4 .4 .4];
    h.LineWidth = 1.3;
    


    thresh_fig=plot([CONTACT_DIST_NM/scale_factor CONTACT_DIST_NM/scale_factor],[0 max(ylim)],'--r', 'LineWidth', 2.1);
    legend_names{length(legend_names)+1} = sprintf('Contact Threshold (%dnm, %.2fpx)', CONTACT_DIST_NM,CONTACT_DIST_NM/scale_factor);

    hL = legend(legend_names,'FontSize',14);
    c=get(gca,'Children'); %Get the handles for the child objects from the current axes
    set(gca,'Children',flipud(c)) %Invert the order of the objects


    % Set x values in nanometers
    xticks(bin_edges);
    ticklabels_um=sprintfc('%.2fum',bin_edges.*scale_factor./1000);
    ticklabels_px=sprintfc('%dpx',bin_edges);
    ticklabels = strcat(ticklabels_um," ", ticklabels_px);
    xticklabels(ticklabels);
    xtickangle(-45);
    set(gca,'TickLabelInterpreter','none');

    % xlim([0 70]);
    % Max smaller tick names;
    Fontsize1 = 10;
    xl = get(gca,'XLabel');
    xlFontSize = get(xl,'FontSize');
    xAX = get(gca,'XAxis');
    set(xAX,'FontSize', Fontsize1);
    set(xl, 'FontSize', xlFontSize);
    % Max smaller tick names;

    Fontsize2 = 12;
    xl = get(gca,'YLabel');
    xlFontSize = get(xl,'FontSize');
    xAY = get(gca,'YAxis');
    set(xAY,'FontSize', Fontsize2);
    set(xl, 'FontSize', xlFontSize);
    yyaxis left
    xl = get(gca,'YLabel');
    xAY = get(gca,'YAxis');
    set(xl, 'FontSize', xlFontSize);
    



    if TEST_ONE_FIG
      break
    end
  end
  if TEST_ONE_FIG
    break
  end

  h=suptitle(aspect.title);
  set(h,'FontSize',20,'FontName','Yu Gothic UI');
  
  fig_name = ['4_ksdensity_plot_with_histogram_scaled_' num2str(aspect_num)];
  if ~TEST_ONE_FIG
   export_fig([fig_save_path fig_name '.png'],'-m2');
  end
end