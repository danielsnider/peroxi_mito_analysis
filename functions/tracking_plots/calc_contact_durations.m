
%% Duration of Contact
CONTACT_THRESH_PX = 1;
contact_durations = [];
for trace_id=unique(T.Trace)'
  TraceTable = T(ismember(T.Trace,trace_id),:);
  distances = TraceTable.Distance;
  in_contact_timepoints = distances<=CONTACT_THRESH_PX;
  % Example: in_contact_timepoints                             = [0 1 0 1 1 0 0 1 1 1 0 1 1 0 1 1] 
  % Example after calculation finishes: in_contact_duration    = [0 1 0 1 2 0 0 1 2 3 0 1 1 0 1 1]
  % Example after calculation finishes: contact_durations      = [  1     2         3   2     2  ]
  in_contact_duration = [0];
  for i=2:length(in_contact_timepoints)
    if in_contact_timepoints(i)==0
      in_contact_duration(i) = 0;
    else
      in_contact_duration(i) = in_contact_duration(i-1)+1;
    end
  end
  for i=fliplr(2:length(in_contact_duration))
    if in_contact_duration(i)==0 && in_contact_duration(i-1) > 0
      contact_durations = [contact_durations in_contact_duration(i-1)];
    end
  end
end

all_contact_durations = [all_contact_durations; contact_durations];