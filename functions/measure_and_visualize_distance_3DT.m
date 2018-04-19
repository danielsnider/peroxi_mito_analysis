log_msg(sprintf('[%s]: %s', mfilename(), 'Measuring distances...'));

z_step_um = 0.34;
pixel_step_um = 0.02405; % 1 step 
num_pixels_in_one_z_step = z_step_um / pixel_step_um;

% Loop over stack types
for typ=fields(s)'
  typ=typ{:};

  % Loop over stacks
  for sid=1:length(s.(typ))
    timepoints = size(s.(typ)(sid).pero_ws,4);
    z_depth = size(s.(typ)(sid).pero_ws,3);
    res_x = size(s.(typ)(sid).pero_ws,1);
    res_y = size(s.(typ)(sid).pero_ws,2);

    % Loop over images in this stack 
    for tid=1:timepoints
      log_msg(sprintf('[%s]: %s timepoint %d', mfilename(), 'Measuring distances', tid));
      %close all

      im_pero = s.(typ)(sid).pero(:,:,:,tid);
      pero_ws_stack = bwlabeln(s.(typ)(sid).pero_ws(:,:,:,tid));
      mito_thresh_stack = s.(typ)(sid).mito_thresh(:,:,:,tid);

      % Get tracking info if available
      clear TraceColor TraceShort Trace
      if exist('T')
        if ismember('Timepoint', T.Properties.VariableNames)
          ObjectsInFrame = T(T.Timepoint==tid,:);
          if ismember('Trace', T.Properties.VariableNames)
            TraceShort = ObjectsInFrame.TraceShort;
            TraceColor = ObjectsInFrame.TraceColor;
          end
        end
      end

      %mito_thresh_stack = bwlabeln(mito_thresh_stack)==1; % smaller for debug
      %pero_ws_stack(pero_ws_stack>3)=0; % smaller for debug

      figure
      hold on

      mitoXYZ = [];
      num_pero = max(pero_ws_stack(:));
      all_mito_faces = {};
      all_mito_vertices = {};
      all_pero_faces = {};
      all_pero_vertices = {};
      for zid=1:z_depth
        [Y X] = find(mito_thresh_stack(:,:,zid));
        Z = zeros(length(X),1)+zid;
        if isempty(Z)
          continue
        end
        mitoXYZ = [mitoXYZ; X Y Z];

        % Draw 2D slice
        shp2d = alphaShape(X,Y); % the default behaviour of a 2d render with alphaShape is to draw green slices at z=0, the next line disables this
        h2d = plot(shp2d); % hide the green 2d slices
        h2d.Visible='off';
        faces = h2d.Faces;
        vertices = [h2d.Vertices Z.*13]; % we created a two 2D but want to put it in 3D
        p = patch('Faces',faces,'Vertices',vertices);
        p.FaceColor = 'red';
        p.EdgeColor = 'none';

        all_mito_faces{zid} = faces;
        all_mito_vertices{zid} = vertices;
      end

      % Render 3D mito
      mito_shp = alphaShape(mitoXYZ,4);
      h = plot(mito_shp);
      h.FaceColor = 'red';
      h.EdgeColor = 'none';
      h.Vertices(:,3) = h.Vertices(:,3) .* 13; % z depth scale factor 13um
      all_mito_faces{zid+1} = h.Faces;
      all_mito_vertices{zid+1} = h.Vertices;


      pero_stats = regionprops3(pero_ws_stack, im_pero, 'Centroid','EquivDiameter','Volume','MeanIntensity');
      pero_stats.Centroid(:,3) = pero_stats.Centroid(:,3) .* 13;  % z depth scale factor 13um
      %% Render each pero one at a time 
      for pid=1:max(pero_ws_stack(:))
        % Draw scatter points instead of rendering with surfaces
        pero_cent_x = pero_stats.Centroid(pid,1);
        pero_cent_y = pero_stats.Centroid(pid,2);
        pero_cent_z = pero_stats.Centroid(pid,3);
        pero_diameter = pero_stats.EquivDiameter(pid);

        if ~RENDER_PERO
          if exist('TraceColor') && ~isempty(TraceColor)
            scatter3(pero_cent_x, pero_cent_y, pero_cent_z, pero_diameter*10,TraceColor(pid,:),'filled')
          else
            scatter3(pero_cent_x, pero_cent_y, pero_cent_z, pero_diameter*10,'green','filled')
          end
        end

        if RENDER_PERO
          pero = pero_ws_stack==pid;
          peroXYZ = [];

          % Render each 2D z-slice of the pero one at a time. This is needed because the 3D render isn't perfect and doesn't display thin 2D slices at all.
          for zid=1:z_depth
            [Y X] = find(pero(:,:,zid));
            Z = zeros(length(X),1)+zid;
            if isempty(Z)
              continue
            end
            peroXYZ= [peroXYZ; X Y Z];
            pero_shp2d = alphaShape(X,Y); % the default behaviour of a 2d render with alphaShape is to draw green slices at z=0, the next line disables this
            pero_h2d = plot(pero_shp2d); % hide the green 2d slices
            pero_h2d.Visible='off';
            faces = pero_h2d.Faces;
            vertices = [pero_h2d.Vertices Z .* 13]; % we created a two 2D but want to put it in 3D
            if isempty(pero_h2d.Faces)
                continue
            end
            p = patch('Faces',faces,'Vertices',vertices);
            p.FaceColor = 'green';
            % if exist('TraceColor') && ~isempty(TraceColor)
            %   p.FaceColor = TraceColor(pid,:);
            % end
            p.EdgeColor = 'none';

            all_pero_faces{zid} = faces;
            all_pero_vertices{zid} = vertices;
          end
          if isempty(peroXYZ)
            continue
          end

          % Render 3D pero
          pero_shp = alphaShape(peroXYZ,4);
          pero_h = plot(pero_shp);
          pero_h.FaceColor = 'green';
          % if exist('TraceColor') && ~isempty(TraceColor)
          %   pero_h.FaceColor = TraceColor(pid,:);
          % end
          pero_h.EdgeColor = 'none';
          pero_h.Vertices(:,3) = pero_h.Vertices(:,3) .* 13; % z depth scale factor 13um
          all_pero_faces{zid+1} = pero_h.Faces;
          all_pero_vertices{zid+1} = pero_h.Vertices;
        end

      end

      % Measure distances between pero and mito
      points = pero_stats.Centroid;
      % points = points(54:60,:); % limit pero for debugging
      %% Do distance measurements
      if ~isfield(s.(typ)(sid), 'Distances') || length(s.(typ)(sid).Distances) < tid % only calculate if needed
        % NOTE: There are 6 distance types, the closest mito could be found in a 2D slice or the 3D render, because...
        % NOTE: We had to measure each 2D slice and the 3D render seperately because I couldn't find a way to make them all one 3D object that could be measured by point2trimesh.
        % Example:
        % all_distances =
        %                z=1           z=2          z=3          z=4            z=5        3D     <----- Distance to nearest mito in z=1,2,3,4,5 or 3D
        % Pero 1        14.137      -13.609          -26      -39.002            0       13.609
        % Pero 2        22.876       -20.52      -29.065      -40.768            0        20.52
        % Pero 3        88.551      -86.332      -86.129      -91.243            0        86.03
        all_distances = []; % distance to each 
        all_surface_points = [];
        for i=1:length(all_mito_vertices)
          FV.faces = all_mito_faces{i};
          FV.vertices = all_mito_vertices{i};
          if isempty(FV.faces)
            all_distances(:,i) = NaN;
            all_surface_points(:,:,i) = NaN;
            continue
          end
          %FV.vertices(:,3) = FV.vertices(:,3).*13; % z depth scale factor 13um
          %points(:,3) = points(:,3).*13; % z depth scale factor 13um
          [distances,surface_points] = point2trimesh(FV, 'QueryPoints', points, 'Algorithm', 'parallel');
          %points(:,3) = points(:,3)./13; % z depth scale factor 13um
          %surface_points(:,3) = surface_points(:,3)./13; % z depth scale factor 13um
          all_distances(:,i) = abs(distances);
          all_surface_points(:,:,i) = surface_points;
        end

        % Get lowest distances
        [min_dist,min_dist_type_id]=min(all_distances');
        Distances = min_dist;

        % Get the correct surface points (there are multiple types 2D z=1,z=2,3D)
        surface_points = [];
        for pid=1:num_pero
          surface_points(pid,:) = all_surface_points(pid,:,min_dist_type_id(pid));
        end

        if EDGE_TO_EDGE_DISTANCE
          Distances = Distances - pero_stats.EquivDiameter' ./ 2;
          Distances(Distances<0) = 0;
        end
      else
        % Use saved variables, do not recalculate
        Distances = s.(typ)(sid).Distances{tid};
        surface_points = s.(typ)(sid).MitoLocationsXYZ{tid};
      end

      % Plot distance lines
      plot3M(reshape([shiftdim(points,-1);shiftdim(surface_points,-1);shiftdim(points,-1)*NaN],[],3),'k')

      % Style
      axis tight
      view(3)
      rotate3d on
      axis vis3d % disable strech-to-fill
      set(gca, 'color','none')
      set(gcf, 'color',[1 1 1])
      camlight 
      lighting gouraud
      h.AmbientStrength = 0.3;
      h.DiffuseStrength = 0.8;
      h.SpecularStrength = 0.9;
      h.SpecularExponent = 25;

      % Display trace id if available
      if exist('TraceShort') && ~isempty(TraceShort)
        for pid=1:num_pero
          h = text(points(pid,1)'-20,points(pid,2)'+20,points(pid,3)',TraceShort{pid},'Color',TraceColor(pid,:),'FontSize',12,'Clipping','on','Interpreter','none','HorizontalAlignment','center');
        end
      end

      % Display amount of distances as text
      h = text(points(:,1)'+20,points(:,2)'-20,points(:,3)',cellstr(num2str(round(Distances'))),'Color','cyan','FontSize',12,'Clipping','on','Interpreter','none','HorizontalAlignment','center');

      % Elapsed Time Text
      frame_txt = sprintf('Frame: %d', tid);
      t_val = 5.203*(tid-1);
      t_unit = 's';
      frame_txt = sprintf('+%.3f %s\n%s', t_val, t_unit, frame_txt);
      %h = text(1000,150,100,txt,'Color','black','FontSize',14,'Interpreter','none','HorizontalAlignment','center');

      % Information Box
      cell_name = sprintf('Name: Fibroblast %d',count);
      info_txt = sprintf('%s\n%s\nPeroxisome Count: %d',frame_txt,cell_name, length(points));
      %h = text(0,0,0,info_txt ,'Color','Black','FontSize',12,'Clipping','off','HorizontalAlignment','center','Interpreter','none');

      dim = [.67 .67 .1 .1]; % four-element vector of the form [x y w h]
      annotation('textbox',dim,'String',info_txt)


      if exist('TraceColor') && ~isempty(TraceColor);
        tracked = 'tracked';
      else
        tracked = '';
      end
      if SAVE_TO_DISK
        % Store result
        if strcmp(tracked,'tracked')
          fig_name = sprintf('/distance_visualization type_%s cell_%03d timepoint_%03d %s',typ, stack_id, tid, tracked);
          [imageData, alpha] = export_fig([fig_save_path fig_name '.png'],SAVE_FIG_MAG, '-nocrop');
          if ~exist('timelapse_gif')
            timelapse_gif=uint8(zeros(size(imageData,1),size(imageData,2),3,timepoints));
          end
          timelapse_gif(:,:,:,tid) = imageData;

          % Top Down View
          fig_name = sprintf('/distance_visualization type_%s cell_%03d  top_down_view timepoint_%03d %s',typ, stack_id, tid, tracked);
          view(2)
          set(gca,'Color',[0 0 0 ]);
          set(gcf,'Color',[0 0 0 ]);
          set(gca,'ycolor','white')
          set(gca,'xcolor','white')
          annotation('textbox',dim,'String',info_txt,'Color','w')
          plot3M(reshape([shiftdim(points,-1);shiftdim(surface_points,-1);shiftdim(points,-1)*NaN],[],3),'cyan')
          [imageData, alpha] = export_fig([fig_save_path fig_name '.png'],SAVE_FIG_MAG);

        end
      end

      % % ANIMATE
      % if tid == 1
      %   Animate_and_save_to_disk
      % end

      % Handle no objects found
      if height(pero_stats)==0
        mito_stats = pero_stats;
        PeroCentroidsXY = [];
        MitoLocationsXYZ = [];
        NearestMitoInd = [];
        Distances = [];
      end

      mito_volume = volume(mito_shp);

      % Store Result
      s.(typ)(sid).PeroCentroidsXYZ{tid} = points;
      s.(typ)(sid).MitoLocationsXYZ{tid} = surface_points;
      s.(typ)(sid).MitoVolume{tid} = mito_volume;
      s.(typ)(sid).Distances{tid} = Distances; 
      s.(typ)(sid).PeroArea{tid} = cat(1,pero_stats.Volume);
      s.(typ)(sid).PeroMeanIntensity{tid} = cat(1,pero_stats.MeanIntensity);
      s.(typ)(sid).PeroTotalIntensity{tid} = s.(typ)(sid).PeroArea{tid} .* s.(typ)(sid).PeroMeanIntensity{tid};

      iterMitoTable = table();
      iterMitoTable.Size = mito_volume;
      iterMitoTable.CellNum = stack_id;
      iterMitoTable.Timepoint = tid;
      iterMitoTable.ImageProcessingType = {IMAGE_PROCESSING_TYPE};
      MitoTable = [MitoTable; iterMitoTable];
    end

    % Create Gif
    if SAVE_TO_DISK
      if strcmp(tracked,'tracked')
        fig_name = sprintf('/0_gif_distance_visualization type_%s cell_%03d %s.gif', typ, stack_id, tracked);
        save_path = [fig_save_path fig_name];
        colour_imgs_to_gif(timelapse_gif,save_path, 1/2);
      end
    end

    if ONE_ONLY
      return
    end
  end

end
