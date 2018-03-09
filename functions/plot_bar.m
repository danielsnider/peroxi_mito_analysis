log_msg(sprintf('[%s]: %s', mfilename(), 'Plotting ksdensity distances...'));

type_namemap = containers.Map;
type_namemap('raw') = 'Raw';
type_namemap('decon') = 'Deconvolved';
type_namemap('zoom_raw') = 'Zoomed Raw';
type_namemap('zoom_decon') = 'Zoomed Deconvolved';

n = 0;
aspects = struct();
n = n + 1;
aspects(n).title = 'Number of Peroxisomes';
aspects(n).value = 'NumPero';
aspects(n).xlabel = 'Stack';
aspects(n).ylabel = 'Number of Peroxisomes';

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
      bar(sid,Values,'FaceColor',cmap(sid,:),'EdgeColor',cmap(sid,:),'LineWidth',0.1)
      hold on
      legend_names{sid} = sprintf('Stack %d', sid);
    end

    % Plot Average
    xlims = xlim;
    plot([xlims(1) xlims(2)], [mean(all_Values), mean(all_Values)],'LineWidth',.75);
    legend_names{length(legend_names)+1} = 'Mean';

    % Style
    set(gca,'FontSize',12);
    set(gca,'Color',[1 1 1 ]);
    set(gcf,'Color',[1 1 1 ]);
    set(gca,'XTick',[]);
    set(gca,'XTickLabels',[{}]);
    title(type_namemap(typ),'Interpreter','none');
    xlabel(aspect.xlabel, 'Interpreter','none');
    ylabel(aspect.ylabel, 'Interpreter','none');
    axis tight;
    box off;
    hL = legend(legend_names);
    newPosition = [.908 0.4 0.092 0.2];
    newUnits = 'normalized';
    set(hL,'Position', newPosition,'Units', newUnits);

  end

  linkaxes(all_axis,'xy');
  suptitle(aspect.title)
end