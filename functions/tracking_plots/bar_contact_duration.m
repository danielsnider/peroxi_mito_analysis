

% Calculate count of contacts for each bar
tally_contact_durations = [];
num_bars = max(contact_durations);
if isempty(num_bars)
    num_bars = 1;
end
for i=1:num_bars
  tally_contact_durations(i) = sum(contact_durations==i);
end

% Plot
figure('Position',[1 1 1201 809])
subplot(1,2,1)
bh = bar(1:num_bars,tally_contact_durations);

% Set Style for bars
for i=1:length(bh)
  set(bh(i), 'LineWidth',2,'FaceColor',[.85 .325 .098],'EdgeColor',[.85 .325 .098].*.6);
end

% Style
set(gca,'FontSize',20);
set(gcf,'Color',[1 1 1 ]);
set(gca,'Color',[.95 .95 .95 ]);
grid on
box off;
set(gca,'GridAlpha',1);
set(gca,'GridColor',[1 1 1]);
set(gca,'LineWidth',2);
title({'Duration of Contact',''},'Interpreter','none','FontName','Yu Gothic UI Light');
text(.5,1.025,'Contact is defined as touching or within one pixel.','FontSize', 17, 'FontName','Yu Gothic UI Light','HorizontalAlignment', 'center', 'Units','normalized');
ylabel('Count', 'Interpreter','none','FontName','Yu Gothic UI');
xlabel('Number of Timepoints in Contact (Duration)', 'Interpreter','none','FontName','Yu Gothic UI');

%% XTicks
% Units for XTicks
xt=xticks;
ticklabels=sprintfc('%d',xt);
xticklabels(ticklabels);
set(gca,'TickLabelInterpreter','none');
% Size for XTicks
Fontsize1 = 18;
xl = get(gca,'XLabel');
xlFontSize = get(xl,'FontSize');
xAX = get(gca,'XAxis');
set(xAX,'FontSize', Fontsize1);
set(xl, 'FontSize', xlFontSize);

% Stack Type Text
txt = sprintf('Type: %s\nCell: %d', typ, stack_id);
text(.99,.97,txt,'FontSize', 13, 'FontName','Yu Gothic UI','HorizontalAlignment', 'right', 'Units','normalized', 'Interpreter','none');

if SAVE_TO_DISK
  pause(0.33)
  fig_name = sprintf('/2_bar_contact_duration type_%s cell_%d',typ,stack_id);
  export_fig([fig_save_path fig_name '.png'],SAVE_FIG_MAG);
end




% Calculate cumulative amounts for each bar
num_bars = max(contact_durations);
for i=1:num_bars
  cumulative_durations(i) = sum(contact_durations>=i);
end

% Plot
figure('Position',[1 1 1201 809])
subplot(1,2,1)
bh = bar(1:num_bars,cumulative_durations);

% Set Style for bars
for i=1:length(bh)
  set(bh(i), 'LineWidth',2,'FaceColor',[.85 .325 .098],'EdgeColor',[.85 .325 .098].*.6);
end

% Style
set(gca,'FontSize',20);
set(gcf,'Color',[1 1 1 ]);
set(gca,'Color',[.95 .95 .95 ]);
grid on
box off;
set(gca,'GridAlpha',1);
set(gca,'GridColor',[1 1 1]);
set(gca,'LineWidth',2);
title({'Duration of Contact',''},'Interpreter','none','FontName','Yu Gothic UI Light');
text(.5,1.025,'Contact is defined as touching or within one pixel.','FontSize', 17, 'FontName','Yu Gothic UI Light','HorizontalAlignment', 'center', 'Units','normalized');
ylabel('Count', 'Interpreter','none','FontName','Yu Gothic UI');
xlabel({'Meet or Exceed Number of', 'Timepoints in Contact (Duration)'}, 'Interpreter','none','FontName','Yu Gothic UI');

%% XTicks
% Units for XTicks
xt=xticks;
ticklabels=sprintfc('>=%d',xt);
xticklabels(ticklabels);
set(gca,'TickLabelInterpreter','none');
% Size for XTicks
Fontsize1 = 18;
xl = get(gca,'XLabel');
xlFontSize = get(xl,'FontSize');
xAX = get(gca,'XAxis');
set(xAX,'FontSize', Fontsize1);
set(xl, 'FontSize', xlFontSize);

% Stack Type Text
txt = sprintf('Type: %s\nCell: %d', typ, stack_id);
text(.99,.97,txt,'FontSize', 13, 'FontName','Yu Gothic UI','HorizontalAlignment', 'right', 'Units','normalized', 'Interpreter','none');

if SAVE_TO_DISK
  pause(0.33)
  fig_name = sprintf('/3_bar_contact_duration_cumulative type_%s cell_%d',typ,stack_id);
  export_fig([fig_save_path fig_name '.png'],SAVE_FIG_MAG);
end


