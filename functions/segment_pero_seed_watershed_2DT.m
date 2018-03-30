log_msg(sprintf('[%s]: %s', mfilename(), 'Segmenting pero...'));

%% Segment peroxi
% Loop over stack types
for typ=fields(s)'
  typ=typ{:};
  % Loop over stacks of this type
  for sid=1:length(s.(typ))
    s_pero = s.(typ)(sid).pero_mid;
    s_pero_thresh = s.(typ)(sid).pero_thresh;
    % Loop over timepoints
    for tid=1:size(s_pero,3)
      pero = s_pero(:,:,tid);
      pero_thresh = s_pero_thresh(:,:,tid);

      %% Seed
      img_smooth = imgaussfilt(pero, 1.6);
      seeds = imregionalmax(img_smooth);
      seeds(pero_thresh==0)=0;

      %% Watershed
      img_min = imimposemin(max(img_smooth(:))-img_smooth,seeds); % set locations of seeds to be -Inf as per  matlab's watershed
      img_ws = watershed(img_min);
      img_ws(pero_thresh==0)=0; % remove areas that aren't in our img mask
      bordercleared_img = imclearborder(img_ws);
      filled_img = imfill(bordercleared_img,'holes');

      % Join overly cut objects
      % joined_img = JoinCutObjects(filled_img);

      % Remove segments that don't have a seed
      reconstruct_img = imreconstruct(logical(seeds),logical(filled_img));
      labelled_img = bwlabel(reconstruct_img);
      % Remove objects that are too small or too large
      stats = regionprops(labelled_img,'area');
      area = cat(1,stats.Area);

      min_a = min_area*size(labelled_img,1)/512; % scale min area by image resolution
      labelled_img(ismember(labelled_img,find(area > max_area | area < min_a)))=0;

      % Store result
      s.(typ)(sid).pero_ws(:,:,tid) = bwlabel(labelled_img);
      s.(typ)(sid).seeds(:,:,tid) = seeds;
    end
  end
  if ONE_ONLY
    return
  end
end
