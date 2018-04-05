

o=squeeze(s.decon_zoom.pero(:,:,4,:));
o=o(120:185,420:500,:);
imgs_to_gif(o);

pause(1)
o=squeeze(s.decon_zoom.pero(:,:,5,:));
o=o(120:185,420:500,:);
imgs_to_gif(o);

pause(1)
PROJECTION_TYPE='max'
get_projection
o=squeeze(s.decon_zoom.pero_mid);
o=o(120:185,420:500,:);
imgs_to_gif(o);
pause(1)

PROJECTION_TYPE='sum'
get_projection
o=squeeze(s.decon_zoom.pero_mid);
o=o(120:185,420:500,:);
imgs_to_gif(o);
