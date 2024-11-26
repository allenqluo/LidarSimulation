library(R.matlab)
library(tidyverse)
library(magrittr)
library(purrr)

### Data Processing

extract_first_val_pine <- function(my_array) {
    ## pine dataset contains two sets of values for each crown.
    ## extract just the first set of values from a crown
    my_list <- my_array[,1,1]
    map_dbl(my_list, \(vect) vect[[1]])
}

array_to_numeric <- function(my_array) {
  ## convert an array with one row to a named numeric vector
  row_names <- rownames(my_array)
  ans <- my_array %>% as.numeric
  names(ans) <- row_names
  ans
}

extract_var <- function(my_list, my_name) {
  ## my_list should be a list of named numeric vectors, each of which
  ## contains exactly one element named my_name
  map_dbl(my_list, \(vect) vect[my_name] %>% unname)
}

### Leaf Area Calculation

calc_rect_area <- function(length, width) {
  length * width
}

calc_leaf_area <- function(d1, d2) {
  calc_rect_area(d1, d2)
}

calc_leaf_area_of_tree <- function(leaf_array) {
  ## extract numeric vectors of leaf parameters
  d1_vect <- leaf_array["d1",,][[1]] %>% as.numeric
  d2_vect <- leaf_array["d2",,][[1]] %>% as.numeric
  map2_dbl(d1_vect, d2_vect, calc_leaf_area) %>% sum
}

### Branch Area Calculation

## find the lateral surface area of a truncuated cone
## (i.e. surface area excluding circles on the top and bottom)
calc_trunc_cone_lat_SA <- function(l, r1, r2) {
  pi * l * (r1 + r2)
}

calc_branch_SA <- function(l, start.radius, end.radius) {
  calc_trunc_cone_lat_SA(l = l,
                         r1 = start.radius,
                         r2 = end.radius)
}

calc_branch_area_of_tree <- function(branch_array) {
  l_vect <- branch_array["l",,][[1]] %>% as.numeric
  start.radius_vect <- branch_array["start.radius",,][[1]] %>% as.numeric
  end.radius_vect <- branch_array["end.radius",,][[1]] %>% as.numeric
  pmap_dbl(list(l_vect, start.radius_vect, end.radius_vect),
           calc_branch_SA) %>% sum
}

### Deciduous Crown Volume Calculation

calc_decid_crown_vol <- function(d1, d2) {
  calc_spheroid_vol(h_rad = d2,
                    v_rad = d1)
}

calc_spheroid_vol <- function(v_rad, h_rad) {
  (4/3) * pi * v_rad * (h_rad ^ 2)
}

### Pine Crown Volume Calculation

calc_pine001_crown_vol <- function(d1, d2, d3) {
  top = calc_spheroid_vol(v_rad = d1,
                          h_rad = d2) / 2
  bottom = calc_cyl_vol(height = d3,
                        radius = d2)
  top + bottom
}

calc_cyl_vol <- function(height, radius) {
  pi * radius ^ 2 * height
}