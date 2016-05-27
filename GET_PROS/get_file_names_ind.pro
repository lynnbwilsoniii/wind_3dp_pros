;+
;PROCEDURE:  get_file_names_ind,  fnames
;PURPOSE:  
;   Gets an array of filenames within a masterfile within a time range
;INPUT:
;   fnames:  named variable in which the output array of filenames is placed.
;KEYWORDS:
;   TIME_RANGE: Two element vector (double or string) specifying the time range.
;     If time range is not set, then "GET_TIMESPAN" will be called
;     to get a time range.
;   MASTERFILE: Name of a masterfile that contains times and associated 
;     filenames.  The file should have the format:
;yyyy-mm-dd/hh:mm:ss   yyyy-mm-dd/hh:mm:ss   fullpathfilename
;     with one line for each file.
;     (Hint: for CDF files, the masterfile can be created using the 
;     UNIX program 'kpdfile' or the IDL procedure "MAKE_CDF_INDEX".)
;   ROOT_DIR:   Optional root_directory of the masterfile.  This will properly
;      manage operating system dependancies.
;   NO_DUPLICATES:  (N;  integer)
;      when set the first N characters of file names are compared and only
;      the highest version is returned.
;
;CREATED BY:	Davin Larson
;VERSION:	@(#)get_file_names_ind.pro	1.1 97/06/23
; 
;-


pro get_file_names_ind,fnames,  $
  starttimes = starttimes, $
  endtimes= endtimes, $
  numrecs = nrecs, $
  TIME_RANGE=trange, $
  MASTERFILE=masterfile, $
  NO_DUPLICATES = no_dup, $
  ROOT_DIR=dir,  $
  NFILES=nfiles

if not keyword_set(trange) then get_timespan,tr else tr= time_double(trange)

if n_elements(tr) ne 2 then tr = [tr(0),tr(0)+24.*3600.]
if data_type(masterfile) ne 7 then begin
   masterfile=''
   read,masterfile,prompt="Name of master file? "
endif

nfiles = 0
fnames = 0
starttimes = 0
endtimes = 0
nrecs = 0

if keyword_set(dir) then mfile=filepath(masterfile,root=dir) $
else mfile = masterfile

on_ioerror,bad_file
openr,lun,mfile,/get_lun

;ts_ = systime(1)
while not eof(lun) do begin
   s = ''
   readf,lun,s
   s = strcompress(strtrim(s,2))
   ss = str_sep(s,' ')
   n = dimen1(ss)

   ts = time_double(ss(0))
   te = time_double(ss(1))
   fname = ss(2)
   if n gt 3 then nr=long(ss(3)) else nr=0
   if(te ge tr(0)) and (ts lt tr(1)) then begin
     append_array,fnames,fname
     append_array,starttimes,ts
     append_array,endtimes,te
     append_array,nrecs,nr
     nfiles = nfiles+1
   endif
endwhile
;print,systime(1)-ts_ ,' seconds'
free_lun,lun

if keyword_set(fnames) eq 0 then begin
   btime = time_string(tr(0))
   etime = time_string(tr(1))
   print,'No data available from ',btime, ' to ',etime,' in ',mfile
endif

if keyword_set(no_dup) then begin
    stpth = strippath(fnames)
    fn = stpth.file_name
    w = where(strlen(fn) lt 26,c)
    if c ne 0 then message,/info,"Warning non-standard file name(s)"
    s = sort(fn)
    u = uniq(strmid(fn(s),0,no_dup))
    i = bytarr(n_elements(s))
    i(s(u)) = 1
    w = where(i eq 0,c) 
    if c ne 0 then begin
        bnames = fnames(w)
        message,/info,'The following obsolete files have been ignored:'
        print,transpose(bnames)
;print,transpose('mv '+bnames+' '+stpth(w).dir_name+'extra')
    endif
    fnames = fnames(s(u))
    starttimes = starttimes(s(u))
    endtimes = endtimes(s(u))
    nrecs = nrecs(s(u))
endif

return
bad_file:
  message,/info,'Unable to open master file: '+mfile
  return
end

