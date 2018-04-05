log_msg(sprintf('[%s]: %s', mfilename(), 'Montage pero...'));

%% Make montages of Mito region
% Loop over stack types
for typ=fields(s)'
  typ=typ{:};
  % Loop over stacks of this type
  for sid=1:length(s.(typ))
    s_pero = s.(typ)(sid).pero_mid;
    thresh_stack = s.(typ)(sid).pero_thresh;
    timepoints = size(s.(typ)(sid).pero_mid,3);
    m=[];
    % Loop over timepoints
    for tid=1:timepoints
      % Display original image
      img = s_pero(:,:,tid);
      if min(img(:)) < prctile(img(:),99.99)
          min_max = [min(img(:)) prctile(img(:),99.99)];
      else
          min_max = [];
      end
      figure
      imshow(img,[min_max]);
      hold on
      % Display color overlay
      labelled_img = thresh_stack(:,:,tid);
      labelled_perim = imdilate(bwperim(labelled_img),strel('disk',0));
      labelled_rgb = label2rgb(uint32(labelled_perim), [1 0 0], [1 1 1], 'shuffle');
      himage = imshow(im2uint8(labelled_rgb),[min_max]);
      himage.AlphaData = labelled_perim*1;
      % Display red dots for seeds
      seeds(labelled_img<1)=0;
      [xm,ym]=find(seeds);
      hold on
      plot(ym,xm,'or','markersize',2,'markerfacecolor','r','markeredgecolor','r')

      % Store result
      if SAVE_TO_DISK
        fig_name = sprintf('single pero %s stack %03d time %03d',typ, sid, tid);
        [imageData, alpha] = export_fig([fig_save_path fig_name '.png'],'-m2');
        if isempty(m)
            m=uint8(zeros(size(imageData,1),size(imageData,2),3,timepoints));
        end
        m(:,:,:,tid) = imageData;
        close all
      end
    end
    if ONE_ONLY
      return
    end

    % Create Montage
    if SAVE_TO_DISK
      figure
      montage(uint8(m),'DisplayRange',[]);
      hold on
      fig_name = [ 'montage pero' typ ''];
      save_path = [fig_save_path fig_name '.png'];
      text(0.01,.99,fig_name,'FontSize',14,'Units','normalized','Interpreter','none','Color','white','HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none');
      imwrite(getimage(gca),save_path);
      close all
    end
  end
end


