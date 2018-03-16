


% Loop over stack types
for typ=fields(s_mid)'
  typ=typ{:};


  T=table();
  T.Distances = [s_mid.(typ).Distances{:}]';
  T.PeroArea = cat(1,s_mid.(typ).PeroArea{:});
  T.PeroMeanIntensity = cat(1,s_mid.(typ).PeroMeanIntensity{:});
  T.PeroTotalIntensity = cat(1,s_mid.(typ).PeroTotalIntensity{:});

  filename = sprintf('%s/peroxisome_stats_%s.csv',fig_save_path,typ);
  writetable(T,filename);
end
