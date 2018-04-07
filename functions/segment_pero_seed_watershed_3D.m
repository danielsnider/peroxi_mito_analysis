log_msg(sprintf('[%s]: %s', mfilename(), 'Segmenting pero 3D...'));

%% Segment peroxi
% Loop over stack types
for typ=fields(s)'
  typ=typ{:};
  % Loop over stacks of this type
  for sid=1:length(s.(typ))
    s_pero = s.(typ)(sid).pero_mid;
    s_pero_thresh = s.(typ)(sid).pero_thresh;

    %% Seed
    img_smooth = imgaussfilt3(s_pero,[2 2 2],'FilterSize',[19 19 3]);
    seeds = imregionalmax(img_smooth);
    seeds(s_pero_thresh==0)=0;

    %% Watershed
    img_min = imimposemin(max(img_smooth(:))-img_smooth,seeds); % set locations of seeds to be -Inf as per  matlab's watershed
    img_ws = watershed(img_min);
    img_ws(s_pero_thresh==0)=0; % remove areas that aren't in our img mask
    % bordercleared_img = imclearborder(img_ws);
    % filled_img = imfill(bordercleared_img,'holes');
    filled_img = imfill(img_ws,'holes');

    %% Remove segments that don't have a seed
    % reconstruct_img = imreconstruct(logical(seeds),logical(filled_img));
    % labelled_img = bwlabeln(reconstruct_img);
    
    labelled_img = bwlabeln(filled_img);

    %% Remove objects that are too small or too large
    stats = regionprops(labelled_img,'area');
    area = cat(1,stats.Area);
    min_area_3d = 25;
    max_area_3d = Inf;
    labelled_img(ismember(labelled_img,find(area > max_area | area < min_area)))=0;

    %% Store result
    s.(typ)(sid).pero_ws = bwlabeln(labelled_img);
    s.(typ)(sid).seeds = seeds;
  end
  if ONE_ONLY
    return
  end
end
