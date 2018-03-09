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
    stats = regionprops(bwlabel(im_pero_ws),'Centroid');
    PeroCentroidsXY = round(cat(1,stats.Centroid));
    PeroCentroidsXYInd = sub2ind(size(im_pero_ws), PeroCentroidsXY(:,2),PeroCentroidsXY(:,1));
    %  Make new image with pero centers marked with a 1
    % im_pero_centroids = zeros(size(im_pero_ws));
    % im_pero_centroids(PeroCentroidsXYInd)=1;
    
    %% Calc Distance to Nearest Mito from Pero
    PeroCentroidsXY = PeroCentroidsXY';
    MitoLocationsXY = MitoLocationsXY';
    NearestMitoInd = nearestneighbour(PeroCentroidsXY, MitoLocationsXY);
    TranslationX = MitoLocationsXY(1,NearestMitoInd) - PeroCentroidsXY(1, :);
    TranslationY = MitoLocationsXY(2, NearestMitoInd) - PeroCentroidsXY(2, :);
    [theta,rho] = cart2pol(TranslationX,TranslationY);
    Distances = rho;

    % Store Result
    s_mid.(typ).PeroCentroidsXY{z} = PeroCentroidsXY;
    s_mid.(typ).MitoLocationsXY{z} = MitoLocationsXY;
    s_mid.(typ).NearestMitoInd{z} = NearestMitoInd;
    s_mid.(typ).TranslationX{z} = TranslationX;
    s_mid.(typ).TranslationY{z} = TranslationY;
    s_mid.(typ).Distances{z} = Distances;

    % More Measurements (Should be another file?)
    s_mid.(typ).NumPero{z} = length(PeroCentroidsXY);
    s_mid.(typ).NumPeroDivMitoArea{z} = length(PeroCentroidsXY);
    s_mid.(typ).PeroAreaDivMitoArea{z} = length(PeroCentroidsXY);

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
