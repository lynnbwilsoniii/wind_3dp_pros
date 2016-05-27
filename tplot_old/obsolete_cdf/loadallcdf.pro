;  FILENAMES:   string (array); full pathname of file(s) to be loaded.
;     (INDEXFILE, ENVIRONVAR, MASTERFILE and TIME_RANGE are ignored
;     if this is set.)
;
;  MASTERFILE:  Full Pathname of indexfile or name of environment variable
;     giving path and filename information as defined in "get_file_names".
;     (INDEXFILE and ENVIRONVAR are ignored if this is set)
;
;  INDEXFILE:   File name (without path) of indexfile. This file
;     should be located in the directory given by ENVIRONVAR.  If not given
;     then "PICKFILE" is used to select an index file. see "make_cdf_index" for
;     information on producing this file.
;
;  ENVIRONVAR:  Name of environment variable containing directory of indexfiles
;     (default is 'CDF_INDEX_DIR')
;+
;PROCEDURE: loadallcdf
;USAGE:
;  loadallcdf,  FORMAT
;PURPOSE:
;  Loads selected CDF file variables into a data structure.
;  VARYing data is returned through the keyword: DATA.
;  NOVARY data is returned through the keyword:  NOVARDATA.
;INPUT:
;  FORMAT is a string (i.e. 'wi_k0_3dp_files') that specify the type of
;  files to be searched for.  see "cdf_file_names" for more info.
;KEYWORDS:  (all keywords are optional)
;  FILENAMES:   string (array); full pathname of file(s) to be loaded.
;     (INDEXFILE, ENVIRONVAR, MASTERFILE and TIME_RANGE are ignored
;     if this is set.)
;  TIME_RANGE:  Two element vector specifying time range (default is to use
;     trange_full; see "TIMESPAN" or "TIMERANGE" for more info)
;
;  CDFNAMES:    Names of CDF variables to be loaded. (string array)
;  TAGNAMES:	String array of structure tag names.
;  DATA:        Named variable that data is returned in.
;  RESOLUTION:	Resolution in seconds to be returned.
;
;  NOVARNAMES:  Names of 'novary' variables to be loaded
;  NOVARDATA:   Named variable that 'novary' data is returned in.
;
;  TPLOT_NAME:  "TPLOT" string name. If set then a tplot variable is created.
;     Individual elements can be referred to as 'NAME.ELEMENT'
;  CARR_FILE:	Load Carrington rotation files.
;
;SEE ALSO:
;  "loadcdf","loadcdfstr","makecdf","make_cdf_index","get_file_names","
;VERSION:  02/04/19  loadallcdf.pro  1.27
;Created by Davin Larson,  August 1996
;-
pro loadallcdf,format, $
   indexfile=indexfile, $
   time_range=trange, $
   FILENAMES  = filenames, $
   MASTERFILE = mfile, $
;   pathname=pathname, $
;   fileinfo=fileinfo, $
;   environvar=environvar, $
   cdfnames=cdfnames, $
   tagnames=tagnames, $
   data=data, novardata=novardata, $
   resolution = res, $
   median = med, $
   filter_proc = filter_proc, $
   tplot_name=tplot_name, $
   novarnames=novarnames, nvtagnames=nvtagnames, $
   novarznames=novarznames, nvztagnames=nvztagnames

verbose=1


if not keyword_set(filenames) then begin

;if getenv('FILE_ENV_SET') ne '1' then setfileenv
if keyword_set(indexfile) then format = indexfile
if keyword_set(mfile)     then format = mfile

if keyword_set(format) then $
  filenames=cdf_file_names(format,pathname=pathname,trange=trange,  $
                  nfiles=ndays,verbose=verbose)

endif

ndays = n_elements(filenames) * keyword_set(filenames)


;if 0 and not keyword_set(filenames) then begin
;  if not keyword_set(mfile) then begin
;  	if not keyword_set(environvar) then $
;  		environvar = 'CDF_INDEX_DIR'
;  	dir = getenv(environvar)
;  	if not keyword_set(dir) then message,$
;  		'Environment variable '+environvar+$
;  		' is not defined!' ,/info
;  	if not keyword_set(indexfile) then mfile = pickfile(path=dir) $
;  	else mfile = filepath(indexfile,root_dir=dir)
;  endif
;  get_file_names,filenames,TIME_RANGE=trange,MASTERFILE=mfile,nfiles=ndays
;endif

if ndays eq 0 then begin
  data=0
  novardata=0
  print,'LOADALLCDF: No data files valid for given time range'
  return
endif

if keyword_set(pickcdfnames) then begin
   print_cdf_info,filenames(0)
   print,'Choose data quantities:'
   repeat begin
     s = ''
     read,s
     if keyword_set(s) then if keyword_set(cdfnames) then $
         cdfnames = [cdfnames,s] else cdfnames=s
   endrep until keyword_set(s) eq 0
endif

loadcdfstr,data,novardata  $
  ,file=filenames,varnames=cdfnames,tagna=tagnames  $
  ,novarnames=novarnames,/time,resolution=res,median=med,filter_proc=filter_proc, $
   nvtagnames = nvtagnames, novarznames=novarznames, nvztagnames=nvztagnames

if keyword_set(tplot_name) then begin
  if size(/type,tplot_name) ne 7 then begin
    message,/info,"Sorry!   Code change!"
    message,/info,"You must now supply a string name for the TPLOT_NAME keyword."
    tplot_name = 'foo'
    message,/info,"The default name is: "+tplot_name
  endif
  store_data,tplot_name,data=data
  message,/info,"The following variables can now be plotted using TPLOT:"
  print,transpose(tplot_name+'.'+tag_names(data))
endif


end
