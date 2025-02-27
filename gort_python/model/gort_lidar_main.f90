Program gort_lidar_main
  
  !Lidar GORT model: modified Ping's and Wenze's code by WNM on  May 19, 2010
  
  use gort_lidar
  
  implicit none
  
  real, parameter :: pi = 3.1415926535897932
  
  real, dimension(:), pointer :: height_levels ! height levels
  real, dimension(:), pointer :: fp, efp, pgap(:,:), dpdz(:,:), wvfm(:,:) 
  integer :: i, n_height_level, sel
  real, dimension(:), pointer :: G(:), gamma(:)  ! leaf orientation and clumping factors
  
  type(gort_input), pointer :: convolute_input(:)
  ! Following line has been modified by Ping, please verify.
  ! type(gort_input), dimension(:), allocatable :: convolute_input
  type(gort_input) :: single_input 
 
  CHARACTER(LEN=30) :: Format_n, FormatIn
  CHARACTER(LEN=10), parameter :: fgin = "gort.in"
  CHARACTER(LEN=10), parameter :: fgout = "gort.out"
  
  !For Maine study:1:conifer:hemlock and 2:deciduous:apsen

  !plant function type 1: conifer-- hemlock   
  !convolute_input(1)%dens_tree = 0.066
  !convolute_input(1)%dens_foliage = 2.200
  !convolute_input(1)%h1 = 6.991
  !convolute_input(1)%h2 = 17.91
  !convolute_input(1)%dz = 0.1 !in m
  !convolute_input(1)%horz_radius = 0.972
  !convolute_input(1)%vert_radius = 0.972*1.614
  !convolute_input(1)%zenith = 0
  !convolute_input(1)%rhol = 0.4291 !leaf reflectance
  !convolute_input(1)%taul = 0.4239 !leaf transmittance 
  !convolute_input(1)%rhos = 0.35156 !surface albedo
  !convolute_input(1)%pft = 1       !plant function type
  
  ! plant function type 2: deciduous   
  !convolute_input(2)%dens_tree = 0.013
  !convolute_input(2)%dens_foliage = 1.00
  !convolute_input(2)%h1 = 25.66
  !convolute_input(2)%h2 = 36.89
  !convolute_input(2)%dz = 0.1 
  !convolute_input(2)%horz_radius = 3.325
  !convolute_input(2)%vert_radius = 3.325*2.038
  !convolute_input(2)%zenith = 0  !off-nadir pointing angle
  !convolute_input(2)%rhol = 0.4312 !leaf reflectance
  !convolute_input(2)%taul = 0.47763 !leaf transmittance 
  !convolute_input(2)%rhos = 0.35156 !surface albedo
  !convolute_input(2)%pft = 7       !plant function type
  
  !  16 CLM plant function types:
  !1: needleleaf_evergreen_temperate_tree   
  !2: needleleaf_evergreen_boreal_tree      
  
  !3: needleleaf_deciduous_boreal_tree      
  
  !4: broadleaf_evergreen_tropical_tree     
  !5: broadleaf_evergreen_temperate_tree    
  
  !6: broadleaf_deciduous_tropical_tree     
  !7: broadleaf_deciduous_temperate_tree    
  !8: broadleaf_deciduous_boreal_tree       
  
  !9: broadleaf_evergreen_shrub             
  !10:broadleaf_deciduous_temperate_shrub   
  !11:broadleaf_deciduous_boreal_shrub      
  
  !12:c3_arctic_grass                       
  !13:c3_non-arctic_grass                   
  !14:c4_grass                              
  
  !15:crop 1: e.g.corn                                  
  !16:crop 2: e.g.wheat                                 
  

  ! read GORT parameters
  Format_n = "(i2)"
  FormatIn  = "(11(f13.4),i2)"
  
  OPEN(1, FILE=fgin)   
  READ(1, format_n) n_height_level
  print *, n_height_level

  !skip the header line
  !READ(1, *)

  n_height_level=1
  allocate(convolute_input(n_height_level))
  !read GORT parameter
  print *, n_height_level
 
  do i=1, n_height_level
     print *, i
 !    READ(1, FormatIn) convolute_input(i)
    READ(1, *) convolute_input(i)
     print *, convolute_input(i)%dens_tree
     print *, convolute_input(i)%dens_foliage 
     print *, convolute_input(i)%h1, convolute_input(i)%h2
     print *, convolute_input(i)%dz
     print *, convolute_input(i)%horz_radius
     print *, convolute_input(i)%vert_radius 
  end do

  allocate(G(n_height_level))
  allocate(gamma(n_height_level))

  !Run convolute gort
  if (n_height_level .eq. 1) then
    call run_gort(convolute_input(1), height_levels,G(1),gamma(1), fp, efp, pgap, dpdz, wvfm)
  else
    call run_gort(convolute_input,height_levels,G,gamma, fp, efp, pgap, dpdz, wvfm)
  end if
  !write gort output	
  open(1, file='gort.out', form='FORMATTED')

  WRITE(1, "(i4,f12.4)") size(height_levels),convolute_input(1)%dz
  WRITE(1, "(a10,2(f8.5))") "G:",(G(i),i=1,N_height_level)
  WRITE(1, "(a10,2(f8.5))") "gamma:",(gamma(i),i=1,N_height_level)
  do i=1, size(height_levels)
    !WRITE(1, "(9(f10.6))") height_levels(i),fp(i),efp(i), pgap(i,1),pgap(i,2), dpdz(i,1),dpdz(i,2), wvfm(i,1),wvfm(i,2)
    WRITE(1, "(6(f10.6))") height_levels(i),fp(i),efp(i), pgap(i,1), dpdz(i,1), wvfm(i,1)
    !WRITE(1, "(6(f10.6))") height_levels(i),fp(i),efp(i), pgap(i,2), dpdz(i,2), wvfm(i,2)
  end do
  close(1)  

  
END Program gort_lidar_main
  
 