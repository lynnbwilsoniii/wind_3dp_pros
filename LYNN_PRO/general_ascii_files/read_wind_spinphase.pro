;+
;*****************************************************************************************
;
;  FUNCTION :   read_wind_spinphase.pro
;  PURPOSE  :   This program reads in an ASCII file created by SPDF Data Orbit Services
;                 and returns a data structure that contains the spin attitude
;                 information for the Wind spacecraft for the desired time range
;                 of interest.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               time_range_define.pro
;               time_double.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII Files created by SPDF Data Orbit Services at:
;                     http://cdaweb.gsfc.nasa.gov/istp_public/
;                   1)  Choose Wind Spacecraft and Ephemeris
;                   2)  Clear all checked boxes
;                   3)  Check ONLY WI_K0_SPHA and click Submit
;                   4)  Enter a desired time range and click on List Data (ASCII)
;                         then click Submit
;                   5)  Copy ASCII data into a text editor and name the file:
;                         wind_spin-phase_YYYY-MM-DD_hhmm_to_YYYY-MM-DD_hhmm.txt
;                             YYYY  :  year (e.g. 1998) of start[end] date for
;                                        first[second] occurrence in file name
;                             MM    :  month (e.g. 08) " "
;                             DD    :  day (e.g. 26) " "
;                             hhmm  :  hour and minutes (UT) of start[end] time " "
;                   6)  Put files in:  ~/wind_3dp_pros/wind_data_dir/Wind_Spin_Phase/
;                         directory so this routine can find them
;                   7)  Call routine with desired time range
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ymdb    = ['1998-08-25/01:30:00','1998-08-28/12:45:00']
;               trange  = time_double(ymdb)
;               wi_spin = read_wind_spinphase(TRANGE=trange)
;
;  KEYWORDS:    
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures [Unix time]
;
;   CHANGED:  1)  Program now returns the header as new structure tag:  HEADER
;                                                                  [01/19/2012   v1.1.0]
;             2)  Removed dependence on read_gen_ascii.pro         [01/19/2012   v1.2.0]
;             3)  Fixed issue where I forgot to free the logical unit number
;                                                                  [02/01/2012   v1.3.0]
;             4)  Fixed issue that occurred when determining files of interest when
;                   multiple dates are selected                    [02/02/2012   v1.3.1]
;
;   NOTES:      
;               1)  When saving files from CDAWeb, keep entire header
;
;   CREATED:  01/13/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/02/2012   v1.3.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION read_wind_spinphase,TRANGE=trange

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
d        = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Determine time range of interest
;-----------------------------------------------------------------------------------------
zdate0   = ''    ; => Start date ['YYYY-MM-DD']
zdate1   = ''    ; => End date ['YYYY-MM-DD']
time_ra  = time_range_define(DATE=date,TRANGE=trange)

tra      = time_ra.TR_UNIX
tdate    = time_ra.TDATE_SE
zdate0   = tdate[0]
zdate1   = tdate[1]
;-----------------------------------------------------------------------------------------
; => Define possible file names
;-----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(EXISTS) THEN BEGIN
  mdir = FILE_EXPAND_PATH('wind_3dp_pros/wind_data_dir/Wind_Spin_Phase/')
ENDIF ELSE BEGIN
  mdir = !wind3dp_umn.WIND_DATA_DIR
  IF (mdir[0] EQ '') THEN BEGIN
    mdir = FILE_EXPAND_PATH('wind_3dp_pros/wind_data_dir/Wind_Spin_Phase/')
  ENDIF ELSE BEGIN
    mdir = mdir[0]+'Wind_Spin_Phase/'
  ENDELSE
ENDELSE
; => find all relevant files
allfiles = FILE_SEARCH(mdir,'wind_spin-phase_*.txt')  ; => All files with entire path set
;  e.g.  wind_spin-phase_1998-08-01_0000_to_1998-10-01_0000.txt
t_length = STRLEN('wind_spin-phase_0000-00-00_0000_to_0000-00-00_0000.txt') - 1L
mfile    = STRMID(STRCOMPRESS(allfiles[*],/REMOVE),t_length,/REVERSE)

sdate    = STRMID(mfile[*],16L,10L)      ; => Start date associated w/ file ['YYYY-MM-DD']
edate    = STRMID(mfile[*],35L,10L)      ; => End date associated w/ file ['YYYY-MM-DD']
; => Define corresponding time ranges
sta_tran = time_double(sdate+'/00:00:00.000')  ; => Unix times assoc. w/ start time in files
end_tran = time_double(edate+'/00:00:00.000')  ; => Unix times assoc. w/ end time in files
;-----------------------------------------------------------------------------------------
; => Find which file(s) is(are) needed
;-----------------------------------------------------------------------------------------
;good     = WHERE(tra[0] GE sta_tran AND tra[1] LE end_tran,gd)
; LBW III 02/02/2012
good     = WHERE(end_tran GE tra[0] AND sta_tran LE tra[1],gd)

IF (gd GT 0) THEN BEGIN
  tyfile = allfiles[good]
ENDIF ELSE BEGIN
  MESSAGE,'No files were found...',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE
;-----------------------------------------------------------------------------------------
; => Check the files
;-----------------------------------------------------------------------------------------
goodf  = WHERE(tyfile NE '',gg)
IF (gg GT 0) THEN BEGIN
  tyfile = tyfile[goodf]
ENDIF ELSE BEGIN
  MESSAGE,'No files were found...',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define dummy variables and read in data
;-----------------------------------------------------------------------------------------
nHeader = 38L                              ; => # of lines in the header
nf      = N_ELEMENTS(tyfile)
nlines  = 0L
FOR k=0L, nf - 1L DO nlines += FILE_LINES(tyfile[k]) - nHeader

header  = ''      ; => [KPAST,NF]-Element array of strings containing the file header
header  = REPLICATE(header[0],38L,nf)

ymdb    = REPLICATE('',nlines)  ; e.g. '1998-08-26/05:41:23.340'
sphase  = REPLICATE(d,nlines)   ; spin phase [rad]
sprate  = REPLICATE(d,nlines)   ; spin rate [rad/s]
stdspr  = REPLICATE(d,nlines)   ; spin rate std. dev. [rad/s]


; => string that marks the last line of the header
mform   = '(a23,2f14.5,E14.5)'
aa      = ''
bb      = REPLICATE(f,2)
cc      = f
end_hds = 'dd-mm-yyyy hh:mm:ss.ms            rad       rad/sec       rad/sec'
jj      = 0L
past    = 0
kpast   = 0
ii      = 0L
WHILE (jj LE nf - 1L) DO BEGIN
  gfile  = tyfile[jj]
  mline  = ''
  ;---------------------------------------------------------------------------------------
  ; => Open file
  ;---------------------------------------------------------------------------------------
  OPENR,gunit,gfile[0],ERROR=err,/GET_LUN
  ;---------------------------------------------------------------------------------------
  ; => Read in header as an array of strings
  ;---------------------------------------------------------------------------------------
  FOR kk=0L, nHeader - 1L DO BEGIN
    READF,gunit,mline
    header[kk,jj] = mline[0]
  ENDFOR
  nn     = FILE_LINES(tyfile[jj]) - nHeader
  FOR k=0L, nn - 1L DO BEGIN
    READF,gunit,FORMAT=mform,aa,bb,cc
    tdd00      = STRMID(aa[0L],6L,4L)+'-'+STRMID(aa[0L],3L,2L)+'-'+STRMID(aa[0L],0L,2L)  ; 'YYYY-MM-DD'
    tim00      = STRMID(aa[0L],11L)  ; 'hh:mm:ss.ms'
    ymdb[ii]   = tdd00[0]+'/'+tim00[0]  ;  e.g. '1998-08-26/00:00:59.340'
    sphase[ii] = bb[0]
    sprate[ii] = bb[1]
    stdspr[ii] = cc[0]
    ; => increase indices
    ii        += 1L
  ENDFOR
  ; => Close file
  FREE_LUN,gunit
  ;---------------------------------------------------------------------------------------
  ; => Update indices
  ;---------------------------------------------------------------------------------------
  jj   +=  1L
  past  =  0
  kpast = -1
ENDWHILE
;-----------------------------------------------------------------------------------------
; => sort data
;-----------------------------------------------------------------------------------------
unix     = time_double(ymdb)    ; => Convert to Unix times
sp       = SORT(unix)
IF KEYWORD_SET(tra) THEN BEGIN
  good = WHERE(unix[sp] GE tra[0] AND unix[sp] LE tra[1],gd)
  IF (gd GT 0) THEN sp = sp[good] ELSE RETURN,0
ENDIF
unix     = unix[sp]
ymdb     = ymdb[sp]
sphase   = sphase[sp]
sprate   = sprate[sp]
stdspr   = stdspr[sp]
; => Calculate spin rate in deg/s
sdrate   = sprate*18d1/!DPI
stdspd   = stdspr*18d1/!DPI
;-----------------------------------------------------------------------------------------
; => Define structure to return to user
;-----------------------------------------------------------------------------------------
tag0  = 'SPIN_'+['PHASE','RATE_R','RATE_R_STDDEV','RATE_D','RATE_D_STDDEV']
tags  = ['HEADER','SCETS','UNIX',tag0]
strut = CREATE_STRUCT(tags,header,ymdb,unix,sphase,sprate,stdspr,sdrate,stdspd)

RETURN,strut
END