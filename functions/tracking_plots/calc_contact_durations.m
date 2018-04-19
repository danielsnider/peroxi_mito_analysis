

%% Duration of Contact
CONTACT_DIST_PX = 1;
contact_durations = [];
in_contact_bool = [];
all_trace_pos = [];
contact_durations_per_pero = [];
for trace_id=unique(T.Trace, 'stable')'
  trace_pos = ismember(T.Trace,trace_id);
  TraceTable = T(trace_pos,:);
  distances = TraceTable.Distance;
  in_contact_timepoints = distances<=CONTACT_DIST_PX;
  % Example: in_contact_timepoints                             = [0 1 0 1 1 0 0 1 1 1 0 1 1 0 1 1] 
  % Example after calculation finishes: in_contact_duration    = [0 1 0 1 2 0 0 1 2 3 0 1 2 0 1 2]
  % Example after calculation finishes: contact_durations      = [  1     2         3     2     2]
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

  in_contact_duration = in_contact_duration(2:end); % remove first item in list because this algorithm only added it to facilitate calculation
  contact_durations_per_pero = [contact_durations_per_pero; in_contact_duration']; % store one data point of length of the seen trace per observed peroxisome, used to save into a CSV 
  in_contact_timepoints = in_contact_timepoints(2:end); % remove first item in list because this algorithm only added it to facilitate calculation
  in_contact_bool = [in_contact_bool in_contact_timepoints'];

   % Get locations of these traces within the T table. The order is important because when we add data back to the table it has to be sorted the same as the table. The table is sorted by timepoint (see create_table_pero_2DT.m) but this function sorts data by Trace. We will correct locations.
  all_trace_pos = [all_trace_pos; find(trace_pos)];
end

% Remove 0s we anly want to know trace lengths greater than 0
contact_durations(contact_durations==0)=[];

%% For adding a stats to table
% Create an array that contains for each pero at each timepoint how long the contact dwell time is.
% Example before calculation finishes: in_contact_duration    = [0 1 0 1 2 0 0 1 2 3 0 1 2 0 1 2]
% Example after  calculation finishes: in_contact_duration2   = [0 1 0 2 2 0 0 3 3 3 0 2 2 0 2 2]
in_contact_duration2 = [];
in_contact_duration_ = [contact_durations_per_pero' 0];
for i=fliplr(1:length(in_contact_duration_)-1)
  if in_contact_duration_(i+1) == 0 && in_contact_duration_(i) > 0
    save_num = in_contact_duration_(i);
  end
  if in_contact_duration_(i) == 0
    save_num = 0;
  end
  in_contact_duration2(i) = save_num;
end


% Correct data so it is sorted the same way as table T
in_contact_bool=in_contact_bool(all_trace_pos);
in_contact_duration2=in_contact_duration2(all_trace_pos);

% in_contact_duration2 = fliplr(in_contact_duration2);

%% Add stats to table % BUG NOT WORKING, NOT SURE WHY THE VALUES ORDER IS MESSED UP. It's obviously broken if you look in T where Distance < 0 the InContactBool is not 1
% T.InContactBool = in_contact_bool';
% T.ContactDwellTime = in_contact_duration2';

%% Add to dwell table
iterDwellTable = table();
iterDwellTable.DwellTime = contact_durations';
iterDwellTable.CellNum = zeros(length(contact_durations),1)+stack_id;
ImageProcessingType=cell(length(contact_durations),1);
ImageProcessingType(:) = {IMAGE_PROCESSING_TYPE};
iterDwellTable.ImageProcessingType = ImageProcessingType;
DwellTable = [DwellTable; iterDwellTable];

%% Store stats for easy plotting later
all_contact_durations{length(all_contact_durations)+1} = contact_durations; % one row per cell. Each value is a length of timepoints for contact that took place
all_in_contact_bool{length(all_in_contact_bool)+1} = in_contact_bool; % one row per cell. Each value is whether a pero is in contact or not
