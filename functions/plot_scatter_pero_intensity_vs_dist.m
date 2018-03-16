log_msg(sprintf('[%s]: %s', mfilename(), 'Plotting ksdensity distances...'));

TEST_ONE_FIG = true;
TEST_ONE_FIG = false;

type_namemap = containers.Map;
type_namemap('raw') = 'Raw';
type_namemap('decon') = 'Deconvolved';
type_namemap('zoom_raw') = 'Zoomed Raw';
type_namemap('zoom_decon') = 'Zoomed Deconvolved';

n = 0;
aspects = struct();

n = n + 1;
aspects(n).title = 'Area of Single Peroxisomes vs. Distance to Mitochondria';
aspects(n).X = 'PeroArea';
aspects(n).Y = 'Distances';
aspects(n).xlabel = 'Single Peroxisome Area (px)';
aspects(n).ylabel = 'Distance to Nearest Mitochondria (px)';

n = n + 1;
aspects(n).title = 'Mean Intensity of Single Peroxisomes vs. Distance to Mitochondria';
aspects(n).X = 'PeroMeanIntensity';
aspects(n).Y = 'Distances';
aspects(n).xlabel = 'Mean Intensity of Single Peroxisomes (a.u.)';
aspects(n).ylabel = 'Distance to Nearest Mitochondria (px)';

n = n + 1;
aspects(n).title = 'Total Intensity of Single Peroxisomes vs. Distance to Mitochondria';
aspects(n).X = 'PeroTotalIntensity';
aspects(n).Y = 'Distances';
aspects(n).xlabel = 'Total Intensity of Single Peroxisomes (a.u.)';
aspects(n).ylabel = 'Distance to Nearest Mitochondria (px)';

CONTACT_DIST_NM = 200;

for aspect_num=1:length(aspects)
  if TEST_ONE_FIG
    clf('reset')
  else
    figure;
  end
  count = 1;
  aspect = aspects(aspect_num);
  all_axis = [];

  % Loop over stack types
  for typ=fields(s_mid)'
    if ~TEST_ONE_FIG
      ax = subplot(2,2,count);
    end

    count = count+1;
    typ=typ{:};
    num_stacks = length(s_mid.(typ).(aspect.X));
    cmap=cbrewer('qual', 'Set2', num_stacks);
    cmap2=cbrewer('qual', 'Dark2', num_stacks);
    % cmap=cbrewer('qual', 'Dark2', num_stacks);
    legend_names = {};
    all_Values = [];
    medians = [];
    % % Loop over images in this stack
    for sid=1:num_stacks
      X = s_mid.(typ).(aspect.X){sid};
      Y = s_mid.(typ).(aspect.Y){sid};
      all_Values = [all_Values; X(:) Y(:)];
      medians = [medians; median(X) median(Y)];
      ax = plot(X,Y,'o', 'Color', [.6 .6 .6],'MarkerSize', 6,'MarkerFaceColor',cmap(sid,:),'MarkerEdgeColor','w','LineWidth',1);
      hold on
      all_axis = [all_axis ax];


      legend_names{sid} = sprintf('Stack %d', sid);
    end



    % Plot Mean Dots
    for sid=1:length(medians)
      plot(medians(sid,1),medians(sid,2),'o', 'Color', [.6 .6 .6],'MarkerSize', 15,'MarkerFaceColor',cmap2(sid,:),'MarkerEdgeColor','w','LineWidth',1);
      legend_names{length(medians)+sid} = sprintf('Stack %d Median', sid);
    end

    ylims = [prctile(all_Values(:,1),0) prctile(all_Values(:,1),98)];
    xlim(ylims);
    xlims = [prctile(all_Values(:,2),0) prctile(all_Values(:,2),98)];
    ylim(xlims);

    % Style
    set(gca,'FontSize',16);
    set(gca,'Color',[1 1 1 ]);
    set(gcf,'Color',[1 1 1 ]);
    title(type_namemap(typ),'Interpreter','none','FontName','Yu Gothic UI Light');
    xlabel(aspect.xlabel, 'Interpreter','none','FontName','Yu Gothic UI');
    ylabel(aspect.ylabel, 'Interpreter','none','FontName','Yu Gothic UI');


    hL=legend(legend_names,'Interpreter','none','FontSize',14);
    newPosition = [.95 0.4 0.01 0.2];
    newUnits = 'normalized';
    set(hL,'Position', newPosition,'Units', newUnits);



    set(gca,'FontSize',16);
    set(gcf,'Color',[1 1 1 ]);
    set(gca,'Color',[.95 .95 .95 ]);
    grid on;
    box off;
    set(gca,'GridAlpha',1);
    set(gca,'GridColor',[1 1 1]);
    set(gca,'LineWidth',1.5);


    % Max smaller tick names;
    Fontsize1 = 12;
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
  
  fig_name = ['6_plot_scatter_pero_intensity_vs_dist_' num2str(aspect_num)];
  export_fig([fig_save_path fig_name '.png'],'-m2');

end