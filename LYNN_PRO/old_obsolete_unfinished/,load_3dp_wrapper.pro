;+
;*****************************************************************************************
;
;  FUNCTION :   load_3dp_wrapper.pro
;  PURPOSE  :   This is a wrapping program for load_3dp_data.pro which loads Wind
;                 data from the 3-Dimensional Plasma Instrument (3DP) for a given
;                 date and time range.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               my_time_string.pro
;               load_3dp_data.pro
;
;  REQUIRES:    
;               WindLib Libraries and the following shared objects:
;                 wind3dp_lib_ls32.so
;                 wind3dp_lib_ss32.so
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               DATE      :  [string] date of 3DP data desired ('MMDDYY')
;               QUALITY   :  [integer] specifying the quality of data 
;                              [Default = 2]
;               DURATION  :  [float,integer,long] amount of data in hours 
;                              [Default = 24]
;               TRANGE    :  [Double] 2-Element array specifying the time range over 
;                              which to get data structures for [Unix time]
;               MEMSIZE   :  Option that allows one to allocate more memory for IDL
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   CREATED:  08/05/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO load_3dp_wrapper,DATE=date,QUALITY=quality,DURATION=duration,TRANGE=trange,$
                     MEMSIZE=memsize

;-----------------------------------------------------------------------------------------
; -Define dummy variables
;-----------------------------------------------------------------------------------------
f         = !VALUES.F_NAN
d         = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; -Get Date associated with files of interest
;-----------------------------------------------------------------------------------------
mydate  = my_str_date(DATE=date)
date    = mydate.S_DATE[0]  ; -('MMDDYY')
mdate   = mydate.DATE[0]    ; -('YYYYMMDD')
tdate   = mydate.TDATE[0]   ; -['YYYY-MM-DD']

3dpdate = mydate.YY[0]+'-'+mydate.MM[0]+'-'+mydate.DD[0]+'/'
;-----------------------------------------------------------------------------------------
; => Check input parameters
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(quality)  THEN quality  = 2
IF KEYWORD_SET(trange) THEN BEGIN
  mts     = my_time_string(trange,UNIX=1)
  ymdb    = mts.DATE_TIME
  sdate   = STRMID(ymdb[0],0L,10L)          ; => ['YYYY-MM-DD']
  stime   = STRMID(ymdb[0],11L,8L)          ; => ['HH:MM:SS.sss']
  s3dpd   = STRMID(sdate,2L,2L)+'-'+STRMID(sdate,5L,2L)+'-'+STRMID(sdate,8L,2L)+'/'
  3dpdate = s3dpd+stime
  delta   = (trange[1] - trange[0])/36d2
ENDIF ELSE BEGIN
  3dpdate = 3dpdate+'00:00:00'
  delta   = 24d0
ENDELSE
IF NOT KEYWORD_SET(duration) THEN duration = delta
;-----------------------------------------------------------------------------------------
; => Load 3DP data
;-----------------------------------------------------------------------------------------
load_3dp_data,3dpdate,duration,MEMSIZE=memsize,QUALITY=quality


END