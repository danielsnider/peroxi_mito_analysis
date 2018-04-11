%close all

pero_ws_stack = bwlabeln(s.(typ)(sid).pero_ws);
mito_thresh_stack = s.(typ)(sid).mito_thresh;

mito_thresh_stack = bwlabeln(mito_thresh_stack)==1; % smaller for debug
pero_ws_stack = pero_ws_stack==1; % smaller for debug

figure
hold on

all_mito_faces = [];
all_mito_vertices = [];
mitoXYZ = [];

% labelled_mito = bwlabeln(mito_thresh_stack);
%% Render each mito one segment at a time 
% for mid=32:35  % mid=32 is a mito with hole in it,. dounut shape
% for mid=2  % mid=32 is a mito with hole in it,. dounut shape
% for mid=1:max(labelled_mito(:))
%   mito = labelled_mito==mid;

%   % Render each 2D z-slice of the mito one at a time. This is needed because the 3D render isn't perfect and doesn't display thin 2D slices at all.
%   for z=1:5
%     [Y X] = find(mito(:,:,z));
%     Z = zeros(length(X),1)+z;
%     if isempty(Z)
%       continue
%     end
%     mitoXYZ= [mitoXYZ; X Y Z];

%     % % Draw 2D slice
%     % shp2d = alphaShape(X,Y); % the default behaviour of a 2d render with alphaShape is to draw green slices at z=0, the next line disables this
%     % h2d = plot(shp2d); % hide the green 2d slices
%     % h2d.Visible='off';
%     % faces = h2d.Faces;
%     % vertices = [h2d.Vertices Z.*13]; % we created a two 2D but want to put it in 3D
%     % p = patch('Faces',faces,'Vertices',vertices);
%     % p.FaceColor = 'red';
%     % p.EdgeColor = 'none';

%     % % BUG: Unfortunately point2trimesh has a problem measuring distance to the 2D slices so this is disabled (lets just eliminate single slice peros)
%     % all_mito2d_faces = [all_mito_faces; faces];
%     % all_mito2d_vertices = [all_mito_vertices; vertices];
%   end
% end


all_mito2d_faces = {};
all_mito2d_vertices = {};
for z=1:5
  [Y X] = find(mito_thresh_stack(:,:,z));
  Z = zeros(length(X),1)+z;
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

  % BUG: Unfortunately point2trimesh has a problem measuring distance to the 2D slices so this is disabled (lets just eliminate single slice peros)
  all_mito2d_faces{zid} = faces;
  all_mito2d_vertices{zid} = vertices;
end


% Render 3D mito
shp = alphaShape(mitoXYZ,4);
h = plot(shp);
h.FaceColor = 'red';
h.EdgeColor = 'none';
h.Vertices(:,3) = h.Vertices(:,3) .* 13; % z depth scale factor 13um
all_mito_faces = h.Faces;
all_mito_vertices = h.Vertices;


pero_stats = regionprops3(pero_ws_stack,'Centroid','EquivDiameter');
pero_stats.Centroid(:,3) = pero_stats.Centroid(:,3) .* 13;  % z depth scale factor 13um
%% Render each pero one at a time 
% for pid=54:60
for pid=1:max(pero_ws_stack(:))
  pero = pero_ws_stack==pid;
  peroXYZ = [];
  RENDER_PERO = false;

  if ~RENDER_PERO
    % Draw scatter points instead of rendering with surfaces
    pero_cent_x = pero_stats.Centroid(pid,1);
    pero_cent_y = pero_stats.Centroid(pid,2);
    pero_cent_z = pero_stats.Centroid(pid,3);
    pero_diameter = pero_stats.EquivDiameter(pid);
    scatter3(pero_cent_x, pero_cent_y, pero_cent_z, pero_diameter*10,'green','filled')
  end


  if RENDER_PERO
    % Render each 2D z-slice of the pero one at a time. This is needed because the 3D render isn't perfect and doesn't display thin 2D slices at all.
    for z=1:5
      [Y X] = find(pero(:,:,z));
      Z = zeros(length(X),1)+z;
      if isempty(Z)
        continue
      end
      peroXYZ= [peroXYZ; X Y Z];
      shp2d = alphaShape(X,Y); % the default behaviour of a 2d render with alphaShape is to draw green slices at z=0, the next line disables this
      h2d = plot(shp2d); % hide the green 2d slices
      h2d.Visible='off';
      if isempty(h2d.Faces)
          continue
      end
      vertices = [h2d.Vertices Z];
      p = patch('Faces',h2d.Faces,'Vertices',vertices);
      p.FaceColor = 'green';
      p.EdgeColor = 'none';
    end
    if isempty(peroXYZ)
      continue
    end

    % Render 3D pero
    shp = alphaShape(peroXYZ,4);
    h = plot(shp);
    h.FaceColor = 'green';
    h.EdgeColor = 'none';
  end
end

% Measure distances between pero and mito
FV.faces = all_mito_faces;
FV.vertices = all_mito_vertices;
points = pero_stats.Centroid;
% points = points(54:60,:);

FV.vertices(:,3) = FV.vertices(:,3).*13; % z depth scale factor 13um
points(:,3) = points(:,3).*13; % z depth scale factor 13um
[distances,surface_points] = point2trimesh(FV, 'QueryPoints', points); 
points(:,3) = points(:,3)./13; % z depth scale factor 13um
surface_points(:,3) = surface_points(:,3)./13; % z depth scale factor 13um

plot3M(reshape([shiftdim(points,-1);shiftdim(surface_points,-1);shiftdim(points,-1)*NaN],[],3),'k')

% Style
% daspect([1 1 1/13])
axis tight
view(3)
rotate3d on
%axis off
axis vis3d % disable strech-to-fill
set(gca, 'color','none')
set(gcf, 'color',[1 1 1])
camlight 
lighting gouraud
h.AmbientStrength = 0.3;
h.DiffuseStrength = 0.8;
h.SpecularStrength = 0.9;
h.SpecularExponent = 25;

% axis equal
% zlim([0 7*13]) %% For closer inspecting of one mito 
% xlim([0 1024])
% ylim([0 1024])


%% Simple Animate
% % Rotate the render about the x axis and the y axis with an ease in and out defined by cos()
% frames = 300;
% fps = 1/60
% speedupdown = -cos(linspace(0,pi,frames));
% for i = 1:frames
%    camorbit(1,speedupdown(i)/2);
%    pause(fps);
% end
% % Rotate the render about the x axis
% for i = 1:frames
%    camorbit(1,0);
%    pause(fps);
% end

% Rotate the render about the x axis and the y axis with an ease in and out defined by cos()



%% Animate and save to disk
m = [];
frames = 300;
fps = 1/60;
speedupdown = -cos(linspace(0,pi,frames));

for fid = 1:frames
  camorbit(1,speedupdown(fid)/2);

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
    % figure
    % imshow3Dfull(permute(m,[1 2 4 3]))
  else
    pause(fps)
  end
  % close all
end

% Rotate the render about the x axis
for fid = 1:frames
  camorbit(1,0);

  if SAVE_TO_DISK
    % Store result
    fig_name = sprintf('/distance_visualization type_%s cell_%03d timepoint_%03d frame_%03d',typ, stack_id, tid, fid);
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
    % figure
    % imshow3Dfull(permute(m,[1 2 4 3]))
  else
    pause(fps)
  end
  % close all
end


% Create Gif
if SAVE_TO_DISK
  fig_name = sprintf('/0_gif_distance_visualization type_%s cell_%03d.gif', typ, stack_id);
  save_path = [fig_save_path fig_name];
  colour_imgs_to_gif(m,save_path);
end

