
  %% Calculate Color Based on ID
  all_trace_ids_short = {};
  cmap = [];
  for i=1:height(CellsTable)
    trace = CellsTable.Trace{i};
    trace = strsplit(trace,'-');
    red = mod(sum(uint8(trace{1})),255);
    green = mod(sum(uint8(trace{2})),255);
    blue = mod(sum(uint8(trace{3})),255);
    cmap = [cmap; red/382+.333 green/382+.333 blue/382+.333];
    all_trace_ids_short{i} = trace{1}(1:2);
  end

  %% Save short ID
  CellsTable.TraceShort = all_trace_ids_short';
  CellsTable.TraceColor = cmap;