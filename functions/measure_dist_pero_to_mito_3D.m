log_msg(sprintf('[%s]: %s', mfilename(), 'Measuring distances...'));

z_step_um = 0.34;
pixel_step_um = 0.02405; % 1 step 
num_pixels_in_one_z_step = z_step_um / pixel_step_um;

% Loop over stack types
for typ=fields(s)'
  typ=typ{:};

  % Loop over stacks
  for sid=1:length(s.(typ))
    pero_stack = s.(typ)(sid).pero;
    mito_stack = s.(typ)(sid).mito;
    pero_ws_stack = s.(typ)(sid).pero_ws;
    mito_thresh_stack = s.(typ)(sid).mito_thresh;
    z_depth = size(pero_ws_stack,3);
    timepoints = size(pero_ws_stack,4);

    % Loop over images in this stack 
    for tid=1:timepoints
      Distances = cell(z_depth,1);
      NearestMitoInd = cell(z_depth,1);
      PeroCentroidsXY = cell(z_depth,1);

      im_pero = pero_stack(:,:,:,tid);
      im_pero_ws = pero_ws_stack(:,:,:,tid);
    
      %% Calc X Y Centroids (Pero)
      pero_stats = regionprops(bwlabeln(im_pero_ws),im_pero,'WeightedCentroid','Area','MeanIntensity');
      PeroCentroidsXYZ = cat(1,pero_stats.WeightedCentroid);
      PeroCentroidsXY_ = PeroCentroidsXYZ(:,1:2)'; % get just X and Y
      PeroCentroidsZ = PeroCentroidsXYZ(:,3);
      PeroCentroidsXYZ_rounded = round(cat(1,pero_stats.WeightedCentroid));

      % Loop over z slices looking for the closest mito for each pero at this z, one of the z's is the closest
      for zid=1:z_depth
        %% Get X Y Locations (Mito)
        im_mito = mito_stack(:,:,zid,tid);
        im_mito_thresh = mito_thresh_stack(:,:,zid,tid);
        [Y X] = find(im_mito_thresh);
        MitoLocationsXY = [Y X];

        % Mito Stats
        mito_stats = regionprops(bwlabel(im_mito_thresh),im_mito,'Area');
        
        %% Calc Distance to Nearest Mito from Pero
        % PeroCentroidsXY = PeroCentroidsXY';
        MitoLocationsXY = MitoLocationsXY';

        % Repeat MitoLocationsXY once for each z_depth. We want to compare 
        % MitoLocationsXY = repmat(MitoLocationsXY,1,z_depth);

        % Nearest Neighbour
        NearestMitoInd_ = nearestneighbour(PeroCentroidsXY_, MitoLocationsXY);
        TranslationX = MitoLocationsXY(1,NearestMitoInd_) - PeroCentroidsXY_(1, :);
        TranslationY = MitoLocationsXY(2, NearestMitoInd_) - PeroCentroidsXY_(2, :);
        
        % Calculate the z distance in pixels (not z slice count) from the current z index to each pero 
        PeroCentroidsZ_with_step_factor = abs((PeroCentroidsZ-zid)*num_xy_steps_in_one_z_step);
        TranslationZ = PeroCentroidsZ_with_step_factor';

        % Convert manhantten distance to euclidian
        [azimuth,elevation,r] = cart2sph(TranslationX,TranslationY,TranslationZ);

        % Find the shortest distance for each pero to mito from all distances
        for zii=1:z_depth
          pero_roughly_at_z_bool = PeroCentroidsXYZ_rounded(:,3)==zii;
          num_pero_roughly_at_z = sum(pero_roughly_at_z_bool); % roughly at z because it's rounded, and it's rounded because we have to store the data somewhere, so we are storing the pero's distance to nearest mito on the nearest z index: s.(typ)(sid).Distances{zii}

          % r contains the distances for all pero, but we are looping one z at a time so get a subset
          pero_dist_roughly_at_z = r(pero_roughly_at_z_bool);
          NearestMitoInd__ = NearestMitoInd_(pero_roughly_at_z_bool);
          PeroCentroidsX__ = PeroCentroidsXY_(1, pero_roughly_at_z_bool);
          PeroCentroidsY__ = PeroCentroidsXY_(2, pero_roughly_at_z_bool);

          % Loop over each pero and check to see if we found a shorter distance at this z
          for pid=1:num_pero_roughly_at_z
            % Get the distance for just one pero
            one_dist_mito_to_pero = pero_dist_roughly_at_z(pid);
            NearestMitoInd___ = NearestMitoInd__(pid);
            PeroCentroidsX___ = PeroCentroidsX__(pid);
            PeroCentroidsY___ = PeroCentroidsY__(pid);

            is_there_an_existing_distance_measurement = pid < length(Distances{zii});
            if is_there_an_existing_distance_measurement
              % Check if the distance between this z and the nearest mito is smaller than was already found
              if one_dist_mito_to_pero < Distances{zii}(pid)
                % smaller distance found, save it
                Distances{zii}(pid) = one_dist_mito_to_pero;
                NearestMitoInd{zii}(pid) = NearestMitoInd___;
                PeroCentroidsXY{zii}(pid,1) = PeroCentroidsY___;
                PeroCentroidsXY{zii}(pid,2) = PeroCentroidsX___;
                NearestMitoXY{zii}(pid,1) = MitoLocationsXY(1, NearestMitoInd___);
                NearestMitoXY{zii}(pid,2) = MitoLocationsXY(2, NearestMitoInd___);
              end
            else
              % A distance for this pero id is not set so set it
              Distances{zii}(pid) = one_dist_mito_to_pero; % set it
              NearestMitoInd{zii}(pid) = NearestMitoInd___;
              PeroCentroidsXY{zii}(pid,1) = PeroCentroidsY___;
              PeroCentroidsXY{zii}(pid,2) = PeroCentroidsX___;
              NearestMitoXY{zii}(pid,1) = MitoLocationsXY(1, NearestMitoInd___);
              NearestMitoXY{zii}(pid,2) = MitoLocationsXY(2, NearestMitoInd___);
            end
          end
        end

        % Handle no objects found
        if length(pero_stats)==0
          mito_stats = pero_stats;
          PeroCentroidsXY = [];
          MitoLocationsXY = [];
          NearestMitoInd = [];
          TranslationX = [];
          TranslationY = [];
          Distances = [];
        end

        % Store Result
        s.(typ)(sid).PeroCentroidsXY = PeroCentroidsXY;
        s.(typ)(sid).MitoLocationsXY{zid} = MitoLocationsXY;
        s.(typ)(sid).NearestMitoInd = NearestMitoInd;
        s.(typ)(sid).NearestMitoXY = NearestMitoXY;
        % s.(typ)(sid).TranslationX{zid} = TranslationX;
        % s.(typ)(sid).TranslationY{zid} = TranslationY;
        s.(typ)(sid).Distances = Distances;

        % More Measurements (Should be another file?)
        % s.(typ)(sid).NumPero{tid} = length(PeroCentroidsXY);
        s.(typ)(sid).NumPero{zid} = 666666666; % TODO: see above but check it works for 3d???
        s.(typ)(sid).PeroArea{zid} = cat(1,pero_stats.Area);
        s.(typ)(sid).PeroMeanIntensity{zid} = cat(1,pero_stats.MeanIntensity);
        s.(typ)(sid).PeroTotalIntensity{zid} = s.(typ)(sid).PeroArea{zid} .* s.(typ)(sid).PeroMeanIntensity{zid};
        s.(typ)(sid).MitoArea{zid} = cat(1,mito_stats.Area); % TODO: IS THIS CORRECT??? Is it not changed in the loop, or?
        s.(typ)(sid).MitoAreaDivNumPero{zid} =  sum(s.(typ)(sid).MitoArea{zid}) / s.(typ)(sid).NumPero{zid};
        s.(typ)(sid).PeroAreaDivMitoArea{zid} = sum(s.(typ)(sid).PeroArea{zid}) ./ sum(s.(typ)(sid).MitoArea{zid});
      end

      %% Debug
      % figure
      % scatter(MitoLocationsXY(1,:), MitoLocationsXY(2,:), 'b')
      % hold on
      % scatter(PeroCentroidsXY(1,:), PeroCentroidsXY(2,:), 'r')
      % quiver(PeroCentroidsXY(1, :), PeroCentroidsXY(2, :), MitoLocationsXY(1,NearestMitoInd) - PeroCentroidsXY(1, :), MitoLocationsXY(2, NearestMitoInd) - PeroCentroidsXY(2, :), 0, 'k');
      % hold off
      % set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');

      if ONE_ONLY
        return
      end
    end
  end
end
