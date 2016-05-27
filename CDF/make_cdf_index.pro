function cdf_time_range,cdffile,fast=fast
if keyword_set(fast) then begin
  message,'Not ready yet'
endif
loadcdf2,cdffile,'Epoch',t
epoch0 = 719528.d * 24.* 3600. * 1000.  ;Jan 1, 1970
t = (t- epoch0)/1000.
;return,minmax(t)
n = n_elements(t)
return,t([0,n-1])
end

;+
;NAME:
;  make_cdf_index
;PROCEDURE:
;  make_cdf_index,  [pattern]
;PURPOSE:
;  Creates an index file for CDF files.
;  The index file will have one line for each CDF file found.
;  Each line contains the start time, end time and filename
;  with the following format:
;YYYY-MM-DD/hh:mm:ss  YYYY-MM-DD/hh:mm:ss   fullpathname.cdf
;  CDF files may be distributed over many directories or disks.
;
;INPUT:
;  pattern:  (string) file pattern, default is:  '*.cdf'
;KEYWORDS:
;  DATA_DIREC  (string) data directory(s) 
;  INDEX_FILENAME:  (string) Name of index file to be created.
;  NO_DUPLICATES:   Set to 1 if duplicate days are to be ignored.
;SEE ALSO:
;  "makecdf","loadcdf","loadcdfstr","loadallcdf",
;CREATED BY:
;  Davin Larson,  August 1996
;VERSION:
;  02/04/17  make_cdf_index.pro  1.5
;-
pro make_cdf_index,pattern, $
  data_direc=data_direc, $
  index_filename=index_filename, $
  no_duplicates=no_duplicates
  files=files

if not keyword_set(pattern) then pattern = '*.cdf'

for n=0,n_elements(data_direc)-1 do begin
  f = findfile(filepath(pattern,root=data_direc(n)))
  if keyword_set(f) then append_array,files,f
endfor

;print,transpose(files)

if data_type(index_filename) ne 7 then index_filename='indexfile'
openw,lun,index_filename,/get_lun

cnt = n_elements(files)
print,cnt,' files found for ',index_filename
tr = dblarr(2,cnt)

for i=0,cnt-1 do begin
   tr(*,i) = cdf_time_range(files(i))
endfor

;sort files:
s = sort( tr(0,*) )
tr = tr(*,s)
files = files(s)

;check for overlap:
if keyword_set(no_duplicates) then begin
  daynum = reform(tr(0,*))  
  daynum = long(daynum/3600./24.)
  u = uniq(daynum)
  files = files(u)
  tr = tr(*,u)
endif

for i=0,n_elements(files)-1 do begin
   str = time_string(tr(*,i))
   printf,lun,str(0),str(1),files(i),format="(a,'  ',a,'  ',a)"
endfor

free_lun,lun

end
