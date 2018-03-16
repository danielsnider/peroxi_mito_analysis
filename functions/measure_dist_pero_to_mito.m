log_msg(sprintf('[%s]: %s', mfilename(), 'Measuring distances...'));

% Loop over stack types
for typ=fields(s_mid)'
  typ=typ{:};
  pero_stack = s_mid.(typ).pero;
  mito_stack = s_mid.(typ).mito;
  pero_ws_stack = s_mid.(typ).pero_ws;
  mito_thresh_stack = s_mid.(typ).mito_thresh;
  z_depth = size(s_mid.(typ).pero,3);

  % Loop over images in this stack (NOTE: variable name 'z' should really be 'stack_id')
  for z=1:z_depth
    im_pero = pero_stack(:,:,z);
    im_mito = mito_stack(:,:,z);
    im_pero_ws = pero_ws_stack(:,:,z);
    im_mito_thresh = mito_thresh_stack(:,:,z);
    
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
    s_mid.(typ).PeroCentroidsXY{z} = PeroCentroidsXY;
    s_mid.(typ).MitoLocationsXY{z} = MitoLocationsXY;
    s_mid.(typ).NearestMitoInd{z} = NearestMitoInd;
    s_mid.(typ).TranslationX{z} = TranslationX;
    s_mid.(typ).TranslationY{z} = TranslationY;
    s_mid.(typ).Distances{z} = Distances;

    % More Measurements (Should be another file?)
    s_mid.(typ).NumPero{z} = length(PeroCentroidsXY);
    s_mid.(typ).PeroArea{z} = cat(1,pero_stats.Area);
    s_mid.(typ).PeroMeanIntensity{z} = cat(1,pero_stats.MeanIntensity);
    s_mid.(typ).PeroTotalIntensity{z} = s_mid.(typ).PeroArea{z} .* s_mid.(typ).PeroMeanIntensity{z};
    s_mid.(typ).MitoArea{z} = cat(1,mito_stats.Area);
    s_mid.(typ).MitoAreaDivNumPero{z} =  sum(s_mid.(typ).MitoArea{z}) / s_mid.(typ).NumPero{z};
    s_mid.(typ).PeroAreaDivMitoArea{z} = sum(s_mid.(typ).PeroArea{z}) ./ sum(s_mid.(typ).MitoArea{z});

    % Debug
%     figure
%     scatter(MitoLocationsXY(1,:), MitoLocationsXY(2,:), 'b')
%     hold on
%     scatter(PeroCentroidsXY(1,:), PeroCentroidsXY(2,:), 'r')
%     quiver(PeroCentroidsXY(1, :), PeroCentroidsXY(2, :), MitoLocationsXY(1,NearestMitoInd) - PeroCentroidsXY(1, :), MitoLocationsXY(2, NearestMitoInd) - PeroCentroidsXY(2, :), 0, 'k');
%     hold off
%     set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');


  end
end
