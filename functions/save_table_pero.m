


% Loop over stack types
for typ=fields(s_mid)'
  typ=typ{:};

  T=table();
  for image_id = 1:length(s_mid.(typ).Distances)

    Distances = s_mid.(typ).Distances{image_id};
    iterT = table();
    iterT.ImageNum = zeros(length(Distances),1)+image_id;
    iterT.Distances = Distances';
    iterT.PeroArea = cat(1,s_mid.(typ).PeroArea{image_id});
    iterT.PeroMeanIntensity = cat(1,s_mid.(typ).PeroMeanIntensity{image_id});
    iterT.PeroTotalIntensity = cat(1,s_mid.(typ).PeroTotalIntensity{image_id});
    T = [T; iterT];
  end

  filename = sprintf('%s/peroxisome_stats_%s.csv',fig_save_path,typ);
  writetable(T,filename);
end
