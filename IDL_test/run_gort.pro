pro run_gort

 tek_color
  ; Setting plotting
  set_plot,'ps'
  
  ;device, file= 'comp.eps', /color,/TIMES,/BOLD,/portrait, ysize=28, YOFFSET=0, xsize=21, xOFFSET=0.0
  device, file= 'rw_f_wvfm.eps', /TIMES,/BOLD,/portrait, ysize=28, YOFFSET=0, xsize=21, xOFFSET=0.0
  !p.multi=[0,3,3]

nsite = 9

; Define the save directory
save_dir = '/data/shared/src/STV/LidarSimulation/IDL_test/'

; List of all base directories
all_subdir_bases = [
    '/data/shared/src/STV/LidarSimulation/OrigGORTInput/2024_07_01/redwood/orig/',
    '/data/shared/src/STV/LidarSimulation/OrigGORTInput/2024_07_01/redwood/origB10th/',
    '/data/shared/src/STV/LidarSimulation/OrigGORTInput/2024_07_01/guiana/orig/',
    '/data/shared/src/STV/LidarSimulation/OrigGORTInput/2024_07_01/guiana/origLD10th/',
    '/data/shared/src/STV/LidarSimulation/OrigGORTInput/2024_07_01/guiana/origLD30th/',
    '/data/shared/src/STV/LidarSimulation/OrigGORTInput/2024_07_01/redwood/orig/with_branch/',
    '/data/shared/src/STV/LidarSimulation/OrigGORTInput/2024_07_01/redwood/origB10th/with_branch/',
    '/data/shared/src/STV/LidarSimulation/OrigGORTInput/2024_07_01/guiana/orig/with_branch/',
    '/data/shared/src/STV/LidarSimulation/OrigGORTInput/2024_07_01/guiana/origLD10th/with_branch/',
    '/data/shared/src/STV/LidarSimulation/OrigGORTInput/2024_07_01/guiana/origLD30th/with_branch/'
]

; Base length for relative path calculations
base_len = strlen('/data/shared/src/STV/LidarSimulation/OrigGORTInput/')

; Loop over each base directory
for j = 0, n_elements(all_subdir_bases) - 1 do begin
    ; Get the current base directory
    all_subdir_base = all_subdir_bases[j]
    all_subdir_base_len = strlen(all_subdir_base)

    ; Generate the file path pattern
    indir = all_subdir_base + '*.in'
    fplot = findfile(indir)

    ; Initialize arrays for relative paths and filenames
    rel_paths = strarr(n_elements(fplot))
    filenames = strarr(n_elements(fplot))

    ; Print a separator for clarity
    print, 'Processing directory: ', all_subdir_base
    print, ''

    ; Loop through each file path to extract relative paths
    for i = 0, n_elements(fplot) - 1 do begin
        filenames[i] = strmid(fplot[i], all_subdir_base_len, strlen(fplot[i]) - all_subdir_base_len + 1)
        print, 'filenames: ', filenames[i]
        rel_paths[i] = strmid(fplot[i], base_len, strlen(fplot[i]) - base_len - strlen(filenames[i]))
        print, 'rel_paths: ', rel_paths[i]
    endfor

    print, '' ; Print an empty line between directories
endfor

print, ''
print, rel_paths

for i=1, nsite do begin

 ; cmd='cp '+indir+fplot(i-1)+ ' gort.in'
    print, 'copying gort.in'
  cmd='cp '+fplot(i-1)+ ' gort.in'
  spawn, cmd, result, err
        if (err ne '') then begin
            print, 'Error copying file:', err
            stop
        endif

  ; Run GORT model. For only 1 type on the site, it will run single gort. While for 2 types, it runs convolute GORT
  cmd='/data/shared/src/STV/LidarSimulation/model/gort_lidar > temp.txt'
  spawn, cmd, result, err
 ; if (err ne '') then stop
    if (err ne '') then begin
        print, 'Error running gort_lidar:', err
        ; Optionally, you can stop further execution or handle the error here
    endif else begin
        print, 'gort_lidar executed successfully.'
        ; Continue with the rest of your script
    endelse

    print, ''

  ;run guassian convolution
  temp_str=''
  gn_level=0
  gout = {height:0.0,fp:0.0,efp:0.0,pgap:0.0,dpdz:0.0,wvfm:0.0}

;read gort output file 
  close,2
  openr, 2, 'gort.out'
  readf, 2, gn_level,dz
  print, gn_level, dz
  n_ext=10./dz  
  n_tot=gn_level+n_ext

  ght=fltarr(n_tot)
  wvfm=fltarr(n_tot)
  gwvfm=wvfm
  ght(0:n_ext-1)=findgen(n_ext)*dz-10 ;extend height to below ground 10m deep 
  wvfm(0:n_ext-1)=0             ;extend wvfm to below ground 10m deep
  
  readf, 2, temp_str  ; read G
  ;print, temp_str
  readf, 2, temp_str  ; read GORT input
  ;print, temp_str
  readf, 2, temp_str ; read gamma
  ;print, temp_str
  for ilevel=0, gn_level-1 do begin
;    print,ilevel
      readf, 2, gout
      ght[ilevel+n_ext]=gout.height
      wvfm[ilevel+n_ext]=gout.wvfm
  endfor
  close, 2

  width = fix(0.6/dz)+1 ;LVIS gaussian width=10ns(10ns*0.15m=1.5m)/2.35482=0.63m, witdth #=0.63/dz
  gwvfm=gsmooth(wvfm,width)
 
  jx1=0
  jx2=0.3
  jh1=-5
  jh2=40 
  cs =2
  ct =1.4
  if (i eq 1) then begin
        plot, gwvfm, ght,title='RW/B+L/'+strmid(fplot(i-1),66+16,3),xtitle='Normalized WF', ytitle='Height(m)', xrange=[jx1,jx2], yrange=[jh1,jh2],charsize=cs,charthick=ct
      endif else begin  
        plot, gwvfm, ght,title='RW/B+L/'+strmid(fplot(i-1),66+16,3),xtitle='Normalized WF', ytitle='Height(m)', xrange=[jx1,jx2], yrange=[jh1,jh2],charsize=cs,charthick=ct
      endelse

    ; Cosntruct full output file path
    output_dir = save_dir + rel_paths[i - 1]

    mkdir_cmd = 'mkdir -p ' + output_dir
    print, 'executing: ', mkdir_cmd
    spawn, mkdir_cmd, result, err

    if err ne '' then begin
        print, 'Error creating directory: ', err
    endif else begin
        print, 'Directory created successfully: ', output_dir
    endelse

    output_file = output_dir + filenames[i - 1] + '.gwvfm.txt'
    mkfile_cmd = 'touch ' + output_file
    print, 'executing: ', mkfile_cmd
    spawn, mkfile_cmd, result, err

    print, ''

    if err ne '' then begin
        print, 'Error creating file: ', err
    endif else begin
        print, 'File created successfully: ', output_file
    endelse

    print, ''

    ; Save gwvfm data to text file
    openw, i, output_file
    printf, i, transpose([[ght], [gwvfm]])
    close, i

    print, 'Data written to:', output_file

;  save, filename='outputs/gort_wvfm'+strtrim(string(i), 2)+'.sav',ght,gwvfm
endfor
DEVICE,/CLOSE 

stop

end
