;+
; FUNCTION:
; 	 DATESEC
;
; DESCRIPTION:
;
;	function to parse out a date string of either the form [YY]YY-MM-DD 
;	(e.g. '1989-10-1' or '89-10-1), DD/MM/YY (e.g. '1/10/89'), DD MMM YY
;	(e.g. '1 Oct 89' or '1 OCT 89', case ingnored) or YYYY/MM/DD 
;	(e.g. 1989/10/01, where the first field is greater than 31).  The
;	RETURN value is double float in seconds since 1 Jan 1970, 00:00 UT.
;
; USAGE (SAMPLE CODE FRAGMENT):
; 
;    
;    ; seconds since 1970 
;
;	string_date = '21 Mar 91'
;    
;    ; convert to string    
;    
;	seconds_date = datesec(string_date)
;    
;    ; print it out
;    
;	PRINT, seconds_date
;
; --- Sample output would be 
;    
;	6.6951720e+08
;    
;
; NOTES:
;
;	If conversion fails, this function returns -1.
;
;	For the forth input format to work (YYYY/MM/DD), the year
;	specified must be greater than 31, otherwise the DD/MM/YY
;	format assumed.
;
; 	Note that NO combination of of input formats will work.  Also, all
; 	three fields must be present.  
;
;	If any of the fields is to large then a carry operation will occur.  
; 	i.e. 34/13/89 would come out to year 90, month 2, day 3.
;
;	If input seconds is an array, then an array of 
;	N_ELEMENTS(inputs vals) of date strings and remainders will be returned.
;
;
; REVISION HISTORY:
;
;	@(#)datesec.pro	1.6 08/17/95 	
; 	Originally written by Jonathan M. Loran,  University of 
; 	California at Berkeley, Space Sciences Lab.   Sep. '91
;
;	Revised to handle arrays of input values, JML, Jan. '92
;-




FUNCTION datesec, stringin

; months as strings

months= $   ; months in upper case string form
  ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']

; days in a month for leap and non-leap years

daytable= [[0,31,28,31,30,31,30,31,31,30,31,30,31] $
          ,[0,31,29,31,30,31,30,31,31,30,31,30,31]]

; other various constants

daysinleap    = 366
daysinnonleap = 365

secinday   = 86400.D      ; seconds in a day

; set exception handling

ON_IOERROR, badconv

; set up first output buf

output=0.0D

; loop for all input values

FOR i=0,N_ELEMENTS(stringin)-1 DO BEGIN

;     extend output, if necessary

	IF i GT 0 THEN  output = [output,0.0D]

	trimst = STRTRIM(stringin(i), 2) ; trim off leading and trailing white space

;     find out delemitation:

	IF STRPOS(trimst,'-') NE -1 THEN $
		delimit='-'  $
	ELSE IF STRPOS(trimst,'/') NE -1 THEN $
		delimit='/'  $
	ELSE IF STRPOS(trimst,' ') NE -1 THEN $
		delimit=' '  $
	ELSE $
		delimit='-'

;     set default day and month in case they are misssing

        IF delimit EQ '-' THEN BEGIN 
           sday = '70' 
           smon = '1'
           syr = '1'
        ENDIF ELSE BEGIN
           sday = '1' 
           smon = '1'
           syr = '70'
        ENDELSE
        
;     now seperate out the "day" "month" "year"

        IF STRLEN (trimst) GT 0 THEN BEGIN 
           IF STRPOS(trimst, delimit) GT 0 THEN delimpos = STRPOS(trimst, delimit)    $
             ELSE delimpos = 4

           sday = STRTRIM(STRMID(trimst, 0, delimpos), 2)       ; get first element 

           trimst = STRTRIM(STRMID(trimst, STRLEN(sday)+1 $ 
		,STRLEN(trimst)-(STRLEN(sday)+1)),2)            ; remove first element

           IF STRLEN(trimst) GT 0 THEN  BEGIN
           
              IF STRPOS(trimst, delimit) GT 0 THEN delimpos = STRPOS(trimst, delimit)    $
                ELSE delimpos = 3

              smon = STRTRIM(STRMID(trimst, 0, delimpos), 2)    ; get 2nd element

              trimst = STRTRIM(STRMID(trimst, STRLEN(smon)+1 $  ; remove 2nd element
                                      , STRLEN(trimst)-(STRLEN(smon)+1)), 2)

              IF (STRLEN(trimst) GT 0) THEN       $
                syr  = STRTRIM(trimst, 2)                       ; get last element
           ENDIF
        ENDIF 

;     convert to ints

	IF delimit EQ ' ' THEN  $              ; mon in word form
		mon = FIX(WHERE(STRUPCASE(STRTRIM(STRMID(smon,0,3),2)) $
			EQ months)+1) $
	ELSE $                                 ; mon in numeric form
		mon = FIX(smon)

	yr  = FIX(syr)
	day = FIX(sday)
	mon = mon(0)            ; convert month to scaler (just in case)

; if the delimiter is a '/' and the day is greater than 31 or delimt is a '-', we
; assume YYYY/MM/DD format, and we switch day and year positions.

        IF (delimit EQ '/' AND day GT 31) OR delimit EQ '-' THEN BEGIN 
           yrsave = yr
           yr = day
           day = yrsave
        ENDIF 

;     make year 4 digits, and if less than 70 assume 21st century 

	WHILE yr GT 100 DO  yr = yr - 100
	IF yr LT 70 THEN  yr = yr + 2000  ELSE yr = yr + 1900

;     now take care of carry problems

	WHILE mon GT 12 DO BEGIN             ; first months > 12
		mon = mon - 12
		yr = yr + 1
	ENDWHILE

	leap = ((yr MOD 4) EQ 0) AND ((yr MOD 100) NE 0) OR $
		((yr MOD 400) EQ 0)          ; leap will be true on a leap year

	WHILE day GT daytable(mon,leap) DO BEGIN
		day = day - daytable(mon,leap)
		mon = mon + 1
		IF mon GT 12  THEN BEGIN
			mon = mon - 12
			yr = yr + 1
		ENDIF
		leap = ((yr MOD 4) EQ 0) AND ((yr MOD 100) NE 0) OR $
			((yr MOD 400) EQ 0)  ; leap year?, year may have changed
	ENDWHILE

;     add up days of this year to current month

	totdays = day-1        ; start with days of this month

	FOR j=1,mon-1 DO     totdays = totdays + daytable(j,leap)

;     add to this all the days from years since 1970

	FOR j=1970,yr-1 DO BEGIN
		leap = ((j MOD 4) EQ 0) AND ((j MOD 100) NE 0) OR $
			((j MOD 400) EQ 0)   
		IF leap THEN $	
			totdays= totdays + daysinleap $
		ELSE $
			totdays= totdays + daysinnonleap
	ENDFOR

;     all done, output this date in seconds since 1/1/1970 00:00 UT

	output(i) = secinday*totdays

ENDFOR                           ; end of main loop

RETURN, output                   ; normal return

badconv:
RETURN, -1.D                     ; sorry pal's we hit an error

; all done

END                              ; DATESEC
