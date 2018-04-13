function colour_imgs_to_gif(imgs,filename, fps)

  if ~exist('fps')
    fps=1/30;
  end
  if ~exist('filename')
    date_str = datestr(now,'yyyymmddTHHMMSS');
    filename = [date_str '.gif'];
  end
  for t=1:size(imgs,4)
    fprintf('Saving GIF frame %d to %s...\n', t, filename)
    [imind,cm] = rgb2ind(squeeze(imgs(:,:,:,t)),256);
    if t == 1;
      imwrite(imind,cm,filename,'gif', 'DelayTime',fps, 'Loopcount',inf);
    else
       imwrite(imind,cm,filename,'gif', 'DelayTime',fps, 'WriteMode','append');
    end
  end
end
