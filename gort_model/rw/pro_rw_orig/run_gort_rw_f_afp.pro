pro run_gort

 tek_color
  ; Setting plotting
  set_plot,'ps'
  
  ;device, file= 'comp.eps', /color,/TIMES,/BOLD,/portrait, ysize=28, YOFFSET=0, xsize=21, xOFFSET=0.0
  device, file= 'rw_f_afp.eps', /TIMES,/BOLD,/portrait, ysize=28, YOFFSET=0, xsize=21, xOFFSET=0.0
  !p.multi=[0,3,3]

nsite = 9
indir = '/data/shared/src/STV/LidarSimulation/OrigGORTInput/2024_06_26/redwood/orig/*.in'
;indir = '/data/shared/src/STV/LidarSimulation/OrigGORTInput/redwood/*.in'
fplot = findfile(indir)

for i=1, nsite do begin
 ; cmd='cp '+indir+fplot(i-1)+ ' gort.in'
  cmd='cp '+fplot(i-1)+ ' gort.in'
  spawn, cmd, result, err
  if (err ne '') then stop

  ; Run GORT model. For only 1 type on the site, it will run single gort. While for 2 types, it runs convolute GORT
  cmd='../../model/gort_lidar > temp.txt'

  spawn, cmd, result, err
 ; if (err ne '') then stop
 ; print, 'output created'

  ;run guassian convolution
  temp_str=''
  temp_str1= temp_str
  gn_level=0
  gout = {height:0.0,fp:0.0,efp:0.0,pgap:0.0,dpdz:0.0,wvfm:0.0}

;read gort output file 
  close,2
  openr, 2, 'gort.out'
  readf, 2, gn_level,dz
  
  ght=fltarr(gn_level)
  fp=fltarr(gn_level)
  afp=fltarr(gn_level)
  jx1 = 0
  jx2 = 6
  jh1 = 0
  jh2 = ght[gn_level-1] 
  cs =2

  readf, 2, temp_str
  readf, 2, temp_str
  readf, 2, temp_str1
  print, strmid(fplot(i-1),66+16,3), ' ', temp_str, temp_str1

  for ilevel=0, gn_level-1 do begin
;   print,ilevel
      readf, 2, gout
      ght[gn_level-1-ilevel]=gout.height
      fp[gn_level-1-ilevel]=gout.fp*2 ; *2-remove G factor 
  endfor
  close, 2
; print, total(fp,/CUMULATIVE)*dz

  plot, total(fp,/CUMULATIVE)*dz, ght,title='RW/L/'+strmid(fplot(i-1),66+16,3),xtitle='Accumulated FP', ytitle='Height(m)', xrange=[jx1,jx2], yrange=[jh1,jh2],charsize=cs,charthick=ct
endfor
DEVICE,/CLOSE 
stop
end
