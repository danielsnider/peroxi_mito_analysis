stack_name = s.(typ)(sid).stack_name;
stack_id = s.(typ)(sid).stack_id;

%% Distance to nearest Mito
figure('Position',[1 1 1201 809])
subplot(1,2,1)
for trace_id=unique(T.Trace)'
  TraceTable = T(ismember(T.Trace,trace_id),:);
  short_trace_id = TraceTable.TraceShort(1);
  trace_color = TraceTable.TraceColor(1,:);
  Y = TraceTable.Distance;
  X = 1:length(Y); % Timepoints as 1,2,3, etc.
  h=plot(X,Y,'-','Color',trace_color);
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % disable legend
  hold on
end

% ylim([0 10])


% Text for trace ID (on top of lines)
for trace_id=unique(T.Trace)'
  TraceTable = T(ismember(T.Trace,trace_id),:);
  short_trace_id = TraceTable.TraceShort(1);
  trace_color = TraceTable.TraceColor(1,:);
  Y = TraceTable.Distance;
  [max_val, max_pos] = min(Y);
  v_offset = max(ylim)*.015;
  % text(max_pos, max_val+v_offset, short_trace_id, 'Color', 'black', 'FontName','Yu Gothic UI','HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight','bold');
  text(max_pos, max_val+v_offset, short_trace_id, 'Color', trace_color/1.0, 'FontName','Yu Gothic UI','HorizontalAlignment', 'center', 'FontSize', 17, 'FontWeight','bold');
end
% % Thresholds for long, close contant
% h=line([10 10], ylim,'Color','red');
% set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % disable legend
% h=line(xlim, [2 2],'Color','red');
% set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % disable legend
% hL = legend(legend_names);


% Style
set(gca,'FontSize',20);
set(gcf,'Color',[1 1 1 ]);
set(gca,'Color',[.95 .95 .95 ]);
grid on
box off;
set(gca,'GridAlpha',1);
set(gca,'GridColor',[1 1 1]);
set(gca,'LineWidth',2);
title({'Proxisome Distance Traces',''},'Interpreter','none','FontName','Yu Gothic UI Light');
text(.5,1.03,'Each line traces the distance of one peroxisome over time.','FontSize', 17, 'FontName','Yu Gothic UI Light','HorizontalAlignment', 'center', 'Units','normalized', 'Interpreter','none');
ylabel('Distance (px)', 'Interpreter','none','FontName','Yu Gothic UI');
xlabel('Timpoint (a.u.)', 'Interpreter','none','FontName','Yu Gothic UI');

% Cell Name Text
txt = sprintf('Cell Name: %s\n', stack_name);
text(.5,.97,txt,'FontSize', 11, 'FontName','Yu Gothic UI','HorizontalAlignment', 'center', 'Units','normalized', 'Interpreter','none');

xlim([0 max(T.Timepoint)])

if SAVE_TO_DISK
  pause(0.33)
  fig_name = sprintf('/1_distance_vs_time_traces type_%s cell_%d',typ,stack_id);
  export_fig([fig_save_path fig_name '.png'],'-m2');
end

