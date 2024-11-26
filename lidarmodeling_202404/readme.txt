Wenge,

I put up the simulated data for 2 kinds :  CA Redwood and Tropical forest of French Guiana.  Location is on google drive at:

https://drive.google.com/drive/folders/1L50k34Zo0zh0tJZLZEcIcjJC7AwYQNq8

I also sent along ppt file which illustrate a summary of simulation geometry.  I adjust simulation domain to be a circle with radius of 48 m so that we can fit 9 lidar pixel of 25 m diameter.  In the google drive, you will see subdir  FG005 (for French Guiana) and RW005 (for CA Redwood).  In each, there are 2 files:  alltreeinfo.mat and full_mod.log.   If you load alltreeinfo, you will get  
(1) ‘tree’ structure that contains all the information of the components of the tree ( trunk , crown , branches and leaves )
(2) ‘tree_x’, ‘tree_y’, ‘tree_h’, ‘tree_r’    which are the location in x, y,  height and the crown radius of each tree
(3) ‘tree_px’, tree_py’  which are  x index and y index telling pixel number that tree belongs to.  For example,  if  tree_px(10) = 1, tree_px(10) = 2,  then  tree # 10 is in pixel (1,2).  If any of tree_px or tree_py or both is Nan, that mean that tree is not in any lidar pixel.

If you have any question, let me know.

Sermsak 


