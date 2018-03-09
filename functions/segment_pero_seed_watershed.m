log_msg(sprintf('[%s]: %s', mfilename(), 'Segmenting pero...'));

%% Segment peroxi
% Loop over stack types
for typ=fields(s_mid)'
  typ=typ{:};
  % Loop over stacks of this type
  s_pero = s_mid.(typ).pero;
  s_pero_thresh = s_mid.(typ).pero_thresh;
  for z=1:size(s_pero,3)
    pero = s_pero(:,:,z);
    pero_thresh = s_pero_thresh(:,:,z);

    %% Seed
    img_smooth = imgaussfilt(pero, 1.4);
    seeds = imregionalmax(img_smooth);
    seeds(pero_thresh==0)=0;

    %% Watershed
    img_min = imimposemin(max(img_smooth(:))-img_smooth,seeds); % set locations of seeds to be -Inf as per  matlab's watershed
    img_ws = watershed(img_min);
    img_ws(pero_thresh==0)=0; % remove areas that aren't in our img mask
    bordercleared_img = imclearborder(img_ws);
    filled_img = imfill(bordercleared_img,'holes');
    % Remove segments that don't have a seed
    reconstruct_img = imreconstruct(logical(seeds),logical(filled_img));
    labelled_img = bwlabel(reconstruct_img);
    % Remove objects that are too small or too large
    stats = regionprops(labelled_img,'area');
    area = cat(1,stats.Area);
    min_area = 11;
    max_area = 5000;
    labelled_img(ismember(labelled_img,find(area > max_area | area < min_area)))=0;

    % Store result
    s_mid.(typ).pero_ws(:,:,z) = bwlabel(labelled_img);
  end
end
