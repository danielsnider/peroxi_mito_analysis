log_msg(sprintf('[%s]: %s', mfilename(), 'Removing short tracks...'));

MIN_TRACE_LENGTH = 6;
for trace_id=unique(T.Trace)'
  TraceTable = T(ismember(T.Trace,trace_id),:);
  num_traces = height(TraceTable);
  if num_traces < MIN_TRACE_LENGTH;
    % Delete these pero's from the labelled images
    for pero_id=1:height(TraceTable)
      centroid = TraceTable.PeroCentroid(pero_id,:);
      tid = TraceTable.Timepoint(pero_id);
      pero_label_id = s.(typ).pero_ws(centroid(2),centroid(1),tid);
      pero_removed = s.(typ).pero_ws(:,:,tid);
      pero_removed(pero_removed==pero_label_id)=0;
      s.(typ).pero_ws(:,:,tid)=pero_removed; % Delete the label for this pero 
    end
  end
end

% Relabel the peroxisomes
for tid=1:size(s.(typ).pero_ws,3)
  s.(typ).pero_ws(:,:,tid) = bwlabel(s.(typ).pero_ws(:,:,tid));
end

%% Recalculate stats
measure_dist_pero_to_mito_2DT
create_table_pero_2DT
[raw_differences, normalized_differences, composite_differences] = DifferentialMeasurements(T);
[T,DiffTable] = cell_tracking_v1_simple(T, composite_differences);
