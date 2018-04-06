z = 0.0001
img_smooth = imgaussfilt3(s_pero,[4 4 4],'FilterSize',[19 19 3]); 
figure; imshow3Dfull(img_smooth, []);