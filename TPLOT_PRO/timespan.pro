;+
;*****************************************************************************************
;
;  FUNCTION :   timespan.pro
;  PURPOSE  :   Define a time span for the "tplot" routine.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               time_double.pro
;               str_element.pro
;               time_string.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               T1  :  Scalar defining the start time in formats accepted by 
;                        time_struct.pro
;               DT  :  Scalar defining the duration of the time span
;                        [Default:  days]
;
;  EXAMPLES:    
;               timespan, '1995-06-19'
;               
;
;  KEYWORDS:    
;               DAYS       :  If set, the resolution of DT is in # of days
;               HOURS      :  " " hours
;               MINUTES    :  " " minutes
;               SECONDS    :  " " seconds
;
;   CHANGED:  1)  ?? Davin changed something                       [06/04/1997   v1.0.14]
;             2)  Re-wrote and cleaned up                          [12/07/2010   v1.1.0]
;
;   NOTES:      
;               1)  See also time_struct.pro, time_double.pro, or time_string.pro
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  12/07/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO timespan,t1,dt,                       $
                   DAYS      = days,      $
                   HOURS     = hours,     $
                   MINUTES   = minutes,   $
                   SECONDS   = seconds

;-----------------------------------------------------------------------------------------
; => Load common blocks
;-----------------------------------------------------------------------------------------
@tplot_com.pro
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (SIZE(t1,/TYPE) EQ 0) THEN BEGIN
   t1         = ''
   dt         = 0d0
   time_units = ''
   READ,t1,PROMPT='Start time  (format: yy-mm-dd/hh:mm:ss)? '
   READ,dt,PROMPT='Duration (# of days)? '
   days       = 1
   hours      = 0
   minutes    = 0
   seconds    = 0
ENDIF

IF (N_ELEMENTS(t1) EQ 2) THEN BEGIN
  tr = time_double(t1)
ENDIF ELSE BEGIN
  start_time = time_double(t1)
  IF (N_ELEMENTS(dt) NE 0) THEN BEGIN
    CASE 1 OF
      KEYWORD_SET(days):    deltat = dt * 86400.
      KEYWORD_SET(hours):   deltat = dt * 3600.
      KEYWORD_SET(minutes): deltat = dt * 60.
      KEYWORD_SET(seconds): deltat = dt
      ELSE:                 deltat = dt * 86400.
    ENDCASE
  ENDIF ELSE deltat = 86400.
  tr = [start_time,start_time+deltat]
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define time range
;-----------------------------------------------------------------------------------------
PRINT,'Time range set from ',time_string(tr[0]),' to ',time_string(tr[1])
str_element,tplot_vars,'OPTIONS.TRANGE_FULL',tr,/ADD_REPLACE
str_element,tplot_vars,'OPTIONS.TRANGE_CUR' ,tr,/ADD_REPLACE
str_element,tplot_vars,'OPTIONS.TRANGE'     ,tr,/ADD_REPLACE
;-----------------------------------------------------------------------------------------
; => Define reference date
;-----------------------------------------------------------------------------------------
str     = time_string(tr[0])
refdate = STRMID(str[0],0,STRPOS(str[0],'/'))
str_element,tplot_vars,'OPTIONS.REFDATE',refdate,/ADD_REPLACE

RETURN
END
