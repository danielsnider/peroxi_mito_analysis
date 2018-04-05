function colour_imgs_to_gif(imgs,filename)
  if ~exist('filename')
    date_str = datestr(now,'yyyymmddTHHMMSS');
    filename = [date_str '.gif'];
  end
  for t=1:size(imgs,4)
    fprintf('Saving GIF frame %d to %s...\n', t, filename)
    [imind,cm] = rgb2ind(squeeze(imgs(:,:,:,t)),256);
    if t == 1;
      imwrite(imind,cm,filename,'gif', 'DelayTime',0.5, 'Loopcount',inf);
    else
       imwrite(imind,cm,filename,'gif', 'DelayTime',0.5, 'WriteMode','append');
    end
  end
end
