;*****************************************************************************************
;
;  PROCEDURE:   time_substitute.pro
;  PURPOSE  :   Program called by time_string.pro for altering time arrays.
;
;  CALLED BY:   
;               time_string.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               DESTINATION    :  [N]-Element [string] array to be altered by SOURCE
;               SOURCE         :  [N]-Element [string] array to insert into DESTINATION
;                                   at character position defined by POS
;               POS            :  Scalar [long/integer] defining the character position
;                                   where SOURCE is to be inserted into DESTINATION
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NEXT_POSITION  :  Set to a named variable to return the character
;                                   position located after POS and the length of
;                                   SOURCE
;
;   CHANGED:  1)  Re-wrote and cleaned up
;                                                                  [09/08/2009   v1.1.0]
;             2)  Updated to be in accordance with newest version of time_substitute.pro
;                   in TDAS IDL libraries
;                   A)  Cleaned up and added some comments
;                                                                  [04/04/2012   v1.2.0]
;             3)  Updated Man. page and increased potential resolution for PRECISION
;                   keyword
;                                                                  [09/23/2015   v1.2.1]
;
;   NOTES:      
;               NA
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/23/2015   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

PRO time_substitute,destination,source,pos,NEXT_POSITION=p


p = -1     ;;  initialize
;;  Check input
IF (pos LT 0) THEN RETURN
IF (N_ELEMENTS(source) EQ 1) THEN BEGIN
  ;;  scalar input
  STRPUT,destination,source,pos
ENDIF ELSE BEGIN
  ;;  array input
  FOR i=0L, N_ELEMENTS(destination) - 1L DO BEGIN
    d = destination[i]
    STRPUT,d,source[i],pos
    destination[i] = d   ;;  Redefine DESTINATION
  ENDFOR
ENDELSE
;;  Define next/new position
p = pos + STRLEN(source[0])

;;  Return to Main Routine
RETURN
END

;+
;*****************************************************************************************
;
;  FUNCTION :   time_string.pro
;  PURPOSE  :   Converts an input time to a time/date string with a user defined
;                 level of precision.  The routine accepts Unix times, string times
;                 (i.e., see formats below), and structures accepted by time_struct.pro.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               time_substitute.pro
;
;  CALLS:
;               time_struct.pro
;               time_substitute.pro
;               time_double.pro
;
;  REQUIRES:    
;               1)  THEMIS SPEDAS/TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TIME0          :  Scalar or [N]-element array of the following type:
;                                   1)  Double    = Unix Time
;                                   2)  String    = 'YYYY-MM-DD/hh:mm:ss'
;                                   3)  Structure = format returned by time_struct.pro
;                                   4)  Float     = ?
;                                   5)  Long      = ?
;
;  EXAMPLES:    
;               test = time_string('2000-01-02/12:00:00.101010101017',PREC=12)
;               PRINT,';; ',test[0]
;               ;; 2000-01-02/12:00:00.1010101010170
;
;  KEYWORDS:    
;               FORMAT         :  Scalar [long] which specifies the output:
;                                   = 0   :  'YYYY-MM-DD/hh:mm:ss'
;                                   = 1   :  'YYYY Mon dd hhmm:ss'
;                                   = 2   :  'YYYYMMDD_hhmmss'
;                                   = 3   :  'YYYY MM dd hhmm:ss'
;                                   = 4   :  'YYYY-MM-DD/hh:mm:ss'
;                                   = 5   :  'YYYY/MM/DD hh:mm:ss'
;                                   = 6   :  'YYYYMMDDhhmmss'
;               PRECISION      :  Scalar [long] which specifies the precision:
;                                   = -5  :  Year only
;                                   = -4  :  Year, month
;                                   = -3  :  Year, month, date
;                                   = -2  :  Year, month, date, hour
;                                   = -1  :  Year, month, date, hour, minute
;                                   = 0   :  Year, month, date, hour, minute, sec
;                                   = >0  :  fractional seconds
;               EPOCH          :  If set, routine assumes input is double precision
;                                   EPOCH time
;               DATE_ONLY      :  Same as setting PRECISION = -3
;               TFORMAT        :  String with following format:  
;                                   "YYYY-MM-DD/hh:mm:ss.ff DOW TDIFF"
;                                   The following tokens are recognized:
;                                     YYYY  - 4 digit year
;                                     yy    - 2 digit year
;                                     MM    - 2 digit month
;                                     DD    - 2 digit date
;                                     hh    - 2 digit hour
;                                     mm    - 2 digit minute
;                                     ss    - 2 digit seconds
;                                     .fff   - fractional seconds
;                                     MTH   - 3 character month
;                                     DOW   - 3 character Day of week
;                                     DOY   - 3 character Day of Year
;                                     TDIFF - 5 character, hours different from UTC
;                                             (useful with LOCAL keyword)
;               LOCAL_TIME     :  If set, then local time is displayed
;               MSEC           :  Same as setting PRECISION = 3
;               SQL            :  If set, produces output format:
;                                   "YYYY-MM-DD hh:mm:ss.sss"
;                                   (quotes included) which convenient for
;                                    building SQL queries.
;               IS_LOCAL_TIME  :  Keyword used by time_struct.pro
;                                   [** not working correctly yet **]
;               AUTOPREC       :  If set, then PRECISION will automatically be set 
;                                   based on the TIME0 array
;               DELTAT         :  Scalar that will define PRECISION
;               TIMEZONE       :  Keyword used by time_struct.pro
;               BADSTRING      :  Scalar string valued used for bad time elements
;
;   CHANGED:  1)  Davin Larson changed something...
;                                                                  [11/01/2002   v1.0.14]
;             2)  Re-wrote and cleaned up
;                                                                  [09/08/2009   v1.1.0]
;             3)  THEMIS software update includes:
;                 a)  now calls time_substitute.pro
;                 b)  changed significant syntax
;                 c)  Added keywords:  TIMEZONE, LOCAL_TIME, IS_LOCAL_TIME, and BADSTRING
;                                                                  [09/08/2009   v1.2.0]
;             4)  Fixed typo created when updating for THEMIS software
;                                                                  [09/09/2009   v1.2.1]
;             5)  Updated to be in accordance with newest version of time_string.pro
;                   in TDAS IDL libraries
;                   A)  Cleaned up and added some comments
;                                                                  [04/04/2012   v1.3.0]
;             6)  Updated Man. page and increased potential resolution for PRECISION
;                   keyword
;                                                                  [09/23/2015   v1.3.1]
;
;   NOTES:      
;               1)  If TFORMAT is set, then the following keywords are ignored:
;                     A)  FORMAT
;                     B)  SQL
;                     C)  PRECISION
;                     D)  AUTOPREC
;                     E)  DELTAT
;                     F)  DATE_ONLY
;                     G)  MSEC
;               2)  This routine works on vectors and is designed to be fast.
;               3)  Output will have the same dimensions as the input.
;               4)  See also:  time_double.pro and time_struct.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  Oct 1996
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/23/2015   v1.3.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION time_string,time0,FORMAT=format,PRECISION=prec,EPOCH=epoch,DATE_ONLY=date_only, $
                           TFORMAT=tformat,LOCAL_TIME=local_time,MSEC=msec,SQL=sql,      $
                           IS_LOCAL_TIME=is_local_time,AUTOPREC=autoprec,DELTAT=dt,      $
                           TIMEZONE=timezone,BADSTRING=badstring

;;----------------------------------------------------------------------------------------
;;  Define some dummy logic variables
;;----------------------------------------------------------------------------------------
ms             = ['   ','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
dow            = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
prec_form      = "(f25.23)"
;;if not keyword_set(badstring) then badstring='NULL'

IF KEYWORD_SET(msec) THEN prec = 3
;;----------------------------------------------------------------------------------------
;;  Determine size and type of variable time
;;----------------------------------------------------------------------------------------
ttype = SIZE(time0,/TYPE)
IF (ttype EQ 0) THEN BEGIN
   s = ''
   PRINT,'Enter time(s)  (YYYY-MM-DD/hh:mm:ss)  blank line to quit:'
   READ,s
   time0 = s
   WHILE KEYWORD_SET(s) DO BEGIN
     READ,s
     IF KEYWORD_SET(s) THEN time0 = [time0,s]
   ENDWHILE
ENDIF
ttype = SIZE(time0,/TYPE)
IF (ttype EQ  4 AND N_ELEMENTS(prec) EQ 0) THEN prec = -1
;;----------------------------------------------------------------------------------------
;;  Force input to a structure type
;;----------------------------------------------------------------------------------------
IF (ttype NE 8) THEN BEGIN
  ;;  Input is NOT a structure => force it to be a structure
  time = time_struct(time0,EPOCH=epoch,TIMEZONE=timezone,$
                           LOCAL_TIME=local_time,IS_LOCAL_TIME=is_local_time)
ENDIF ELSE BEGIN
  ;;  Input is a structure
  time = time0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  
;;----------------------------------------------------------------------------------------
ttype  = SIZE(time,/TYPE)
t0ndim = SIZE(/N_DIMENSIONS,time0)
t0ddim = SIZE(/DIMENSIONS,time0)
IF KEYWORD_SET(tformat) THEN BEGIN
  IF (t0ndim EQ 0) THEN BEGIN
    res = tformat
  ENDIF ELSE BEGIN
    res = MAKE_ARRAY(VALUE=tformat,DIM=t0ddim)
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  define start position
  ;;--------------------------------------------------------------------------------------
  pos = 0
  REPEAT time_substitute,res, dow[time.DOW],                                     STRPOS(tformat,'DOW',pos)  ,NEXT_POSITION=pos  UNTIL (pos LT 0)
  REPEAT time_substitute,res, ms[time.MONTH],                                    STRPOS(tformat,'MTH',pos)  ,NEXT_POSITION=pos  UNTIL (pos LT 0)
  REPEAT time_substitute,res, STRING(time.YEAR,        FORMAT='(i4.4)'),         STRPOS(tformat,'YYYY',pos) ,NEXT_POSITION=pos  UNTIL (pos LT 0)
  REPEAT time_substitute,res, STRING(time.YEAR MOD 100,FORMAT='(i2.2)'),         STRPOS(tformat,'yy',pos)   ,NEXT_POSITION=pos  UNTIL (pos LT 0)
  REPEAT time_substitute,res, STRING(time.MONTH,       FORMAT='(i2.2)'),         STRPOS(tformat,'MM',pos)   ,NEXT_POSITION=pos  UNTIL (pos LT 0)
  REPEAT time_substitute,res, STRING(time.DATE,        FORMAT='(i2.2)'),         STRPOS(tformat,'DD',pos)   ,NEXT_POSITION=pos  UNTIL (pos LT 0)
  REPEAT time_substitute,res, STRING(time.HOUR,        FORMAT='(i2.2)'),         STRPOS(tformat,'hh',pos)   ,NEXT_POSITION=pos  UNTIL (pos LT 0)
  REPEAT time_substitute,res, STRING(time.MIN,         FORMAT='(i2.2)'),         STRPOS(tformat,'mm',pos)   ,NEXT_POSITION=pos  UNTIL (pos LT 0)
  REPEAT time_substitute,res, STRING(time.SEC,         FORMAT='(i2.2)'),         STRPOS(tformat,'ss',pos)   ,NEXT_POSITION=pos  UNTIL (pos LT 0)
  REPEAT time_substitute,res, STRING(time.DOY,         FORMAT='(i3.3)'),         STRPOS(tformat,'DOY',pos)  ,NEXT_POSITION=pos  UNTIL (pos LT 0)
  REPEAT time_substitute,res, STRING(time.TDIFF,       FORMAT='("(",i+3.2,")")'),STRPOS(tformat,'TDIFF',pos),NEXT_POSITION=pos  UNTIL (pos LT 0)
  token='.'
  REPEAT BEGIN
    token = token+'f'
    pos   = STRPOS(tformat,token)
  ENDREP UNTIL STRPOS(tformat,token+'f') LT 0
  ;;--------------------------------------------------------------------------------------
  ;;  Call time_substitute.pro
  ;;--------------------------------------------------------------------------------------
  time_substitute,res,STRMID(STRING(time.FSEC,FORMAT='(f10.8)'),1,STRLEN(token)), pos
;  time_substitute,res,STRMID(STRING(time.FSEC,FORMAT=prec_form[0]),1,STRLEN(token)),pos    ;;  Increased resolution considerably
  ;;  Return result
  RETURN,res
ENDIF ELSE BEGIN
  IF (t0ndim EQ 0) THEN BEGIN
    res = ''
  ENDIF ELSE BEGIN
    res = MAKE_ARRAY(VALUE='',DIM=t0ddim)
  ENDELSE
  IF NOT KEYWORD_SET(format) THEN fmt = 0 ELSE fmt = format
  
  IF KEYWORD_SET(sql) THEN BEGIN
    prec = 3  ;;  precision of 3 decimal places
    fmt  = 4
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Determine output format
  ;;--------------------------------------------------------------------------------------
  CASE fmt OF
    0 : f = '(i4.4,"-",i2.2,"-",i2.2,"/",i2.2,":",i2.2,":",i2.2)'
    1 : f = '(i4.4," ",a," ",i2.2," ",i2.2,i2.2,":",i2.2)'
    2 : f = '(i4.4,i2.2,i2.2,"_",i2.2,i2.2,i2.2)'
    3 : f = '(i4.4," ",i2.2," ",i2.2," ",i2.2," ",i2.2," ",i2.2)'
    4 : f = '(i4.4,"-",i2.2,"-",i2.2," ",i2.2,":",i2.2,":",i2.2)'
    5 : f = '(i4.4,"/",i2.2,"/",i2.2," ",i2.2,":",i2.2,":",i2.2)'
    6 : f = '(i4.4,i2.2,i2.2,i2.2,i2.2,i2.2)'
  ENDCASE
  ;;--------------------------------------------------------------------------------------
  ;;  Check to see if user wants program to determine precision of output
  ;;--------------------------------------------------------------------------------------
  IF (KEYWORD_SET(autoprec) OR KEYWORD_SET(dt)) THEN BEGIN
    IF (N_ELEMENTS(time) GE 1 AND KEYWORD_SET(autoprec)) THEN BEGIN
      ;;  let routine determine the precision
      td = time_double(time)
      td = td[SORT(td)]
      dt = MIN(ABS(td - SHIFT(td,1)),/NAN)
    ENDIF
    IF (dt LE 0) THEN dt = 1
    prec = -5
    IF (dt LT 364*864d2) THEN prec = -4                     ;;  months
    IF (dt LT 6d1*864d2) THEN prec = -3                     ;;  days
    IF (dt LT 12*36d2)   THEN prec = -1                     ;;  minutes
    IF (dt LT 6d1)       THEN prec =  0                     ;;  seconds
    IF (dt LT 1d0)       THEN prec = FLOOR(1 - ALOG10(dt))  ;;  fraction of a second
  ENDIF
  
  IF KEYWORD_SET(date_only) THEN prec = -3  ;;  force output to resolution of days
  ;;--------------------------------------------------------------------------------------
  ;;  find cutoff character position in string
  ;;--------------------------------------------------------------------------------------
  IF KEYWORD_SET(prec) THEN BEGIN
    posits = [[16,13,10,7,4],[16,14,11,8,4],[13,11,8,6,4],[16,13,10,7,4],$
              [16,13,10,7,4],[16,13,10,7,4],[12,10,8,6,4]]
    IF (prec GT 0) THEN pos = prec ELSE pos = -posits[-prec-1,fmt]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  check for structure type
  ;;--------------------------------------------------------------------------------------
  IF (ttype EQ 8) THEN BEGIN
    ;;  Input is a structure
    FOR i=0L, N_ELEMENTS(time) - 1L DO BEGIN
      t = time[i]
      CASE fmt OF
        0    : s = STRING(FORMAT=f,t.YEAR,t.MONTH,t.DATE,t.HOUR,t.MIN,t.SEC)
        1    : s = STRING(FORMAT=f,t.YEAR,ms[t.MONTH],t.DATE,t.HOUR,t.MIN,t.SEC)
        ELSE : s = STRING(FORMAT=f,t.YEAR,t.MONTH,t.DATE,t.HOUR,t.MIN,t.SEC)
      ENDCASE
      IF KEYWORD_SET(pos) THEN BEGIN
        ;;  (pos > 0) -> add fractional seconds
        ;;  (pos < 0) -> remove resolution
;        IF (pos GT 0) THEN s += STRMID(STRING(t.FSEC,FORMAT="(f16.14)"),1,pos+1)
        IF (pos GT 0) THEN s += STRMID(STRING(t.FSEC,FORMAT=prec_form[0]),1,pos+1)    ;;  Increased resolution considerably
        IF (pos LT 0) THEN s  = STRMID(s,0,-pos)
      ENDIF
      res[i] = s
    ENDFOR
    IF KEYWORD_SET(sql) THEN BEGIN
      res = '"' + res + '"'
    ENDIF
    IF KEYWORD_SET(badstring) THEN BEGIN
      ;;  replace "bad" strings with user defined input
      notgood = WHERE(FINITE(time.SOD) EQ 0,ntg)
      IF (ntg GT 0) THEN res[notgood] = badstring
    ENDIF
    RETURN,res
  ENDIF
ENDELSE

;;  should not get here...
MESSAGE,'Improper input:  TIME0',/CONTINUE,/INFORMATIONAL
END


