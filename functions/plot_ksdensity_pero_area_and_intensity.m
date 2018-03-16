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
aspects(n).title = 'Area of Single Peroxisomes';
aspects(n).value = 'PeroArea';
aspects(n).xlabel = 'Area of Single Peroxisomes (px)';
aspects(n).ylabel = 'Probability';
aspects(n).average_only = false;

n = n + 1;
aspects(n).title = 'Mean Intesity of Single Peroxisomes';
aspects(n).value = 'PeroMeanIntensity';
aspects(n).xlabel = 'Mean Intesity of Single Peroxisomes (a.u.)';
aspects(n).ylabel = 'Probability';
aspects(n).average_only = false;

% n = n + 1;
% aspects(n).title = 'Total Intensities of Single Peroxisomes';
% aspects(n).value = 'PeroTotalIntensity';
% aspects(n).xlabel = 'Total Intensities of Single Peroxisomes (a.u.)';
% aspects(n).ylabel = 'Probability';
% aspects(n).average_only = false;

% % Double the aspects with average_only logically flipped
% for aspect=aspects
%   aspect.average_only=true;
%   aspects(length(aspects)+1)=aspect
% end

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
    num_stacks = length(s_mid.(typ).(aspect.value));
    cmap=cbrewer('qual', 'Set2', num_stacks);
    % cmap=cbrewer('qual', 'Dark2', num_stacks);
    legend_names = {};
    all_Values = [];
    % Loop over images in this stack
    for sid=1:num_stacks
      Values = s_mid.(typ).(aspect.value){sid};
      all_Values = [all_Values; Values];
      limits = linspace(double(prctile(Values(:),0)),double(prctile(Values(:),100)),80);
      if ~aspect.average_only
        [f,xi] = ksdensity(Values,limits,'Support','positive');
        % cmap_index = round(size(cmap,1)/num_stacks)*z;
        % plot(xi,f,'LineWidth',1,'color',cmap(cmap_index,:))
        plot(xi,f,'LineWidth',1,'color',cmap(sid,:))
        hold on
        legend_names{sid} = sprintf('Stack %d', sid);
      end
    end

    % Plot Average
    if aspect.average_only
      limits = linspace(double(prctile(all_Values(:),0)),double(prctile(all_Values(:),100)),300);
      [f,xi] = ksdensity(all_Values,limits,'Support','positive');
      % [f,xi] = ksdensity(all_Values,limits,'Support','positive','Bandwidth',0.05);
      % [f,xi] = ksdensity(all_Values,limits,'Bandwidth',0.55);
      plot(xi,f,'r','LineWidth',1.6);
      hold on
      legend_names{length(legend_names)+1} = 'All Stacks';
    end


    yyaxis left
    % Style
    set(gca,'FontSize',16);
    set(gca,'Color',[1 1 1 ]);
    set(gcf,'Color',[1 1 1 ]);
    title(type_namemap(typ),'Interpreter','none','FontName','Yu Gothic UI Light');
    xlabel(aspect.xlabel, 'Interpreter','none','FontName','Yu Gothic UI');
    ylabel(aspect.ylabel, 'Interpreter','none','FontName','Yu Gothic UI');
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
    h=histogram(all_Values,'NumBins',30);
    legend_names{length(legend_names)+1} = 'Histogram';
    alpha .1;
    ylabel('Bin Count','FontName','Yu Gothic UI');
    % h.FaceColor = [0 0.5 0.5];
    h.EdgeColor = [.4 .4 .4];
    h.LineWidth = 1.3;
    xlims = xlim;
    for idx=1:length(h.Values)
      bin_count = h.Values(idx);
      bin_center = (h.BinEdges(idx) + h.BinEdges(idx+1)) / 2;
      if bin_center > 70
        break
      end
    end


    hL = legend(legend_names,'FontSize',14);
    c=get(gca,'Children'); %Get the handles for the child objects from the current axes
    set(gca,'Children',flipud(c)); %Invert the order of the objects




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
  
  if SAVE_TO_DISK
    fig_name = ['4_ksdensity_plot_pero_area_and_intensity_' num2str(aspect_num)];
    export_fig([fig_save_path fig_name '.png'],'-m2');
  end
end