
pero_ch_color = [0 1 0];
mito_ch_color = [1 0 0];
mito_perim_color = [1 0 0];


% Loop over stack types
for typ=fields(s_mid)'
  typ=typ{:};
  pero_stack = s_mid.(typ).pero;
  mito_stack = s_mid.(typ).mito;
  pero_ws_stack = s_mid.(typ).pero_ws;
  mito_thresh_stack = s_mid.(typ).mito_thresh;
  z_depth = size(s_mid.(typ).pero,3);
  m=[];

  % Loop over images in this stack
  for z=1:z_depth
    im_pero = pero_stack(:,:,z);
    im_mito = mito_stack(:,:,z);
    im_pero_ws = pero_ws_stack(:,:,z);
    im_mito_thresh = mito_thresh_stack(:,:,z);

    % Scale image (Pero)
    im_norm = normalize0to1(double(im_pero));
    min_dyn_range_percent = 0;
    max_dyn_range_percent = .75;
    im_adj = imadjust(im_norm,[min_dyn_range_percent max_dyn_range_percent], [0 1]); % limit intensites for better viewing 
    im_pero_scaled = uint16(im_adj.*2^16); % increase intensity to use full range of uint16 values
    im_pero_scaled = im_pero_scaled./length(NUM_CHANS); % reduce intensity so not to go overbounds of uint16
    % Scale image (Mito)
    im_norm = normalize0to1(double(im_mito));
    min_dyn_range_percent = 0;
    max_dyn_range_percent = .95;
    im_adj = imadjust(im_norm,[min_dyn_range_percent max_dyn_range_percent], [0 1]); % limit intensites for better viewing 
    im_mito_scaled = uint16(im_adj.*2^16); % increase intensity to use full range of uint16 values
    im_mito_scaled = im_mito_scaled./length(NUM_CHANS); % reduce intensity so not to go overbounds of uint16

    % Create color composite of mito and pero
    color_mito = uint16(zeros(x_res,y_res));
    color_mito(:,:,1) = im_mito_scaled .* mito_ch_color(1);
    color_mito(:,:,2) = im_mito_scaled .* mito_ch_color(2);
    color_mito(:,:,3) = im_mito_scaled .* mito_ch_color(3);
    color_pero = uint16(zeros(x_res,y_res));
    color_pero(:,:,1) = im_pero_scaled .* pero_ch_color(1);
    color_pero(:,:,2) = im_pero_scaled .* pero_ch_color(2);
    color_pero(:,:,3) = im_pero_scaled .* pero_ch_color(3);
    composite_img = color_pero + color_mito;

    % Display original image
    figure
    imshow(composite_img,[]);
    hold on

    % Display color overlay (Mito)
    labelled_img = im_mito_thresh;
    labelled_perim = imdilate(bwperim(labelled_img),strel('disk',0));
    labelled_rgb = label2rgb(uint32(labelled_perim), mito_perim_color, [1 1 1], 'shuffle');
    himage = imshow(im2uint8(labelled_rgb),[]);
    himage.AlphaData = labelled_perim*.6;
    % Display color overlay (Pero)
    labelled_img = im_pero_ws;
    labelled_perim = imdilate(bwperim(labelled_img),strel('disk',0));
    labelled_rgb = label2rgb(uint32(labelled_perim), [1 1 1], [1 1 1], 'shuffle');
    himage = imshow(im2uint8(labelled_rgb),[]);
    himage.AlphaData = logical(labelled_perim)*.8;

    % Display red dots for seeds
    % seeds(labelled_img<1)=0;
    % [xm,ym]=find(seeds);
    % hold on
    % plot(ym,xm,'or','markersize',2,'markerfacecolor','r','markeredgecolor','r')

    % Store result
    fig_name = [typ ' z=' num2str(z)];
    [imageData, alpha] = export_fig([fig_save_path fig_name '.png'],'-m2');
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
  fig_name = [typ ''];
  save_path = [fig_save_path fig_name '.png'];
  text(0.01,.99,fig_name,'FontSize',14,'Units','normalized','Interpreter','none','Color','white','HorizontalAlignment','left','VerticalAlignment','top');
  %export_fig(save_path,'-native');
  imwrite(getimage(gca),save_path);
  close all
end