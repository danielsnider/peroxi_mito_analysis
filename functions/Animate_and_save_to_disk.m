
%% Animate and save to disk
m = [];
frames = 180;
fps = 1/30;
angle_step = 2;
speedupdown = -cos(linspace(0,pi,frames));

for fid = 1:frames
  camorbit(angle_step,speedupdown(fid));

  if SAVE_TO_DISK
  % Store result
    fig_name = sprintf('/rotate type_%s cell_%03d timepoint_%03d frame_%03d %s',typ, stack_id, tid, fid, tracked);
    [imageData, alpha] = export_fig([fig_save_path fig_name '.png'],SAVE_FIG_MAG, '-nocrop');
    if isempty(m)
        m=uint8(zeros(size(imageData,1),size(imageData,2),3,timepoints*2));
        size_m = size(m)
    end

    % Resize images to be the minimum common size in the X and Y
    size_imageData = size(imageData) % debug only
    min_x_res = min(size(m,1), size(imageData,1));
    min_y_res = min(size(m,2), size(imageData,2));
    m = m(1:min_x_res, 1:min_y_res, :,:); % minimum common size
    imageData = imageData(1:min_x_res,1:min_y_res,:); % minimum common size

    % Save result
    m(:,:,:,fid) = imageData;
  else
    pause(fps)
  end
end

% Rotate the render about the x axis
for fid = 1:frames
  camorbit(angle_step,0);

  if SAVE_TO_DISK
    % Store result
    fig_name = sprintf('/rotate type_%s cell_%03d timepoint_%03d frame_%03d %s',typ, stack_id, tid, frames+fid, tracked);
    [imageData, alpha] = export_fig([fig_save_path fig_name '.png'],SAVE_FIG_MAG, '-nocrop');
    if isempty(m)
        m=uint8(zeros(size(imageData,1),size(imageData,2),3,timepoints));
    end

    % Resize images to be the minimum common size in the X and Y
    size_imageData = size(imageData) % debug only
    min_x_res = min(size(m,1), size(imageData,1));
    min_y_res = min(size(m,2), size(imageData,2));
    m = m(1:min_x_res, 1:min_y_res, :,:); % minimum common size
    imageData = imageData(1:min_x_res,1:min_y_res,:); % minimum common size

    % Save result
    m(:,:,:,frames+fid) = imageData;
  else
    pause(fps)
  end
end

% Create Gif
if SAVE_TO_DISK
  fig_name = sprintf('/0_gif_rotate type_%s cell_%03d %s.gif', typ, stack_id, tracked);
  save_path = [fig_save_path fig_name];
  colour_imgs_to_gif(m,save_path);
end
