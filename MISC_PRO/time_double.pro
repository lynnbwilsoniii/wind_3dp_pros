;+
;*****************************************************************************************
;
;  FUNCTION :   time_double.pro
;  PURPOSE  :   A fast, vectorized routine that returns the number of seconds since 1970,
;                 a.k.a. Unix time.
;
;  CALLED BY:   
;               time_epoch.pro
;               time_string.pro
;               time_struct.pro
;               time_ticks.pro
;
;  CALLS:
;               time_double.pro
;               time_struct.pro
;               time_string.pro
;               add_tt2000_offset.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TIME           :  Scalar or array of one of the following types:
;                                   1)  DOUBLE     :  Unix time (s)
;                                   2)  STRING     :  YYYY-MM-DD/hh:mm:ss.xxx
;                                   3)  STRUCTURE  :  Format returned by time_struct.pro
;                                   4)  LONG ARRAY :  2-Dimensional PB5 time (CDF files)
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               EPOCH          :  If set, implies the input, TIME, is a double precision
;                                   Epoch time
;               DIM            :  Set to the dimensions of the input
;               PB5            :  If set, implies the input, TIME, is a PB5 time
;               MMDDYYYY       :  Keyword used by time_struct.pro
;                                   [changes order of date output]
;               TIMEZONE       :  Keyword used by time_struct.pro
;               IS_LOCAL_TIME  :  Keyword used by time_struct.pro
;                                   [** not working correctly yet **]
;               TT2000         :  If set, it implies that the input is a 64 bit
;                                   signed integer, TT2000 time: leaped nanoseconds
;                                   since J2000
;
;   CHANGED:  1)  Davin Larson changed something...                [07/12/2001   v1.0.9]
;             2)  Re-wrote and cleaned up                          [06/23/2009   v1.1.0]
;             3)  Fixed typo which seemed to only affect long (> 1 month) time
;                   ranges                                         [03/16/2010   v1.2.0]
;             4)  Updated to be in accordance with newest version of time_double.pro
;                   in TDAS IDL libraries
;                   A)  Cleaned up and added some comments
;                   B)  no longer calls pb5_to_time.pro
;                   C)  new keywords:  MMDDYYYY, TIMEZONE, and IS_LOCAL_TIME
;                                                                  [04/04/2012   v1.3.0]
;             5)  Updated to be in accordance with newest version of time_double.pro
;                   in TDAS IDL libraries [thmsw_r10908_2012-09-10]
;                   A)  new keywords:  TT2000
;                                                                  [09/12/2012   v1.4.0]
;
;   NOTES:      
;               1)  See also:  time_string.pro and time_struct.pro
;
;   CREATED:  October, 1996
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/12/2012   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION time_double,time,EPOCH=epoch,DIM=dim,PB5=pb5,MMDDYYYY=mmddyyyy,$
                     TIMEZONE=timezone,IS_LOCAL_TIME=is_local_time,TT2000=tt2000

;;----------------------------------------------------------------------------------------
;; => Determine type of input
;;----------------------------------------------------------------------------------------
ntyp0 = (SIZE(time,/TYPE))[0]
CASE ntyp0 OF
  8   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Structure Input
    ;;------------------------------------------------------------------------------------
    ; => Day number of 1970-01-01 = 719162L
    dn1970  = 1969L*365L + 1969L/4 - 1969L/100 + 1969L/400  ; => Day number of 1970-1-1
    mdt     = [[0, 31,  59,  90, 120, 151, 181, 212, 243, 273, 304, 334, 365], $
               [0, 31,  60,  91, 121, 152, 182, 213, 244, 274, 305, 335, 366]]
    month   = time.MONTH - 1
    date    = time.DATE - 1
    dy      = FLOOR(month/12.)
    year    = time.YEAR + dy
    month   = month - dy*12
    isleap  = ((year MOD 4) EQ 0) - ((year MOD 100) EQ 0) +  $
               ((year MOD 400) EQ 0) - ((year MOD 4000) EQ 0)
    doy     = mdt[month,isleap] + date
    seconds = (time.HOUR*6d1 + time.MIN)*6d1 + time.SEC + time.FSEC
    y       = year - 1
    daynum  = (y*365L + y/4L - y/100L + y/400L - y/4000L) + doy
    seconds = (daynum - dn1970)*36d2*24d0 + seconds
    ndim0   = (SIZE(dim,/N_DIMENSIONS))[0]
    IF (ndim0 EQ 1) THEN IF (dim[0] EQ 1) THEN seconds = [seconds]  ;!!! IDL BUG
    RETURN,seconds
  END
  7   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => String Input
    ;;------------------------------------------------------------------------------------
    dims = SIZE(time,/DIMENSIONS)
    temp = time_struct(time,/NO_CLEAN,MMDDYYYY=mmddyyyy,TIMEZONE=timezone,IS_LOCAL_TIME=is_local_time)
;  TDAS Update
;    RETURN,time_double(time_struct(time,/NO_CLEAN),DIM=dims)
    RETURN,time_double(temp,DIM=dims[0])
  END
  5   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Double Precision Input
    ;;------------------------------------------------------------------------------------
    IF KEYWORD_SET(epoch) THEN RETURN, time/1d3 - 719528d0*24d0*36d2
    RETURN,time
  END
;  TDAS Update
  9   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => handle CDF_EPOCH16
    ;;------------------------------------------------------------------------------------
    IF KEYWORD_SET(epoch) THEN BEGIN
      temp = REAL_PART(time) - 719528d0*24d0*36d2 + IMAGINARY(time)*1d-12
      RETURN, temp
    ENDIF
    MESSAGE,'Improper time input',/INFORMATIONAL
  END
  4   : RETURN,DOUBLE(time)     ; => Floating Point Input
  14  : BEGIN
;  TDAS Update
    IF KEYWORD_SET(tt2000) THEN BEGIN
      ;; nanoseconds since J2000 coverted into seconds + seconds since 1970-01-01 
      ;;   TAI - historical skew between TAI & TT epochs - leap seconds since J2000.0
      RETURN,add_tt2000_offset(DOUBLE(time)/1d9 + time_double('2000-01-01/12:00:00'),/SUBTRACT)
    ENDIF ELSE BEGIN
      RETURN,DOUBLE(time)     ; => 64 Bit Long Integer Input
    ENDELSE
  END
;  TDAS Update
  2   : RETURN,DOUBLE(time)     ; => Integer Integer Input
  3   : BEGIN
;  TDAS Update
;    IF KEYWORD_SET(pb5) THEN RETURN, pb5_to_time(time)
    RETURN,DOUBLE(time)         ; => Long Integer Input
  END
  0   : RETURN,time_double(time_string(time,PREC=6))    ; => Undefined Input
  ELSE : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => bad input
    ;;------------------------------------------------------------------------------------
    MESSAGE,'Improper time input',/INFORMATIONAL
  END
ENDCASE


END
