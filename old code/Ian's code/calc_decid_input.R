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

list_crown_decid <- map(df_decid$crown, array_to_numeric)

df_crown_decid <- tibble(
  base = extract_var(list_crown_decid, "base"),
  d1 = extract_var(list_crown_decid, "d1"),
  d2 = extract_var(list_crown_decid, "d2"),
  d3 = extract_var(list_crown_decid, "d3"))

df_crown_decid %<>%
  mutate(crown_vol = calc_decid_crown_vol(d1, d2))

df_crown_decid$crown_vol %>% sum




map_dbl(list_crown_decid, \(vect) vect["base"] %>% unname)


map(df_decid$stem, array_to_numeric)

map(df_decid$primary.branch, array_to_numeric)



map(df_decid$leaf, array_to_numeric)

map(df_decid$crown, array_to_numeric)
map(df_decid$crown[[24]][1], array_to_numeric)
str(df_decid$crown[[24]])
str(df_decid$crown[[24]][1])
value_base <- df_decid$crown[[24]]
value_base <- df_decid$crown[[24]][1]

map(df_decid$stem
  , array_to_numeric)
