;+
;*****************************************************************************************
;
;  FUNCTION :   gettime.pro
;  PURPOSE  :   Returns a Unix time for various types of inputs.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               str_element.pro
;               time_string.pro
;               ctime.pro
;               time_double.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X         :  Null, double, string, or integer [see examples]
;
;  EXAMPLES:    
;               t = gettime('95-7-4/12:34')
;               t = gettime('12:34:56')          ; => (get time on reference date)
;               t = gettime(t+300.)              ; => (assumes t is a double)
;               t = gettime(10)                  ; => (t = 10 am on reference date)
;               t = gettime(/KEYBOARD)           ; => (prompts user for time on reference date)
;               t = gettime(KEYBOARD='Enter time: ')
;               t = gettime(/CURSOR)             ; => (select time using cursor in tplot routine)
;
;  KEYWORDS:    
;               KEYBOARD  :  If non-zero, then user is prompted to enter a time
;                              If string, then the string is used as a prompt
;               CURSOR    :  If set, then user selects time with cursor
;               VALUES    :  If CURSOR also set, then returns data values for time chosen
;               REFDATE   :  Scalar string used to define the reference date
;                              [Format = 'yyyy-mm-dd']
;
;   CHANGED:  1)  Davin changed something                          [08/02/1998   v1.0.17]
;             2)  Fixed up man page, program, and other minor changes 
;                                                                  [02/18/2011   v1.1.0]
;
;   NOTES:      
;               1)  The procedure "load_3dp_data" must be called prior to use
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  02/18/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION gettime,x,KEYBOARD=key,CURSOR=curs,VALUES=vals,REFDATE=refdate

;-----------------------------------------------------------------------------------------
; => Load common blocks
;-----------------------------------------------------------------------------------------
@tplot_com.pro

IF (N_ELEMENTS(x) NE 0) THEN t = x
;-----------------------------------------------------------------------------------------
; => Check REFDATE keyword
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(refdate) THEN BEGIN
  temp = STRMID(time_string(refdate),0,10)
  str_element,tplot_vars,'OPTIONS.REFDATE',temp,/ADD_REPLACE
ENDIF
;-----------------------------------------------------------------------------------------
; => Check KEYBOARD keyword
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(key) THEN BEGIN
  IF (SIZE(key,/TYPE) NE 7) THEN BEGIN
    key = 'Enter time for '+tplot_vars.OPTIONS.REFDATE+': (hh:mm:ss) '
  ENDIF
  t = '' 
  READ,t,PROMPT=key
ENDIF
;-----------------------------------------------------------------------------------------
; => Check CURSOR keyword
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(curs) THEN ctime,t,vals,NPOINTS=curs

IF (N_ELEMENTS(t) EQ 0) THEN RETURN,time_double(tplot_vars.OPTIONS.REFDATE) ; default

;-----------------------------------------------------------------------------------------
; => Check if string was input
;-----------------------------------------------------------------------------------------
IF (SIZE(t,/TYPE) EQ 7) THEN BEGIN
  IF (STRPOS(t[0],'/') EQ -1 AND STRPOS(t[0],'-') EQ -1) THEN BEGIN
    t = tplot_vars.OPTIONS.REFDATE+'/'+t
  ENDIF
  t = time_double(t) 
ENDIF ELSE t = DOUBLE(t)

str_element,tplot_vars,'OPTIONS.REFDATE',tplot_refdate
IF (t[0] LT 1e8) THEN t = time_double(tplot_refdate) + t*3600.   ; hours

IF N_ELEMENTS(tplot_refdate) EQ 0 THEN BEGIN
  str_element,tplot_vars,'OPTIONS.REFDATE','1970-1-1',/ADD_REPLACE
ENDIF

IF (N_ELEMENTS(t) EQ 1) THEN t = t[0]

RETURN,t
END

