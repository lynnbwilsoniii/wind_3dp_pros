;+
;*****************************************************************************************
;
;  FUNCTION :   time_range_define.pro
;  PURPOSE  :   The program defines a time range from an input date or 2 element Unix
;                 time range with various formatted outputs.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               time_double.pro
;               my_time_string.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               DATE    :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures [Unix time]
;
;   CHANGED:  1)  Fixed issue that occurred when neither keyword is set
;                                                                   [02/02/2012   v1.0.1]
;
;   NOTES:      
;               
;
;   CREATED:  11/22/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/02/2012   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION time_range_define,DATE=date,TRANGE=trange

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
tdate  = ''              ; => Date 'YYYY-MM-DD'
sdate  = ''              ; => Date 'MMDDYY'
fdates = ''              ; => Date 'MM-DD-YYYY'
st_st  = ''              ; => Time 'YYYY-MM-DD/hh:mm:ss'
st_et  = ''              ; => Time 'YYYY-MM-DD/hh:mm:ss'
tr_str = ''              ; => Time Range 'YYYY-MM-DD/hh:mm:ss'
tags   = ['S_DATE_SE','TDATE_SE','FDATE_SE','TR_STRING','TR_UNIX']
;-----------------------------------------------------------------------------------------
; => Determine date of interest
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(trange) THEN BEGIN
  IF KEYWORD_SET(date) THEN BEGIN
    ; => Only DATE set
    mydate  = my_str_date(DATE=date)
    ndays   = N_ELEMENTS(mydate.TDATE)
    tdate   = mydate.TDATE
    sdates  = mydate.S_DATE
    fdates  = STRMID(tdate[*],5L,2L)+'-'+STRMID(tdate[*],8L,2L)+'-'+STRMID(tdate[*],0L,4L)
  ENDIF ELSE BEGIN
    ; => Neither keyword was set
    mydate  = my_str_date(DATE=date)
    ndays   = 1L
    tdate   = mydate.TDATE[0]
    sdates  = mydate.S_DATE[0]
    fdates  = STRMID(tdate[0],5L,2L)+'-'+STRMID(tdate[0],8L,2L)+'-'+STRMID(tdate[0],0L,4L)
  ENDELSE
  ;---------------------------------------------------------------------------------------
  ; => Define start and end day string
  ;---------------------------------------------------------------------------------------
  IF (ndays GT 1) THEN BEGIN
    start_date = fdates[0]
    end_date   = fdates[ndays - 1L]
  ENDIF ELSE BEGIN
    start_date = fdates[0]
    end_date   = start_date
    ; => Redefine dates
    tdate      = [tdate[0],tdate[0]]
    sdates     = [sdates[0],sdates[0]]
    fdates     = [fdates[0],fdates[0]]
  ENDELSE
  ymd0   = [tdate[0]+'/00:00:00',tdate[1]+'/23:59:59']
  tra    = time_double(ymd0)
ENDIF ELSE BEGIN
  ; => Time Range Defined
  tra    = time_double(trange)
  sp     = SORT(tra)
  tra    = tra[sp]
  ;---------------------------------------------------------------------------------------
  ; => Format time range
  ;---------------------------------------------------------------------------------------
  mts    = my_time_string(tra,UNIX=1,/NOM)
  ymd0   = mts.DATE_TIME    ; => 'YYYY-MM-DD/HH:MM:SS.sss'
  uni0   = mts.UNIX
  tra    = uni0
  fdates = STRMID(ymd0[*],5L,2L)+'-'+STRMID(ymd0[*],8L,2L)+'-'+STRMID(ymd0[*],0L,4L)
  sdates = STRMID(ymd0[*],5L,2L)+STRMID(ymd0[*],8L,2L)+STRMID(ymd0[*],2L,2L)
  mydate = my_str_date(DATE=sdates)
  ; => initial guess at # of days
  t0     = time_double(STRMID(ymd0[0],0L,10L)+'/00:00:00')
  t1     = time_double(STRMID(ymd0[1],0L,10L)+'/00:00:01')
  ndays  = FLOOR((t1[0] - t0[0])/864d2) + 1L
;  ndays  = FLOOR((MAX(uni0,/NAN) - MIN(uni0,/NAN))/864d2) + 1L
  IF (ndays LE 0) THEN ndays = 1L   ; => in case less than a day is desired
  ;---------------------------------------------------------------------------------------
  ; => Define start and end day string
  ;---------------------------------------------------------------------------------------
  IF (ndays GT 1) THEN BEGIN
    start_date = fdates[0L]
    end_date   = fdates[1L]
    tdate      = mydate.TDATE
  ENDIF ELSE BEGIN
    start_date = fdates[0]
    end_date   = start_date
    tdate      = [mydate.TDATE[0],mydate.TDATE[0]]
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define return structure
;-----------------------------------------------------------------------------------------
struc    = CREATE_STRUCT(tags,sdates,tdate,fdates,ymd0,tra)

RETURN,struc
END
