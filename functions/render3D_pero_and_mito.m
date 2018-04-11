log_msg(sprintf('[%s]: %s', mfilename(), 'Rendering...'));

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
    timepoints = size(s.(typ)(sid).pero_mid,3);
    stack_name = s.(typ)(sid).stack_name;
    m=[];

    % Loop over images in this stack
    for tid=1:timepoints

      pero_ws_stack = bwlabeln(s.(typ)(sid).pero_ws);
      mito_thresh_stack = s.(typ)(sid).mito_thresh;

      figure(1); clf
      labelled_mito = bwlabeln(mito_thresh_stack);
      figure(3); clf; imshow3Dfull(flipud(labelled_mito), []);
      stats = regionprops3(labelled_mito,'Volume');
      for mid=40:height(stats)
        mito_part_volume=stats.Volume(mid);
        mito_part_im = labelled_mito==mid;
        % Cut object into many small pieces so that we can get convex hulls of the parts, getting one big convex hull would be one big lump with no detail!
        num_cuts = 10000;
        mito_supercut = superpixels3(uint8(mito_part_im), num_cuts,'NumIterations',1);
        mito_supercut(mito_thresh_stack==0)=0; % remove known background 
        figure(2); clf; imshow3Dfull(flipud(mito_supercut), []);
        % Get the points that delineate a convex hull around the mito
        cut_stats = regionprops3(mito_supercut,'ConvexHull');
        for vert_points=cut_stats.ConvexHull'
          vert_points = vert_points{:};
          vert_points (:,3) = vert_points(:,3).*13; % z depth scale factor 13um
          vx = vert_points(:,1);
          vy = vert_points(:,2);
          vz = vert_points(:,3);
          % Get surface faces from verticies
          faces = boundary(vert_points); % returns a triangulation representing a single conforming 3-D boundary around the points (x,y,z). Each row of k is a triangle defined in terms of the point indices.

          % Plot with trisurf (same as patch)
          figure(1); clf
          trisurf(faces,vx,vy,vz,'Facecolor','red','FaceAlpha',1)
          hold on
          axis equal
        end
        pause
      end 

      % %% Visualize distances from point to the surface of the Mito (with point2trimesh)
      % vert_points (:,3) = vert_points(:,3).*13; % z depth scale factor 13um
      % FV.faces = faces;
      % FV.vertices = vert_points;
      % points = [900 700 5; 900 950 5; 950 900 5]; 
      % [distances,surface_points] = point2trimesh(FV, 'QueryPoints', points); 
      % patch(FV,'FaceAlpha',.5); xlabel('x'); ylabel('y'); zlabel('z'); axis equal; hold on 
      % plot3M = @(XYZ,varargin) plot3(XYZ(:,1),XYZ(:,2),XYZ(:,3),varargin{:}); 
      % plot3M(points,'*r') 
      % plot3M(surface_points,'*k') 
      % plot3M(reshape([shiftdim(points,-1);shiftdim(surface_points,-1);shiftdim(points,-1)*NaN],[],3),'k')

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
