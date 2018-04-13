% Simple Animate
% Rotate the render about the x axis and the y axis with an ease in and out defined by cos()
frames = 300;
fps = 1/60
speedupdown = -cos(linspace(0,pi,frames));
for i = 1:frames
   camorbit(1,speedupdown(i)/2);
   pause(fps);
end
% Rotate the render about the x axis
for i = 1:frames
   camorbit(1,0);
   pause(fps);
end