
% Drop Columns
T.TraceUsed = [];

% Save Table
filename = sprintf('%s/peroxisome_stats type_%s cell_%d.csv',fig_save_path,typ,stack_id);
writetable(T,filename);
