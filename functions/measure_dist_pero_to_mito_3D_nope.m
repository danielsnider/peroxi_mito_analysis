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
    z_depth = size(pero_ws_stack,3);
    timepoints = size(pero_ws_stack,4);

    % Loop over images in this stack 
    for tid=1:timepoints

      im_pero = pero_stack(:,:,:,tid);
      im_pero_ws = pero_ws_stack(:,:,:,tid);
    
      %% Calc X Y Centroids (Pero)
      pero_stats = regionprops(bwlabeln(im_pero_ws),im_pero,'WeightedCentroid','Area','MeanIntensity');
      % PeroCentroidsXY = cat(1,pero_stats.WeightedCentroid);
      PeroCentroidsXY_3D = round(cat(1,pero_stats.WeightedCentroid));

      for zid=1:z_depth
        PeroCentroidsXY = PeroCentroidsXY_3D(PeroCentroidsXY_3D(:,3)==zid,:); % get centroids that are positioned at this zid
          
        %% Get X Y Locations (Mito)
        im_mito = mito_stack(:,:,zid,tid);
        im_mito_thresh = mito_thresh_stack(:,:,zid,tid);
        [Y X] = find(im_mito_thresh);
        MitoLocationsXY = [X Y];

        % Mito Stats
        mito_stats = regionprops(bwlabeln(im_mito_thresh),im_mito,'Area');
        
        %% Calc Distance to Nearest Mito from Pero
        PeroCentroidsXY = PeroCentroidsXY';
        MitoLocationsXY = MitoLocationsXY';

        % Nearest Neighbour
        NearestMitoInd = nearestneighbour(PeroCentroidsXY(1:2,:), MitoLocationsXY);

        TranslationX = MitoLocationsXY(1,NearestMitoInd) - PeroCentroidsXY(1, :);
        TranslationY = MitoLocationsXY(2, NearestMitoInd) - PeroCentroidsXY(2, :);
        [theta,rho] = cart2pol(TranslationX,TranslationY);
        Distances = rho;

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
        s.(typ)(sid).PeroCentroidsXY{zid} = PeroCentroidsXY;
        s.(typ)(sid).MitoLocationsXY{zid} = MitoLocationsXY;
        s.(typ)(sid).NearestMitoInd{zid} = NearestMitoInd;
        s.(typ)(sid).TranslationX{zid} = TranslationX;
        s.(typ)(sid).TranslationY{zid} = TranslationY;
        s.(typ)(sid).Distances{zid} = Distances;

        % More Measurements (Should be another file?)
        s.(typ)(sid).NumPero{zid} = length(PeroCentroidsXY);
        s.(typ)(sid).PeroArea{zid} = cat(1,pero_stats.Area);
        s.(typ)(sid).PeroMeanIntensity{zid} = cat(1,pero_stats.MeanIntensity);
        s.(typ)(sid).PeroTotalIntensity{zid} = s.(typ)(sid).PeroArea{zid} .* s.(typ)(sid).PeroMeanIntensity{zid};
        s.(typ)(sid).MitoArea{zid} = cat(1,mito_stats.Area);
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
