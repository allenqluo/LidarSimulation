pro run_gort_orig

 tek_color
  ; Setting plotting
  set_plot,'ps'
  
  ;device, file= 'comp.eps', /color,/TIMES,/BOLD,/portrait, ysize=28, YOFFSET=0, xsize=21, xOFFSET=0.0
  device, file= 'rw_f_wvfm.eps', /TIMES,/BOLD,/portrait, ysize=28, YOFFSET=0, xsize=21, xOFFSET=0.0
  !p.multi=[0,3,3]

nsite = 9

; Open the file and read the script path
OPENR, lun, 'gort_in_locations.txt', /GET_LUN
gort_in_path = ''
READF, lun, gort_in_path
FREE_LUN, lun

; Open the file and read the script path
OPENR, lun, 'idl_wvfm_out_location.txt', /GET_LUN
save_dir = ''
READF, lun, save_dir
FREE_LUN, lun

; Output the path to verify it was read successfully
PRINT, 'Gort in locations from file: ', gort_in_path
PRINT, 'IDL waveform out location from file: ', save_dir

all_subdir_base_len = strlen(gort_in_path)
indir = gort_in_path + '*.in'
fplot = findfile(indir)

; Get a list of files matching the pattern
file_list = file_search(indir)

; Get the number of files
n_files = n_elements(file_list)

; Initialize an array to store relative paths
rel_paths = strarr(n_elements(fplot))
filenames = strarr(n_elements(fplot))

; Calculate the length of the base directory path
base_len = strlen('/data/shared/src/STV/simscenes/LidarSimulation/Gort/OrigGORTInput/')

print, ''

; Loop through each file path to extract relative paths
for i=0, n_elements(fplot) - 1 do begin
    filenames[i] = strmid(fplot[i], all_subdir_base_len, strlen(fplot[i]) - all_subdir_base_len + 1)
    print, 'filenames: ', filenames[i]
    rel_paths[i] = strmid(fplot[i], base_len, strlen(fplot[i]) - base_len - strlen(filenames[i]))
    print, 'rel_paths: ', rel_paths[i]
endfor

print, ''
print, rel_paths

for i=1, n_files do begin

 ; cmd='cp '+indir+fplot(i-1)+ ' gort.in'
    print, 'copying gort.in'
  cmd='cp '+fplot(i-1)+ ' gort.in'
  spawn, cmd, result, err
        if (err ne '') then begin
            print, 'Error copying file:', err
            stop
        endif

  ; Run GORT model. For only 1 type on the site, it will run single gort. While for 2 types, it runs convolute GORT
  cmd='/data/shared/src/STV/simscenes/LidarSimulation/model/gort_lidar > temp.txt'
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
  
;+   readf, 2, temp_str  ; read G
  ;print, temp_str
  readf, 2, temp_str  ; read GORT input
  ;print, temp_str
  readf, 2, temp_str ; read gamma
  ;print, temp_str -;

; Step 1: Skip lines until we find the line with "gamma:"
while not eof(unit) do begin
    readf, unit, line    ; Read a line from the file
    if strsearch(line, 'gamma:') ne -1 then begin
        print, 'Found "gamma:" line'
        break
    endif
endwhile

; Step 2: After finding "gamma:", start reading lines until we find one with 6 columns
while not eof(unit) do begin
    readf, unit, line    ; Read the next line from the file

    ; Split the line into columns (by spaces or tabs)
    columns = strsplit(line, ' ', /extract)

    ; Check if there are 6 columns
    if n_elements(columns) eq 6 then begin
        print, 'Found a line with 6 columns: ', line
        break
    endif
endwhile

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
