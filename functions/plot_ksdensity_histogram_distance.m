log_msg(sprintf('[%s]: %s', mfilename(), 'Plotting ksdensity distances...'));


%TEST_ONE_FIG = false;

type_namemap = containers.Map;
type_namemap('raw') = 'Raw';
type_namemap('decon') = 'Deconvolved';
type_namemap('zoom_raw') = 'Zoomed Raw';
type_namemap('zoom_decon') = 'Zoomed Deconvolved';

n = 0;
aspects = struct();

% % Average Ksdensity Line Only 
% n = n + 1;
% aspects(n).title = 'Peroxisome Distance to Mitochondria';
% aspects(n).value = 'Distances';
% aspects(n).xlabel = 'Distance Peroxisome to Nearest Mitochondria';
% aspects(n).ylabel = 'Probability';
% aspects(n).average_only = true;

% Ksdensity Line for each stack 
n = n + 1;
aspects(n).title = 'Peroxisome Distance to Mitochondria';
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
    pause(.1)
    if ~TEST_ONE_FIG
      ax = subplot(2,2,count);
    end

    count = count+1;
    typ=typ{:};


    if strfind(typ,'zoom')
      scale_factor = 48; % nm per pixel
    else
      scale_factor = 90; % nm per pixel
    end
    CONTACT_DIST_PX = CONTACT_DIST_NM/scale_factor;
    hold on

    num_stacks = length(s_mid.(typ).(aspect.value));
    % cmap=cbrewer('qual', 'Set2', num_stacks);
    cmap=cbrewer('qual', 'Dark2', num_stacks);
    legend_names = {};
    all_Values = [];
    % Loop over images in this stack
    for sid=1:num_stacks
      Values = s_mid.(typ).(aspect.value){sid};
      if isempty(Values)
          continue
      end
      all_Values = [all_Values Values];
      limits = linspace(double(prctile(Values(:),0)),double(prctile(Values(:),99.5)),300);
      if ~aspect.average_only
        [f,xi] = ksdensity(Values+1/9e9,limits,'Support','positive','BoundaryCorrection','reflection','Bandwidth',0.55);
        % cmap_index = round(size(cmap,1)/num_stacks)*z;
        % plot(xi,f,'LineWidth',1,'color',cmap(cmap_index,:))
        plot(xi,f,'LineWidth',1,'color',cmap(sid,:))
        hold on
        legend_names{length(legend_names)+1} = sprintf('Stack %d (n_peroxisomes=%d)', sid, length(Values));
      end
    end

    % Plot Average
    % if aspect.average_only & ~isempty(all_Values)
      limits = linspace(double(prctile(all_Values(:),0)),double(prctile(all_Values(:),99.5)),300);
      [f,xi] = ksdensity(all_Values+1/9e9,limits,'Support','positive','BoundaryCorrection','reflection','Bandwidth',0.55);
      % [f,xi] = ksdensity(all_Values,limits,'Bandwidth',0.55,'Support','positive');
      plot(xi,f,'r','LineWidth',1.2)
      hold on
      legend_names{length(legend_names)+1} = 'Avg. Kernel Density Estimate ';
    % end


    yyaxis left
    % Style
    set(gca,'FontSize',16);
    set(gca,'Color',[1 1 1 ]);
    set(gcf,'Color',[1 1 1 ]);
    xlabel(aspect.xlabel, 'Interpreter','none','FontName','Yu Gothic UI');
    ylabel(aspect.ylabel, 'Interpreter','none','FontName','Yu Gothic UI');
    % set(gca,'TickLength',[0 0])
    box off;


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
    h=histogram(all_Values,0:45);
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    % legend_names{length(legend_names)+1} = 'Histogram';
    alpha .15;
    ylabel('Bin Count','FontName','Yu Gothic UI');
    % h.FaceColor = [0 0.5 0.5];
    h.EdgeColor = [.4 .4 .4];
    h.LineWidth = 1.3;
    bin_edges = h.BinEdges;

    xlims = xlim;
    for idx=1:length(h.Values)
      bin_count = h.Values(idx);
      bin_center = (h.BinEdges(idx) + h.BinEdges(idx+1)) / 2;
      text(bin_center, bin_count+max(ylim)*.03, num2str(bin_count),'Color',[.1 .1 .1],'FontSize',10,'FontName','Yu Gothic UI Light','HorizontalAlignment','center');
    end


    % CONTACT THRESHOLD LINE
    thresh_fig=plot([CONTACT_DIST_PX CONTACT_DIST_PX],[0 max(ylim)],'--r', 'LineWidth', 2.1);
    legend_names{length(legend_names)+1} = sprintf('Contact Thresh (%dnm, %.2fpx)', CONTACT_DIST_NM,CONTACT_DIST_PX);


    num_in_contact = sum(all_Values<=CONTACT_DIST_PX);
    num_out_contact = sum(all_Values>CONTACT_DIST_PX);
    num_pero = num_in_contact + num_out_contact;
    num_in_contact_percent = num_in_contact / num_pero * 100;
    num_out_contact_percent = num_out_contact / num_pero * 100;

    % Draw shaded box for incontact region
    x = [0 CONTACT_DIST_PX CONTACT_DIST_PX 0];
    y = [0 0 max(ylim) max(ylim)];
    ph = patch(x,y,[.3 1 0]);
    PATCH_ALPHA = 0.07;
    ph.FaceAlpha=PATCH_ALPHA;
    ph.EdgeAlpha=0;
    legend_names{length(legend_names)+1} = sprintf('In Contact (n=%d, %.0f%%)', num_in_contact, num_in_contact_percent);
    txt = sprintf('%.0f%%',num_in_contact_percent);
    % text(CONTACT_DIST_PX-max(xlim)*.022, max(ylim)*.97, txt,'Color',[.1 .1 .1],'FontSize',14,'FontName','Yu Gothic UI Light','HorizontalAlignment','center');

    % Draw shaded box for out-of-contact region
    x = [CONTACT_DIST_PX max(xlim) max(xlim) CONTACT_DIST_PX];
    y = [0 0 max(ylim) max(ylim)];
    ph = patch(x,y,[.6 0 1]);
    PATCH_ALPHA = 0.07;
    ph.FaceAlpha=PATCH_ALPHA;
    ph.EdgeAlpha=0;
    legend_names{length(legend_names)+1} = sprintf('Out of Contact (n=%d, %.0f%%)', num_out_contact, num_out_contact_percent);
    txt = sprintf('%.0f%% Out of Contact',num_out_contact_percent);
    text(CONTACT_DIST_PX+.25, max(ylim)*.97, txt,'Color',[.1 .1 .1],'FontSize',14,'FontName','Yu Gothic UI Light','HorizontalAlignment','left');


    %% Legend
    [BL,BLicons] = legend(legend_names,'FontSize',14,'Interpreter','none');
    % Fix patch transparences to match the actual patches. NOT WORKING
    PatchInLegend = findobj(BLicons, 'type', 'patch');
    set(PatchInLegend, 'facea', PATCH_ALPHA);
    % [BL,BLicons] = legend(legend_names,'FontSize',14);

    %% Invert the order of the objects
    c=get(gca,'Children'); %Get the handles for the child objects from the current axes
    set(gca,'Children',flipud(c)) %Invert the order of the objects

    % Set x values in nanometers
    xticks(bin_edges);
    ticklabels_um=sprintfc('%.2fum',bin_edges.*scale_factor./1000);
    ticklabels_px=sprintfc('%dpx',bin_edges);
    ticklabels = strcat(ticklabels_um," ", ticklabels_px);
    xticklabels(ticklabels(1:2:end));
    xticks(bin_edges(1:2:end));
    xtickangle(-45);
    set(gca,'TickLabelInterpreter','none');

    xlim([0 45]);
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
    

    title_ = sprintf('%s (n_stacks=%d, n_peroxisomes=%d)',type_namemap(typ), length(legend_names)-4, num_pero);
    title(title_,'Interpreter','none','FontName','Yu Gothic UI Light');
    

    % pos=get(gca,'Position');
    % set(gca,'Position',[pos(1) pos(2)    0.3266    0.3220]);

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
    fig_name = ['4_ksdensity_plot_with_histogram_' num2str(aspect_num)];
    export_fig([fig_save_path fig_name '.png'],'-m2');
  end
end