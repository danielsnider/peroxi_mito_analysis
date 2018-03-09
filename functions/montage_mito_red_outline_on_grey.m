
%% Make montages of Mito region
% Loop over stack types
for typ=fields(s_mid)'
  typ=typ{:};
  img_stack = s_mid.(typ).mito;
  thresh_stack = s_mid.(typ).mito_thresh;
  z_depth = size(s_mid.(typ).mito,3);
  m=[];
  % Loop over images in this stack
  for z=1:z_depth
    % Display original image
    img = img_stack(:,:,z);
    if min(img(:)) < prctile(img(:),99.5)
        min_max = [min(img(:)) prctile(img(:),99.5)];
    else
        min_max = [];
    end
    figure
    imshow(img,[min_max]);
    hold on
    % Display color overlay
    labelled_img = thresh_stack(:,:,z);
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
    [imageData, alpha] = export_fig('ws_out.png','-m2');
    if isempty(m)
        m=uint8(zeros(size(imageData,1),size(imageData,2),3,z_depth));
    end
    m(:,:,:,z) = imageData;
    close all
  end

  % Create Montage
  figure
  montage(uint8(m),'DisplayRange',[]);
  hold on
  fig_name = [typ ' Mito Segments'];
  text(0.01,.99,fig_name,'FontSize',14,'Units','normalized','Interpreter','none','Color','white','HorizontalAlignment','left','VerticalAlignment','top');
  export_fig([fig_save_path fig_name '.png'],'-m2');
  close all
end

