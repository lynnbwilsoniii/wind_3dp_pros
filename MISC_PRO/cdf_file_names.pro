;+
;*****************************************************************************************
;
;  PROCEDURE:   cdf_file_names_index.pro
;  PURPOSE  :   
;
;  CALLED BY:   
;               cdf_file_names.pro
;
;  CALLS:
;               NA
;
;   CREATED:  ??/??/????
;   CREATED BY:  ?
;    LAST MODIFIED:  04/30/2014   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO cdf_file_names_index,name,info,SET=set,GET=get

;;----------------------------------------------------------------------------------------
;;  Get COMMON block variables
;;----------------------------------------------------------------------------------------
COMMON cdf_file_names_index_com,index
;;----------------------------------------------------------------------------------------
;;  Define defaults
;;----------------------------------------------------------------------------------------
f    = {indexformat,NAME:'',PTR:PTR_NEW()}
n    = 0
i    = -1
test = (SIZE(/TYPE,name) EQ 7 AND KEYWORD_SET(index))
;IF (SIZE(/TYPE,name) EQ 7 AND KEYWORD_SET(index)) THEN  $
IF (test) THEN i = (WHERE(name EQ index.NAME,n))[0]
IF (n GE 2) THEN MESSAGE,'Error'

IF KEYWORD_SET(set) THEN BEGIN
  IF KEYWORD_SET(info) THEN BEGIN
    IF (n EQ 0) THEN BEGIN
      f.NAME = name
      f.PTR  = PTR_NEW(info)
      index  = KEYWORD_SET(index) ? [index,f] : [f]
    ENDIF ELSE BEGIN
      *index[i].PTR = info
    ENDELSE
  ENDIF ELSE BEGIN           ; Delete
    IF (n NE 0) THEN BEGIN
      PTR_FREE,index[i].PTR
      ni = WHERE(name NE index.NAME,n)
      IF (n NE 0) THEN index = index[ni] ELSE index = 0
    ENDIF
  ENDELSE
  RETURN
ENDIF

IF KEYWORD_SET(get) THEN BEGIN
  info = (n NE 0) ? *index[i].ptr : 0
  RETURN
ENDIF

IF NOT KEYWORD_SET(index) THEN BEGIN
  dprint,'Nothing stored!'
  RETURN
ENDIF

IF N_ELEMENTS(name) EQ 0 THEN BEGIN
  dprint,TRANSPOSE(["'"+ index.NAME +"'"]) 
  RETURN
ENDIF

IF (i GE 0) THEN printdat,index[i] ELSE dprint, 'Name not found!'

RETURN
END


;+
;*****************************************************************************************
;
;  PROCEDURE:   file_YYYYMMDD_to_time.pro
;  PURPOSE  :   
;
;  CALLED BY:   
;               cdf_file_names.pro
;
;  CALLS:
;               time_struct.pro
;               time_double.pro
;
;   CREATED:  ??/??/????
;   CREATED BY:  ?
;    LAST MODIFIED:  04/30/2014   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO file_YYYYMMDD_to_time,allfiles

datepos        = 16
n              = N_ELEMENTS(allfiles)
pos            = STRLEN(allfiles.NAME) - datepos

IF (n GT 1) THEN date = LONG(STRMID(allfiles.NAME,TRANSPOSE(pos),8)) $
            ELSE date = LONG(STRMID(allfiles.NAME,pos,8))

t              = REPLICATE(time_struct(0d0),n)
t.year         = date/10000
date           = date MOD 10000
t.month        = date/100
t.date         = date MOD 100
allfiles.START = time_double(t)

st             = SORT(allfiles.START)
allfiles       = allfiles[st]
allfiles.STOP  = allfiles.START + 86400d0 - 1d0
;    allfiles.STOP = SHIFT(allfiles.START,-1) - 1d
;    allfiles[n-1].STOP = allfiles[n-1].START + 86400d - 1d

RETURN
END

;+
;*****************************************************************************************
;
;  PROCEDURE:   file_bartel_to_time.pro
;  PURPOSE  :   
;
;  CALLED BY:   
;               cdf_file_names.pro
;
;  CALLS:
;               bartel_time.pro
;
;   CREATED:  ??/??/????
;   CREATED BY:  ?
;    LAST MODIFIED:  04/30/2014   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO file_bartel_to_time,allfiles

datepos            = 12
n                  = N_ELEMENTS(allfiles)
n_1                = n[0] - 1L
pos                = STRLEN(allfiles.NAME) - datepos
bartnum            = LONG(STRMID(allfiles.NAME,TRANSPOSE(pos),4))
allfiles.START     = bartel_time(bartnum)
st                 = SORT(allfiles.START)
allfiles           = allfiles[st]
allfiles.STOP      = SHIFT(allfiles.START,-1) - 1d0
;allfiles[n-1].STOP = allfiles[n-1].START + 27*86400d0 - 1d0
allfiles[n_1].STOP = allfiles[n_1].START + 27*86400d0 - 1d0

RETURN
END




;+
;*****************************************************************************************
;
;  FUNCTION :   cdf_file_names.pro
;  PURPOSE  :   Returns an array of filenames within a timerange.
;
;  CALLED BY:   
;               loadallcdf.pro
;
;  CALLS:
;               timerange.pro
;               dprint.pro
;               setfileenv.pro
;               cdf_file_names_index.pro
;               time_double.pro
;               append_array.pro
;               file_YYYYMMDD_to_time.pro
;               file_bartel_to_time.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP or TDAS IDL Libraries
;
;  INPUT:
;               FORMAT  :  Scalar [string] that will be interpreted as one of two things:
;                            CASE 1 Example:  
;                               FORMAT = '/home/wind/dat/wi/3dp/k0/????/wi_k0_3dp*.cdf'
;                                 --> if FORMAT contains * or ? then filenames are
;                                     returned that match that pattern and for which
;                                     YYYYMMDD falls within the specified timerange.
;                               for example:  
;                               (UNIX only)
;                            CASE 2 Example:
;                               FORMAT = 'fa_k0_ees_files'
;                                 --> The name of an indexfile that associates filenames
;                                     with start and end times. If his file is not found,
;                                     then the environment variable returned by
;                                     GETENV('CDF_INDEX_DIR') is prepended and used in
;                                     the file search.
;
;  EXAMPLES:    
;               files = cdf_file_names(format,TRANGE=trange,/VERBOSE)
;
;  KEYWORDS:    
;               PATHNAME    :  Set to a named variable to return the path to the data
;                                files loaded/found
;               USE_MASTER  :  If set, routine will assume that FORMAT is the name of
;                                a master file indexed list
;               TRANGE      :  [2]-Element [double/string] array defining the time range
;                                for which data files should be returned.  If not
;                                provided, then timerange.pro is called to provide the
;                                time range.  See also timespan.pro
;               NFILES      :  Set to a named variable to return the number of files found
;               FILEINFO    :  **  OBSOLETE  **
;               RESET       :  If set, routine removes any previously set/defined CDF
;                                index
;                                [**  Not sure if still relevant  **]
;               VERBOSE     :  If set, routine prints more information than usual
;                                See also dprint.pro
;               ROUTINE     :  Scalar [string] that defines the routine to use to
;                                interpret the date or time in the CDF file name
;                                [except for specialized cases, just ignore]
;
;   CHANGED:  1)  Someone modified something
;                                                                   [06/23/2008   v1.?.?]
;             2)  Updated for TDAS and removed dependence upon obsolete IDL routine
;                   FINDFILE.PRO
;                                                                   [01/24/2012   v1.?.?]
;             3)  Updated man page, added comments, and cleaned up a little
;                                                                   [04/30/2014   v1.1.0]
;
;   NOTES:      
;               1)  If STRUPCASE(FORMAT) is the name of an environment varible.  Then
;                     the value of that environment variable is used instead.
;               2)  See "make_cdf_index" for information on producing the
;                     'CDF_INDEX_DIR' file.
;               3)  UNIX only!
;
;  REFERENCES:  
;               NA
;
;   CREATED:  ??/??/????
;   CREATED BY:  ?
;    LAST MODIFIED:  04/30/2014   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION cdf_file_names,format,PATHNAME=pathname,USE_MASTER=use_master, $
                        TRANGE=trange,NFILES=n,FILEINFO=fileinfo,$
                        RESET=reset,VERBOSE=verbose,ROUTINE=routine

;;----------------------------------------------------------------------------------------
;;  Determine time range to load
;;----------------------------------------------------------------------------------------
ts_ = SYSTIME(1)
tr  = timerange(trange)
;;----------------------------------------------------------------------------------------
;;  Define defaults and initialize
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(fileinfo) THEN dprint,'FILEINFO keyword is obsolete'

mfileformat = {mfileformat, NAME:'',START:0d,STOP:0d,LEN:0l}
n           = 0

IF (GETENV('FILE_ENV_SET') NE '1') THEN setfileenv

IF (SIZE(/TYPE,format) NE 7) THEN BEGIN
  dprint,'Input format must be a string'
  RETURN,''
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check for previously defined defaults
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(format) THEN BEGIN
  envformat = GETENV(STRUPCASE(format) )
  IF KEYWORD_SET(envformat) THEN BEGIN
    IF KEYWORD_SET(verbose) THEN $
       dprint,'Environment variable: ',STRUPCASE(format),' Found.'
  ENDIF
  IF NOT KEYWORD_SET(envformat)  THEN envformat = format
  IF     KEYWORD_SET(use_master) THEN envformat = format
  IF (STRPOS(envformat,'*') GE 0 OR STRPOS(envformat,'?') GE 0) THEN BEGIN
    pathname  = envformat
    indexfile = 0
  ENDIF ELSE BEGIN
    IF FILE_TEST(envformat,/REGULAR,/READ) THEN BEGIN
      pathname  = envformat
      indexfile = 1
    ENDIF ELSE BEGIN
      envformat2 = FILEPATH(envformat,ROOT=GETENV('CDF_INDEX_DIR'))
      IF FILE_TEST(envformat2,/REGULAR,/READ) THEN BEGIN
        pathname  = envformat2
        indexfile = 1
      ENDIF ELSE BEGIN
        IF KEYWORD_SET(verbose) THEN dprint, 'Using default path.'
        parts     =  STRSPLIT(envformat,/extr,'_')
        parts     =  parts[[0,1,2]]
        pathname  = GETENV('BASE_DATA_DIR')+'/'+STRJOIN(parts,'/')+'/????/*.*'
        indexfile = 0
;             message,/info,'Unable to determine PATHNAME for "'+format+'"'
;             RETURN,''
      ENDELSE
    ENDELSE
  ENDELSE
ENDIF ELSE BEGIN
  dprint,'FORMAT must be set'
  RETURN,''
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Get index file info
;;----------------------------------------------------------------------------------------
cdf_file_names_index,format,fileinfo,/GET

IF KEYWORD_SET(fileinfo) THEN BEGIN
  reset_time = 3600.*2
  allfiles   = fileinfo.ALLFILES
  IF (fileinfo.INDEXFILE  NE indexfile) THEN allfiles = 0
  IF (fileinfo.PATHNAME   NE  pathname) THEN allfiles = 0
  IF (indexfile) THEN BEGIN
    OPENR,lun,pathname,/GET_LUN
    stat = FSTAT(lun)
    FREE_LUN,lun
;      print,'File: ',time_string(stat.MTIME)
;       print,'info: ',time_string(fileinfo.TIMESTAMP)
    IF (stat.MTIME GT fileinfo.TIMESTAMP) THEN BEGIN
      IF KEYWORD_SET(verbose) THEN dprint, 'Index file has been modified!'
      allfiles = 0
    ENDIF
  ENDIF ELSE BEGIN
    IF (fileinfo.TIMESTAMP + reset_time LT ts_) THEN BEGIN
      allfiles = 0
      IF KEYWORD_SET(verbose) THEN dprint, 'Timer elapsed, checking for more files.'
    ENDIF
  ENDELSE
  IF KEYWORD_SET(reset) THEN allfiles = 0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get CDF file names
;;----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(allfiles) THEN BEGIN
  datepos = 16
  IF (indexfile) THEN BEGIN
    IF KEYWORD_SET(verbose) THEN dprint, "Searching for files in: indexfile='",pathname,"'"
    ON_IOERROR,BAD_FILE
    OPENR,lun,pathname,/GET_LUN
;printdat,FSTAT(lun)
    mf = mfileformat
    WHILE NOT EOF(lun) DO BEGIN
       s        = ''
       READF,lun,s
       ss       = STRSPLIT(s,/EXTRACT)
       ns       = N_ELEMENTS(ss)
       mf.START = time_double(ss[0])
       mf.STOP  = time_double(ss[1])
       mf.NAME  = ss[2]
       mf.len   = (ns GT 3) ? LONG(ss[3]) : 0
       append_array,allfiles,mf,INDEX=n
    ENDWHILE
    append_array,allfiles,INDEX=n,/DONE
    FREE_LUN,lun
  ENDIF ELSE BEGIN
    IF KEYWORD_SET(verbose) THEN dprint, "Searching for files in: pathname='",pathname,"'"
    allfnames = FILE_SEARCH(pathname,COUNT=n)  ; This is the time consuming call.
    IF (n EQ 0) THEN BEGIN
      dprint,'No files found in path: "'+pathname+'"'
      RETURN,''
    ENDIF
    allfiles      = REPLICATE(mfileformat,n)
    allfiles.NAME = allfnames
    IF NOT KEYWORD_SET(routine) THEN BEGIN
      IF (STRPOS(pathname,'bartel') GE 0) THEN routine = 'file_BARTEL_to_time' $
                                          ELSE routine = 'file_YYYYMMDD_to_time'
    ENDIF
    CALL_PROCEDURE,routine,allfiles
  ENDELSE
  ;search for and eliminate duplicate or earlier version files
  IF (n GE 2) THEN BEGIN
    p        = STRPOS(allfiles.NAME,'/',/REVERSE_SEARCH)
    fn1      = STRMID(allfiles.NAME,TRANSPOSE(p+1))
    st       = SORT(fn1)
    allfiles = allfiles[st]
    fn1      = fn1[st]
    l        = STRLEN(fn1)
    fn2      = STRMID(fn1,0,TRANSPOSE(l-datepos+8))
    dup      = fn2 EQ SHIFT(fn2,-1)
    dup[n-1] = 0
    wdup     = WHERE(dup,ndup)
    IF (ndup NE 0) THEN BEGIN
      IF (indexfile) THEN dprint, 'The indexfile ',pathname,' has the following duplicate entries:' $
                     ELSE dprint, 'The following files are either duplicate or earlier version files and should be deleted:'
      dprint, allfiles[TRANSPOSE(wdup)].NAME
    ENDIF
    allfiles = allfiles[WHERE(dup EQ 0)]
    allfiles = allfiles[SORT(allfiles.START)]
  ENDIF
  fileinfo = {TIMESTAMP:ts_,PATHNAME:pathname,INDEXFILE:indexfile,ALLFILES:allfiles}
  IF NOT KEYWORD_SET(allfiles) THEN fileinfo = 0
ENDIF

cdf_file_names_index,format,fileinfo,/SET

n = N_ELEMENTS(allfiles) * KEYWORD_SET(allfiles)
IF (n EQ 0) THEN BEGIN
  dprint,'No matching files found!'
  RETURN,''
ENDIF

w = WHERE(allfiles.STOP GE tr[0] and allfiles.START LT tr[1],n)
IF (n NE 0) THEN files = allfiles[w].NAME ELSE files = ''

n2 = 0
IF (n NE 0) THEN w = WHERE(FILE_TEST(files),n2)

IF (n2 GT 0) THEN files = files[w] ELSE files = ''
n = n2

IF KEYWORD_SET(verbose) THEN $
  dprint, n,' of ',N_ELEMENTS(allfiles),' Files found in ',SYSTIME(1) - ts_ ,' seconds'
RETURN,files
;;========================================================================================
BAD_FILE:
;;========================================================================================
dprint,'Unable to open index file: '+pathname
RETURN,''
END
