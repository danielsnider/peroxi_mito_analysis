% Loop over stack types
for typ=fields(s)'
  typ=typ{:};

  T=table();
  for sid=1:length(s.(typ))
    if strcmp(IMAGE_PROCESSING_TYPE,'3D')
      timepoints = size(s.(typ)(sid).pero_ws,4);
    elseif strcmp(IMAGE_PROCESSING_TYPE, '2.5D')
      timepoints = size(s.(typ)(sid).pero_ws,3);
    end

    for tid = 1:timepoints
      iterT = table();
      iterT.PeroMeanIntensity = cat(1,s.(typ)(sid).PeroMeanIntensity{tid});
      iterT.PeroTotalIntensity = cat(1,s.(typ)(sid).PeroTotalIntensity{tid});
      iterT.PeroArea = cat(1,s.(typ)(sid).PeroArea{tid});
      if isfield(s.(typ)(sid), 'PeroCentroidsXYZ')
        iterT.PeroCentroid = cat(1,s.(typ)(sid).PeroCentroidsXYZ{tid});
      else
        Z = zeros(height(iterT),1)+3.5; % TODO: fix HARDCODED Z-depth for max projection of slices 3,4!!
        iterT.PeroCentroid = [s.(typ)(sid).PeroCentroidsXY{tid}; Z']';
      end

      num_objects = height(iterT);
      % iterT.CellConvexAreaSqrUM = zeros(num_objects,1)+s.(typ)(sid).ConvexAreaSqrUM(tid);
      iterT.Distance = s.(typ)(sid).Distances{tid}';
      iterT.CellNum = zeros(num_objects,1)+stack_id;
      iterT.Timepoint = zeros(num_objects,1)+tid;
      
      % ImagingType
      ImagingType=cell(num_objects,1);
      ImagingType(:) = {typ};
      iterT.ImagingType = ImagingType;
      
      % ImageProcessingType
      ImageProcessingType=cell(num_objects,1);
      ImageProcessingType(:) = {IMAGE_PROCESSING_TYPE};
      iterT.ImageProcessingType = ImageProcessingType;
      
      T = [T; iterT];
    end

    if ONE_ONLY
      return
    end
  end
end
