

setwd("C:/Users/allen/OneDrive/Desktop/Work/Scripts/Lidar Simulation")
wd <- getwd()

source("process_matlab_util.R")

data_dir <- file.path(wd, "lidarmodeling_202404")
mat_pine <- readMat(file.path(data_dir, "pine001data.mat"))

## read data into array of lists
## "tree" contains the data in the matlab object as a 3D array,
## and [,,] gets all of the contents of that array as a 2D array

## rows correspond to the tree properties (crown, stem, etc.), and columns
## refer to each tree in the dataset
pine <- mat_pine$tree[,,]

df_pine <- tibble(crown = pine[1,],
                  stem = pine[2,],
                  primary.branch = pine[3,],
                  secondary.branch = pine[4,],
                  tertiaries.branch = pine[5,],
                  leaf = pine[6,])

list_crown_pine <- map(df_pine$crown, \(arr) arr %>%
                         extract_first_val_pine)


df_crown_pine <- tibble(base = extract_var(list_crown_pine, "base"),
                        d1 = extract_var(list_crown_pine, "d1"),
                        d2 = extract_var(list_crown_pine, "d2"),
                        d3 = extract_var(list_crown_pine, "d3"))

df_crown_pine %<>%
  mutate(crown_vol = calc_pine001_crown_vol(d1, d2, d3))

df_crown_pine$crown_vol %>% sum

## calculate crown volume
