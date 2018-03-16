
pero_ch_color = [0 1 0];
mito_ch_color = [1 0 0];
% mito_ch_color = [1 .4 .4];
mito_perim_color = [1 .5 .5];


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
    PeroCentroidsXY = s_mid.(typ).PeroCentroidsXY{z};
    MitoLocationsXY = s_mid.(typ).MitoLocationsXY{z};
    NearestMitoInd = s_mid.(typ).NearestMitoInd{z};
    Distances = s_mid.(typ).Distances{z};
    any_objects = ~isempty(PeroCentroidsXY);
    ConvexAreaPX = s_mid.(typ).ConvexAreaPX(z);
    ConvexAreaSqrUM = s_mid.(typ).ConvexAreaSqrUM(z);

    % Scale image (Pero)
    im_norm = normalize0to1(double(im_pero));
    min_dyn_range_percent = 0;
    max_dyn_range_percent = .95;
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

    %% Convex Hull and Area
    if any_objects
      XY=s_mid.(typ).ConvexHull{z};
      patch(XY(:,1), XY(:,2),'r', 'EdgeColor','red','FaceColor','none','LineWidth',2)
    end

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

    if any_objects
      % Display distance lines
      quiver(PeroCentroidsXY(1, :), PeroCentroidsXY(2, :), MitoLocationsXY(1,NearestMitoInd) - PeroCentroidsXY(1, :), MitoLocationsXY(2, NearestMitoInd) - PeroCentroidsXY(2, :), 0, 'c');

      %% Display amount of distances as text
      h = text(PeroCentroidsXY(1,:)'+3,PeroCentroidsXY(2,:)',cellstr(num2str(round(Distances'))),'Color','cyan','FontSize',9,'Clipping','on','Interpreter','none');
      % Delete text that goes off the screen
      text_extent = cat(1,h.Extent);
      text_extent_total_x = text_extent(:,1) + text_extent(:,3);
      text_extent_total_y = text_extent(:,2) + text_extent(:,4);
      delete(h(text_extent_total_x > x_res));
      delete(h(text_extent_total_x > y_res));

    % NOT ENOUGH SIGNAL IN IMAGE, display warning
    else
      x = round(x_res)/2;
      y = round(y_res)/2;
      h = text(x,y,'Not enough signal for robust segmentation','Color','white','FontSize',18,'Clipping','on','HorizontalAlignment','center','Interpreter','none');
    end

    % Display red dots for seeds
    % seeds(labelled_img<1)=0;
    % [xm,ym]=find(seeds);
    % hold on
    % plot(ym,xm,'or','markersize',2,'markerfacecolor','r','markeredgecolor','r')


    % Information Box
    txt = sprintf('Name: %s Stack # %d\nSlice: %s\nPeroxisomes Count: %d\nConvex Area: %.0f px, %.1f um^2',type_namemap(typ),z,USE_SLICE,length(PeroCentroidsXY), ConvexAreaPX, ConvexAreaSqrUM);
    h = text(10,y_res-35,txt,'Color','white','FontSize',12,'Clipping','on','HorizontalAlignment','left','Interpreter','none');


    if ONE_ONLY
      return
    end    
    if SAVE_TO_DISK
      % Store result
      sli = size(labelled_img)
      fig_name = [ 'single ' typ ' stack ' num2str(z)];
      [imageData, alpha] = export_fig([fig_save_path fig_name '.png'],'-m2');
      if isempty(m)
          m=uint8(zeros(size(imageData,1),size(imageData,2),3,z_depth));
      end
      m(:,:,:,z) = imageData;

      close all
    end
  end

  % Create Montage
  if SAVE_TO_DISK
    figure
    montage(uint8(m),'DisplayRange',[]);
    hold on
    fig_name = [ 'montage ' typ ''];
    save_path = [fig_save_path fig_name '.png'];
    text(0.01,.99,fig_name,'FontSize',14,'Units','normalized','Interpreter','none','Color','white','HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none');
    imwrite(getimage(gca),save_path);
    close all
  end
end