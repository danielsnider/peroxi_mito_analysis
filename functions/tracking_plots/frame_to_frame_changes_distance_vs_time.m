
%% Distance to nearest Mito
figure('Position',[1 1 1201 809])
subplot(1,2,1)
for trace_id=unique(T.Trace)'
  TraceTable = T(ismember(T.Trace,trace_id),:);
  Y = TraceTable.Distance;
  X = 1:length(Y); % Timepoints as 1,2,3, etc.
  h=plot(X,Y,'-o','MarkerIndices',X);
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % disable legend
  hold on
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
text(.5,1.025,'Each line traces the distance of one peroxisome over time.','FontSize', 17, 'FontName','Yu Gothic UI Light','HorizontalAlignment', 'center', 'Units','normalized', 'Interpreter','none');
ylabel('Distance (px)', 'Interpreter','none','FontName','Yu Gothic UI');
xlabel('Timpoint (a.u.)', 'Interpreter','none','FontName','Yu Gothic UI');

% Stack Type Text
txt = sprintf('Type: %s\nCell: %d', typ, stack_id);
text(.99,.97,txt,'FontSize', 13, 'FontName','Yu Gothic UI','HorizontalAlignment', 'right', 'Units','normalized', 'Interpreter','none');

if SAVE_TO_DISK
  pause(0.1)
  fig_name = sprintf('/1_distance_vs_time_traces type_%s cell_%d',typ,stack_id);
  export_fig([fig_save_path fig_name '.png'],'-m2');
end

