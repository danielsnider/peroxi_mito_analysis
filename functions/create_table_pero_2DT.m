


% Loop over stack types
for typ=fields(s)'
  typ=typ{:};

  T=table();
  for sid=1:length(s.(typ))
    timepoints = size(s.(typ)(sid).pero_ws,3);
    for tid = 1:timepoints
      iterT = table();
      iterT.PeroMeanIntensity = cat(1,s.(typ)(sid).PeroMeanIntensity{tid});
      iterT.PeroTotalIntensity = cat(1,s.(typ)(sid).PeroTotalIntensity{tid});
      iterT.PeroArea = cat(1,s.(typ)(sid).PeroArea{tid});
      iterT.PeroCentroid = cat(1,s.(typ)(sid).PeroCentroidsXY{tid})';

      num_objects = height(iterT);
      iterT.CellConvexAreaPX = zeros(num_objects,1)+s.(typ)(sid).ConvexAreaPX(tid);
      % iterT.CellConvexAreaSqrUM = zeros(num_objects,1)+s.(typ)(sid).ConvexAreaSqrUM(tid);
      iterT.Distance = s.(typ)(sid).Distances{tid}';
      iterT.CellNum = zeros(num_objects,1)+stack_id;
      iterT.Timepoint = zeros(num_objects,1)+tid;
      
      % ImagingType
      ImagingType=cell(num_objects,1);
      ImagingType(:) = {typ};
      iterT.ImagingType = ImagingType;
      
      T = [T; iterT];
    end

    if ONE_ONLY
      return
    end
  end
end
