setwd("C:/Users/allen/OneDrive/Desktop/Work/Scripts/Lidar Simulation")
wd <- getwd()

source("process_matlab_util.R")

data_dir <- file.path(wd, "lidarmodeling_202404")
mat_deciduous <- readMat(file.path(data_dir, "deciduous001data.mat"))

decid <- mat_deciduous$tree[,,]

df_decid <- tibble(crown = decid[1,],
                   stem = decid[2,],
                   primary.branch = decid[3,],
                   secondary.branch = decid[4,],
                   tertiaries.branch = decid[5,],
                   leaf = decid[6,])

decid_leaf_areas <- map_dbl(df_decid$leaf, calc_leaf_area_of_tree)
total_leaf_area_decid <- decid_leaf_areas %>% sum

primary_branch_area_decid <- map_dbl(df_decid$primary.branch,
                                     calc_branch_area_of_tree) %>% sum
secondary_branch_area_decid <- map_dbl(df_decid$secondary.branch,
                                       calc_branch_area_of_tree) %>% sum
tertiary_branch_area_decid <- map_dbl(df_decid$tertiaries.branch,
                                      calc_branch_area_of_tree) %>% sum

total_branch_area_decid <-
  primary_branch_area_decid +
  secondary_branch_area_decid +
  tertiary_branch_area_decid