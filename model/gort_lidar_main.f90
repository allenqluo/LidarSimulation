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

  ! read GORT parameters
  Format_n = "(i2)"
  FormatIn  = "(11(f13.4),i2)"
  
  OPEN(1, FILE=fgin)   
  READ(1, format_n) n_height_level
  print *, n_height_level

  !skip the header line
  !READ(1, *)

  !n_height_level=1
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
  WRITE(1, "(a10,6(f9.3))") "GORT input:",(convolute_input(i)%dens_tree,convolute_input(i)%dens_foliage, & 
                            convolute_input(i)%horz_radius,convolute_input(i)%vert_radius, &
                            convolute_input(i)%h1, convolute_input(i)%h2,i=1,N_height_level)
  WRITE(1, "(a10,2(f8.5))") "gamma:",(gamma(i),i=1,N_height_level)
  do i=1, size(height_levels)
    !WRITE(1, "(9(f10.6))") height_levels(i),fp(i),efp(i), pgap(i,1),pgap(i,2), dpdz(i,1),dpdz(i,2), wvfm(i,1),wvfm(i,2)
    WRITE(1, "(6(f10.6))") height_levels(i),fp(i),efp(i), pgap(i,1), dpdz(i,1), wvfm(i,1)
    !WRITE(1, "(6(f10.6))") height_levels(i),fp(i),efp(i), pgap(i,2), dpdz(i,2), wvfm(i,2)
  end do
  close(1)  

  
END Program gort_lidar_main
  
 