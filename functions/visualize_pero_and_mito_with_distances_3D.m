log_msg(sprintf('[%s]: %s', mfilename(), 'Visualizing Distances...'));

pero_ch_color = [0 1 0];
mito_ch_color = [1 0 0];
% mito_ch_color = [1 .4 .4];
mito_perim_color = [1 .5 .5];

% Loop over stack types
% for typ={'zoom_raw'}
for typ=fields(s)'
  typ=typ{:};

  % Loop over stacks
  for sid=1:length(s.(typ))
    pero_stack = s.(typ)(sid).pero_mid;
    mito_stack = s.(typ)(sid).mito_mid;
    pero_ws_stack = bwlabeln(s.(typ)(sid).pero_ws);
    mito_thresh_stack = s.(typ)(sid).mito_thresh;
    timepoints = size(s.(typ)(sid).pero_mid,3);
    stack_name = s.(typ)(sid).stack_name;
    m=[];

    % Loop over images in this stack
    for tid=1:timepoints
      im_pero = pero_stack(:,:,tid);
      im_mito = mito_stack(:,:,tid);
      im_pero_ws = pero_ws_stack(:,:,tid);
      im_mito_thresh = mito_thresh_stack(:,:,tid);
      %ObjectsInFrame = T(T.Timepoint==tid,:);
      PeroCentroidsXY = s.(typ)(sid).PeroCentroidsXY{tid};
      MitoLocationsXY = s.(typ)(sid).MitoLocationsXY{tid};
      NearestMitoInd = s.(typ)(sid).NearestMitoInd{tid};
      NearestMitoXY = s.(typ)(sid).NearestMitoXY{tid};
      Distances = s.(typ)(sid).Distances{tid};
      any_objects = ~isempty(PeroCentroidsXY);
      ConvexAreaPX = s.(typ)(sid).ConvexAreaPX(tid);
      ConvexAreaSqrUM = s.(typ)(sid).ConvexAreaSqrUM(tid);

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

      x_res = size(im_mito_scaled,1);
      y_res = size(im_mito_scaled,2);

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
      figure('Position',[1 1 2560 1276])
      imshow(composite_img,[]);
      hold on

      %% Convex Hull and Area
      if any_objects
        XY=s.(typ)(sid).ConvexHull{tid};
        line_width = 2;
        XY(XY<line_width)=line_width; % shift cell boundaries inwards so that a thickened line does not go over the bounds of the image
        XY(XY>x_res-2)=x_res-2; % shift cell boundaries inwards so that a thickened line does not go over the bounds of the image

        patch(XY(:,1), XY(:,2),'r', 'EdgeColor','red','FaceColor','none','LineWidth',line_width)
        ax = gca;               % get the current axis
        ax.Clipping = 'on';    % turn clipping off
      end

      % Display color overlay (Mito)
      labelled_img = im_mito_thresh;
      dilate_factor = size(labelled_img,1)/512-1; % scale min area by image resolution
      img_size_factor = size(labelled_img,1)/512;
      labelled_perim = imdilate(bwperim(labelled_img),strel('disk',dilate_factor));
      labelled_rgb = label2rgb(uint32(labelled_perim), mito_perim_color, [1 1 1], 'shuffle');
      himage = imshow(im2uint8(labelled_rgb),[]);
      himage.AlphaData = labelled_perim*.6;

      % Display color overlay (Pero)
      if any_objects
        labelled_img = im_pero_ws;
        labelled_perim = imdilate(bwperim(labelled_img),strel('disk',0));
        % if ismember('Trace', T.Properties.VariableNames)
        %   cmap = [0 0 0; 0 0 0; ObjectsInFrame.TraceColor]; % weird working cmap for traces
        %   all_trace_ids_short= ObjectsInFrame.TraceShort;
        %   labelled_perim=bwlabel(labelled_perim);
        %   im_pero_ws2 = im_pero_ws+2; % weird working cmap for traces
        %   im_pero_ws2(im_pero_ws2==2)=0; % weird working cmap for traces
        %   im_pero_ws2(labelled_perim==0)=0; % weird working cmap for traces
        %   im_pero_ws2(1)=1;
        %   labelled_rgb = label2rgb(im_pero_ws2, cmap, [1 1 1]); % Coloured by TraceID
        %   % labelled_rgb = label2rgb(labelled_perim, cmap, [1 1 1]); % Coloured by TraceID
        % else
        %   labelled_rgb = label2rgb(uint32(labelled_perim), [1 1 1], [1 1 1], 'shuffle'); % Coloured white
        % end

          % Color by ws label
          % labelled_rgb = label2rgb(uint32(labelled_perim), 'hsv', [1 1 1], 'shuffle'); % Coloured by ws label
          unique_labels = unique(pero_ws_stack(:));
          labelled_img(1:length(unique_labels)) = unique_labels;
          labelled_rgb = label2rgb(labelled_img, 'hsv', [1 1 1],'shuffle'); % Coloured by ws label
        himage = imshow(im2uint8(labelled_rgb),[]);
        himage.AlphaData = logical(labelled_perim)*1;
        % himage.AlphaData = logical(im_pero_ws2)*1;

        % % Display distance lines
        % quiver(PeroCentroidsXY(:, 1)', PeroCentroidsXY(:, 2)', MitoLocationsXY(1,NearestMitoInd) - PeroCentroidsXY(:, 1)', MitoLocationsXY(2, NearestMitoInd) - PeroCentroidsXY(:, 2)', 0, 'c');
        quiver(PeroCentroidsXY(:, 2), PeroCentroidsXY(:, 1), NearestMitoXY(:, 1) - PeroCentroidsXY(:, 2), NearestMitoXY(:, 2) - PeroCentroidsXY(:, 1), 0, 'c');

        % %% Display amount of distances as text
        h = text(PeroCentroidsXY(:,1)'+3*img_size_factor,PeroCentroidsXY(:,2)'-1,cellstr(num2str(round(Distances'))),'Color','cyan','FontSize',12,'Clipping','on','Interpreter','none');

        % %% Display trace ID
        % h = text(PeroCentroidsXY(:,1)'-13*img_size_factor,PeroCentroidsXY(:,2)'-1,all_trace_ids_short{:},'Color','White','FontSize',12,'Clipping','on','Interpreter','none');
        % for i=1:height(ObjectsInFrame)  % colored by cmap
          % h = text(PeroCentroidsXY(1,i)'-13*img_size_factor,PeroCentroidsXY(2,i)'-1,all_trace_ids_short{i},'Color',ObjectsInFrame.TraceColor(i,:),'FontSize',12,'Clipping','on','Interpreter','none'); % colored by cmap
        % end

      % NOT ENOUGH SIGNAL IN IMAGE, display warning
      else
        x = round(x_res)/2;
        y = round(y_res)/2;
        h = text(x,y,'Not enough signal for robust segmentation','Color','white','FontSize',18,'Clipping','on','HorizontalAlignment','center','Interpreter','none');
      end

      % Display red dots for seeds
      % seeds = s.(typ)(sid).seeds(:,:,tid);
      % seeds(labelled_img<1)=0;
      % [xm,ym]=find(seeds);
      % hold on
      % plot(ym,xm,'or','markersize',2,'markerfacecolor','r','markeredgecolor','r')


      % Information Box
      txt = sprintf('Slice: %s\nPeroxisomes Count: %d\nConvex Area: %.0f px\n%s',USE_SLICE,length(PeroCentroidsXY), ConvexAreaPX,stack_name); % '%.1f um^2',ConvexAreaSqrUM
      h = text(10,y_res-45,txt,'Color','white','FontSize',12,'Clipping','on','HorizontalAlignment','left','Interpreter','none');

      % Elapsed Time Text
      % series_id = s.(typ)(sid).series_id;
      % plane_id = tid*NUM_CHANS; 
      % t = omeMeta.getPlaneDeltaT(series_id-1, plane_id);
      % frame_txt = sprintf('Frame: %d', tid);
      % if ~isempty(t)
      %   t_val = double(t.value());
      %   t_unit = char(t.unit().getSymbol());
      %   txt = sprintf('+%.3f %s\n%s', t_val, t_unit, frame_txt);
      % else
      %   txt = frame_txt;
      % end
      frame_txt = sprintf('z=%d', tid);
      % t_val = 5.203*(tid-1);
      % t_unit = 's';
      % txt = sprintf('+%.3f %s\n%s', t_val, t_unit, frame_txt);
      h = text(10,20,frame_txt,'Color','white','FontSize',18,'Clipping','on','HorizontalAlignment','left','Interpreter','none');

      % unique_labelled_perim = unique(labelled_perim)
      % size_ObjectsInFrame = size(ObjectsInFrame)
      % size_labelled_perim = size(unique(labelled_perim))
      % size_im_pero_ws = size(unique(im_pero_ws))
      % size_cmap = size(cmap)


      if SAVE_TO_DISK
        % Store result
        fig_name = sprintf('/distance_visualization type_%s cell_%03d timepoint_%03d',typ, stack_id, tid);
        [imageData, alpha] = export_fig([fig_save_path fig_name '.png'],'-m1.8');
        % [imageData, alpha] = export_fig([fig_save_path fig_name '.png'],SAVE_FIG_MAG);
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
        m(:,:,:,tid) = imageData;
        % figure
        % imshow3Dfull(permute(m,[1 2 4 3]))

        close all
      end
    end
    if ONE_ONLY
      return
    end    


    % Create Gif
    if SAVE_TO_DISK
      fig_name = sprintf('/0_gif_distance_visualization type_%s cell_%03d.gif', typ, stack_id);
      save_path = [fig_save_path fig_name];
      colour_imgs_to_gif(m,save_path);
    end
  end
end
