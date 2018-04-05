function imgs_to_gif(imgs)
  date_str = datestr(now,'yyyymmddTHHMMSS');
  filename = [date_str '.gif'];
  for t=1:size(imgs,3)
    img = imgs(:,:,t,:);
    img=normalize0to1(img);
    img=im2uint8(img);
    if t==1;
      imwrite(img,filename,'gif', 'DelayTime',0.3, 'Loopcount',inf);
    else
      imwrite(img,filename,'gif', 'DelayTime',0.3, 'WriteMode','append');
    end
  end
end

