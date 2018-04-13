log_msg(sprintf('[%s]: %s', mfilename(), 'Visualizing Distances...'));

z_step_um = 0.34;
pixel_step_um = 0.02405; % 1 step 
num_pixels_in_one_z_step = z_step_um / pixel_step_um;

% Loop over stack types
for typ=fields(s)'
  typ=typ{:};

  % Loop over stacks
  for sid=1:length(s.(typ))
    timepoints = size(s.(typ)(sid).pero_ws,4);

    % Loop over images in this stack 
    for tid=1:timepoints
      %close all

      % Get colors if Available
      if exist('T')
        if ismember('Timepoint', T.Properties.VariableNames)
          ObjectsInFrame = T(T.Timepoint==tid,:);
          if ismember('Trace', T.Properties.VariableNames)
            TraceShort = ObjectsInFrame.TraceShort;
            TraceColor = ObjectsInFrame.TraceColor;
          end
        end
      end

      im_pero = s.(typ)(sid).pero(:,:,:,tid);
      pero_ws_stack = bwlabeln(s.(typ)(sid).pero_ws(:,:,:,tid));
      mito_thresh_stack = s.(typ)(sid).mito_thresh(:,:,:,tid);

      %mito_thresh_stack = bwlabeln(mito_thresh_stack)==1; % smaller for debug
      %pero_ws_stack(pero_ws_stack>3)=0; % smaller for debug

      figure
      hold on

      all_mito_faces = [];
      all_mito_vertices = [];
      mitoXYZ = [];
      num_pero = max(pero_ws_stack(:));

      all_mito_faces = {};
      all_mito_vertices = {};
      for zid=1:5
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
      shp = alphaShape(mitoXYZ,4);
      h = plot(shp);
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
        scatter3(pero_cent_x, pero_cent_y, pero_cent_z, pero_diameter*10,'green','filled')
      end

      % Measure distances between pero and mito
      points = pero_stats.Centroid;
      % points = points(54:60,:); % limit pero for debugging

      %% Do distance measurements
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
        [distances,surface_points] = point2trimesh(FV, 'QueryPoints', points); 
        %points(:,3) = points(:,3)./13; % z depth scale factor 13um
        %surface_points(:,3) = surface_points(:,3)./13; % z depth scale factor 13um
        all_distances(:,i) = abs(distances);
        all_surface_points(:,:,i) = surface_points;
      end

      [min_dist,min_dist_type_id]=min(all_distances');
      Distances = min_dist;

      surface_points = [];
      for pid=1:num_pero
        surface_points(pid,:) = all_surface_points(pid,:,min_dist_type_id(pid));
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
          fig_name = sprintf('/distance_visualization type_%s cell_%03d timepoint_%03d frame_%03d',typ, stack_id, tid, fid);
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
          fig_name = sprintf('/distance_visualization type_%s cell_%03d timepoint_%03d frame_%03d',typ, stack_id, tid, frames+fid);
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
        fig_name = sprintf('/0_gif_distance_visualization type_%s cell_%03d.gif', typ, stack_id);
        save_path = [fig_save_path fig_name];
        colour_imgs_to_gif(m,save_path);
      end

      % Handle no objects found
      if length(pero_stats)==0
        mito_stats = pero_stats;
        PeroCentroidsXY = [];
        MitoLocationsXYZ = [];
        NearestMitoInd = [];
        Distances = [];
      end

      % Store Result
      s.(typ)(sid).PeroCentroidsXY{tid} = points;
      s.(typ)(sid).MitoLocationsXYZ{tid} = surface_points;
      s.(typ)(sid).Distances{tid} = Distances; 
      s.(typ)(sid).PeroArea{zid} = cat(1,pero_stats.Volume);
      s.(typ)(sid).PeroMeanIntensity{zid} = cat(1,pero_stats.MeanIntensity);
      s.(typ)(sid).PeroTotalIntensity{zid} = s.(typ)(sid).PeroArea{zid} .* s.(typ)(sid).PeroMeanIntensity{zid};
    end

    if ONE_ONLY
      return
    end
  end
end
