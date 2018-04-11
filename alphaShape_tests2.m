%close all

pero_ws_stack = bwlabeln(s.(typ)(sid).pero_ws);
mito_thresh_stack = s.(typ)(sid).mito_thresh;

labelled_mito = bwlabeln(mito_thresh_stack);


figure
hold on 
for mid=32  % a mito with hole in it,. dounut shape
%for mid=1:height(stats)
  mito = labelled_mito==mid;
  mitoXYZ = [];
  for z=1:5
    [Y X] = find(mito(:,:,z));
    Z = zeros(length(X),1)+z;
    if isempty(Z)
      continue
    end
    mitoXYZ= [mitoXYZ; X Y Z];
    shp2d = alphaShape(X,Y);
    h2d = plot(shp2d);
    h2d.Visible='off';
    p = patch('Faces',h2d.Faces,'Vertices',[h2d.Vertices Z]);
    p.FaceColor = 'red';
    p.EdgeColor = 'none';
  end
  if isempty(mitoXYZ)
    continue
  end
  shp = alphaShape(mitoXYZ,4);
  h = plot(shp);
  h.FaceColor = 'red';
  h.EdgeColor = 'none';
end 
daspect([1 1 1/13])
axis tight
view(3)
rotate3d on
axis off
axis vis3d % disable strech-to-fill
set(gca, 'color','none')
set(gcf, 'color',[1 1 1])
camlight 
lighting gouraud
h.AmbientStrength = 0.3;
h.DiffuseStrength = 0.8;
h.SpecularStrength = 0.9;
h.SpecularExponent = 25;

frames = 60;
fps = 1/60
speedupdown = -cos(linspace(0,pi,frames));
for i = 1:frames
   camorbit(1,speedupdown(i)/2);
   %camlight(h,'left')
   pause(fps);
end
for i = 1:frames

   camorbit(1,0);
   %camlight(h,'left')
   pause(fps);
end
