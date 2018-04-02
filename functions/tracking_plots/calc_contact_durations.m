
%% Duration of Contact
CONTACT_DIST_PX = 1;
contact_durations = [];
in_contact_bool = [];
for trace_id=unique(T.Trace)'
  TraceTable = T(ismember(T.Trace,trace_id),:);
  distances = TraceTable.Distance;
  in_contact_timepoints = distances<=CONTACT_DIST_PX;
  % Example: in_contact_timepoints                             = [0 1 0 1 1 0 0 1 1 1 0 1 1 0 1 1] 
  % Example after calculation finishes: in_contact_duration    = [0 1 0 1 2 0 0 1 2 3 0 1 1 0 1 1]
  % Example after calculation finishes: contact_durations      = [  1     2         3   2     2  ]
  in_contact_timepoints=[0; in_contact_timepoints];
  in_contact_duration = [0];
  for i=2:length(in_contact_timepoints)
    if in_contact_timepoints(i)==0
      in_contact_duration(i) = 0;
    else
      in_contact_duration(i) = in_contact_duration(i-1)+1;
      if in_contact_duration(i) == 0 
        in_contact_duration(i) = 1;
      end
    end
  end
  cell_contact_durations = in_contact_duration(imregionalmax(in_contact_duration)); % find [0 1 0 1 2 0 0 1 2 3 0 1 1 0 1 1] -->  [  1     2         3   2     2  ]
  contact_durations = [contact_durations cell_contact_durations];

  in_contact_bool = [in_contact_bool in_contact_timepoints'];
end

contact_durations(contact_durations==0)=[];

all_contact_durations{length(all_contact_durations)+1} = contact_durations; % one row per cell. Each value is a length of timepoints for contact that took place
all_in_contact_bool{length(all_in_contact_bool)+1} = in_contact_bool; % one row per cell. Each value is whether a pero is in contact or not

