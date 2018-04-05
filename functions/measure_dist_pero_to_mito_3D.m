log_msg(sprintf('[%s]: %s', mfilename(), 'Measuring distances...'));

% Loop over stack types
for typ=fields(s)'
  typ=typ{:};

  % Loop over stacks
  for sid=1:length(s.(typ))
    pero_stack = s.(typ)(sid).pero;
    mito_stack = s.(typ)(sid).mito;
    pero_ws_stack = s.(typ)(sid).pero_ws;
    mito_thresh_stack = s.(typ)(sid).mito_thresh;
    timepoints = size(pero_ws_stack,3);

    % Loop over images in this stack 
    for tid=1:timepoints
      im_pero = pero_stack(:,:,tid);
      im_mito = mito_stack(:,:,tid);
      im_pero_ws = pero_ws_stack(:,:,tid);
      im_mito_thresh = mito_thresh_stack(:,:,tid);
      
      %% Get X Y Locations (Mito)
      [Y X] = find(im_mito_thresh);
      MitoLocationsXY = [X Y];
      %% Calc X Y Centroids (Pero)
      pero_stats = regionprops(bwlabel(im_pero_ws),im_pero,'Centroid','Area','MeanIntensity');
      if length(pero_stats)
        PeroCentroidsXY = round(cat(1,pero_stats.Centroid));
        PeroCentroidsXYInd = sub2ind(size(im_pero_ws), PeroCentroidsXY(:,2),PeroCentroidsXY(:,1));
        %  Make new image with pero centers marked with a 1
        % im_pero_centroids = zeros(size(im_pero_ws));
        % im_pero_centroids(PeroCentroidsXYInd)=1;

        % Mito Stats
        mito_stats = regionprops(bwlabel(im_mito_thresh),im_mito,'Centroid','Area','MeanIntensity');
        
        %% Calc Distance to Nearest Mito from Pero
        PeroCentroidsXY = PeroCentroidsXY';
        MitoLocationsXY = MitoLocationsXY';
        NearestMitoInd = nearestneighbour(PeroCentroidsXY, MitoLocationsXY);
        TranslationX = MitoLocationsXY(1,NearestMitoInd) - PeroCentroidsXY(1, :);
        TranslationY = MitoLocationsXY(2, NearestMitoInd) - PeroCentroidsXY(2, :);
        [theta,rho] = cart2pol(TranslationX,TranslationY);
        Distances = rho;

        if EDGE_TO_EDGE_DISTANCE
          %% Measure not from center but edge
          % This could be done with linear algebra
          pero_boundaries = regionprops(bwlabel(bwperim(im_pero_ws)),'Image');
          for idx=1:length(pero_boundaries)
            pero_boundary = pero_boundaries(idx).Image;
            [Y,X]=find(pero_boundary);
            % Find 
            X2=X-size(pero_boundary,2)/2-0.5;
            Y2=Y-size(pero_boundary,1)/2-0.5;
            this_segment_theta = theta(idx);
            [theta_,rho_] = cart2pol(X2,Y2);
            [min_val, min_idx] = min(abs(theta_-this_segment_theta));
            Distances(idx) = Distances(idx) - rho_(min_idx);
          end
          Distances(Distances<0)=0;
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
      s.(typ)(sid).PeroCentroidsXY{tid} = PeroCentroidsXY;
      s.(typ)(sid).MitoLocationsXY{tid} = MitoLocationsXY;
      s.(typ)(sid).NearestMitoInd{tid} = NearestMitoInd;
      s.(typ)(sid).TranslationX{tid} = TranslationX;
      s.(typ)(sid).TranslationY{tid} = TranslationY;
      s.(typ)(sid).Distances{tid} = Distances;

      % More Measurements (Should be another file?)
      s.(typ)(sid).NumPero{tid} = length(PeroCentroidsXY);
      s.(typ)(sid).PeroArea{tid} = cat(1,pero_stats.Area);
      s.(typ)(sid).PeroMeanIntensity{tid} = cat(1,pero_stats.MeanIntensity);
      s.(typ)(sid).PeroTotalIntensity{tid} = s.(typ)(sid).PeroArea{tid} .* s.(typ)(sid).PeroMeanIntensity{tid};
      s.(typ)(sid).MitoArea{tid} = cat(1,mito_stats.Area);
      s.(typ)(sid).MitoAreaDivNumPero{tid} =  sum(s.(typ)(sid).MitoArea{tid}) / s.(typ)(sid).NumPero{tid};
      s.(typ)(sid).PeroAreaDivMitoArea{tid} = sum(s.(typ)(sid).PeroArea{tid}) ./ sum(s.(typ)(sid).MitoArea{tid});

      % Debug
  %     figure
  %     scatter(MitoLocationsXY(1,:), MitoLocationsXY(2,:), 'b')
  %     hold on
  %     scatter(PeroCentroidsXY(1,:), PeroCentroidsXY(2,:), 'r')
  %     quiver(PeroCentroidsXY(1, :), PeroCentroidsXY(2, :), MitoLocationsXY(1,NearestMitoInd) - PeroCentroidsXY(1, :), MitoLocationsXY(2, NearestMitoInd) - PeroCentroidsXY(2, :), 0, 'k');
  %     hold off
  %     set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');


    end
    if ONE_ONLY
      return
    end
  end
end
