;+
;PROCEDURE:  get_file_names,  fnames
;PURPOSE:  
;   Gets an array of filenames within a time range
;INPUT:
;   fnames:  named variable in which the output array of filenames is placed.
;KEYWORDS:
;   TIME_RANGE: Two element vector (double or string) specifying the time range.
;     If time range is not set, then "GET_TIMESPAN" will be called
;     to get a time range.
;   MASTERFILE: Use this keyword to pass in one of the following:
;	1) Name of a masterfile that contains times and associated 
;	     	filenames.  The file should have the format:
;yyyy-mm-dd/hh:mm:ss   yyyy-mm-dd/hh:mm:ss   fullpathfilename
;     		with one line for each file.
;	     (Hint: for CDF files, the masterfile can be created using the 
;	     UNIX program 'kpdfile' or the IDL procedure "MAKE_CDF_INDEX".)
;	2) Full path/file names with wildcard characters to search for
;		relevant files.  Input should be in the form:
;		/path/xxx* for files of form /path/xxx_date.
;	3) The name of a previously defined environment variable containing
;		data in the form of 1 or 2 above.
;   ROOT_DIR:   Optional root_directory of the masterfile.  This will properly
;      manage operating system dependancies.
;
;CREATED BY:	Davin Larson
;MODIFIED BY:	Peter Schroeder
;VERSION:	1.26 00/10/04 get_file_names.pro
; 
;-


pro get_file_names,fnames,  $
  starttimes = starttimes, $
  endtimes= endtimes, $
  masterfile= masterfile, $
  numrecs = nrecs, $
  TIME_RANGE=trange, $
  ROOT_DIR=dir,  $
  NFILES=nfiles

if data_type(masterfile) ne 7 then begin
	masterfile=''
	read,masterfile,prompt="Name of master file? "
endif

if keyword_set(dir) then masterfile=filepath(masterfile,root=dir)

if getenv('FILE_ENV_SET') ne '1' then setfileenv

filefoo = findfile(masterfile)
if filefoo(0) eq '' then begin
	mafile = getenv(masterfile)
	if mafile eq '' then mafile = getenv(strupcase(masterfile))
	masterfile=mafile
	useenv = 1
	if masterfile eq '' then begin
		print,'Invalid environment variable '+masterfile+'!'
		return
	endif
endif else if strpos(masterfile,'*') eq -1 then useenv = 0 else useenv = 1

if not keyword_set(trange) then get_timespan,tr else tr= time_double(trange)

if n_elements(tr) ne 2 then tr = [tr(0),tr(0)+24.*3600.]

;if tr(1) lt tr(0)+24.*3600. then tr(1) = tr(0)+24.*3600.

ts = time_struct(tr)
nfiles = 0
fnames = 0
starttimes = 0
endtimes = 0

if useenv eq 1 then begin
	allfnames = findfile(masterfile)
	date_indx1 = where(strlen(allfnames) eq strlen(allfnames(0)),cnt1)
	date_indx2 = where(strlen(allfnames) ne strlen(allfnames(0)),cnt2)
	date_pos1 = strlen(allfnames(0))-16
	date = long(strmid(allfnames(date_indx1),date_pos1,8))
	if cnt2 ne 0 then begin
		date_pos2 = strlen(allfnames(date_indx2[0]))-16
		date = [date, $
			long(strmid(allfnames(date_indx2),date_pos2,8))]
		allfnames = [allfnames(date_indx1),allfnames(date_indx2)]
	endif
	year = date/10000
	date = date - year*10000
	month = date/100
	date = date mod 100
	mydate = time_double({year: year, date: date, month: month, hour: 0,$
		min: 0, sec: 0, fsec: 0})
	sortindex = sort(mydate)
	allfnames = allfnames(sortindex)
	mydate = mydate(sortindex)
	w = where(mydate ge tr(0)-24.*3600.+1. and mydate lt tr(1),nfiles)
	if nfiles ne 0 then fnames = allfnames(w)
endif else begin
	mfile = masterfile

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
endelse

return
bad_file:
  message,/info,'Unable to open master file: '+mfile
  return
end

