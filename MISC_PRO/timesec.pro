;+
; FUNCTION:
; 	 TIMESEC
;
; DESCRIPTION:
;
;	function to parse out a time string of the form hh:mm:sec.msc.
;	The return value is in seconds of the day.
;	
; USAGE (SAMPLE CODE FRAGMENT):
; 
;    
;    ; set up a time string
;
;	time_string = '25:01:01.001'
;    
;    ; convert to seconds
;    
;	time_seconds = timesec(time_string, carries=nc)
;    
;    ; print it out
;    
;	PRINT, time_seconds, nc
;
; --- Sample output would be 
;    
;	3661.0010, 1
;    
;
; NOTES:
;
;	if the input time is greater than 24 hours, then 24 hours will
;	subtracted until time is less than 24 hours.  The CARRIES keyword
;	if set, will contain the number of rollovers.
;
;	The return value is a double float.  
;
;	if conversion fails, this functin returns -1.
;
;	The input is interpreted in the following way:
;
;	 1) only the last 2 digits of any field is significant, except 
;	    for the case of miliseconds, where only the first 3 digits are 
;	    significant.  e.g. if the second field is 1160, it will be taken 
;	    as 60 for fields other than msc, and taken as 116 for millisecond.
;
;	 2) if the hour is greater than 23, then 24 is subtracted from it
;	    successivly till it is less than 24.  e.g. if the hour field is
;	    73, then it will be set to 1
;
;	 3) if the min or sec is greater than 60, 60 is subtracted and 
;	    the remander is caried over to the hour and min, respectively
;
;	 4) anything after the msc field will be ignored.
;
;	 5) input is interpreted from left to right for the hour:min:sec parts
;	    e.g. '03:12' is inturpeted as hour=3,  min=12, sec=0 and msc=0.  
;	    '03' is taken to mean hour=3 and min = sec = msc = 0, however 1.1 
;	    is taken to mean hour=1, msc=100, min=sec=0.
;
;	 6) everything up to the last two digits before the first colon will
;	    be ignored, if the colon is presant.  So a string formed thusly:
;	    '1995/1/31 03:00:00.0' will give the hour=3 and min = sec = msc=0.
;
;	 7) if there is trailing information in the input string, the
;	    time must contain all fields, and the string must not have
;	    other ':' or '.'  characters.  This allows times to be pulled
;	    off of strings containing other information.
;
;	If input sting is an array, then an array of N_ELEMENTS(inputs val) 
;	of date strings and remainders will be returned. 
;
;
; REVISION HISTORY:
;
;	@(#)timesec.pro	1.3 10/06/95 	
; 	Originally written by Jonathan M. Loran,  University of 
; 	California at Berkeley, Space Sciences Lab.   Nov. '91
;
;	Revised to handle arrays of input values, JML, Mar. '92
; 	Revised to implement carry keyword, JML Oct. '95
;-


FUNCTION timesec,stringin, carries=carries

; make sure input is defined

IF( N_ELEMENTS(stringin)   LE 0 )   THEN RETURN, -1

; null string error

IF (WHERE(STRLEN(stringin) LE 0))(0) NE -1 THEN RETURN, -1.D 

; exception handling

ON_IOERROR, badconv

; loop through all values

FOR i=0,N_ELEMENTS(stringin)-1  DO BEGIN

  shour = '0'
  smin ='0'
  ssec ='0'
  smsc = '0'

;   The following block is messy, but hey, it works

  trimstring=STRTRIM(stringin(i),2)     ; trim off leading and trailing blanks
  IF STRPOS(trimstring,'.') NE -1 THEN BEGIN             ; we have msc 
    smsc=STRTRIM($                                       ; set msc part first
	STRMID(trimstring,STRPOS(trimstring,'.'), $      ;  to be from the .
	STRLEN(trimstring)-STRPOS(trimstring,'.')))      ;  to the end of strng
    smsc=smsc+'    '                                     ; pad out w/ blanks &
    smsc=STRMID(smsc,0,4)                                ; take first 4 chars 
    IF(STRPOS(smsc,' ') NE -1) THEN $
       smsc=STRTRIM(STRMID(smsc,0,STRPOS(smsc,' ')))+'0' ; ignore end stuff
    trimstring=STRTRIM(STRMID(trimstring,0, $            ; remove msc for
	STRPOS(trimstring,'.')))                         ;  rest of calulation
  ENDIF                                                  ; end if msc part
  IF STRPOS(trimstring,':') GT 0 THEN $                  ; check for : 
     shour = STRTRIM( $
	STRMID(trimstring,0,STRPOS(trimstring,':'))) $   ; hour is first field
   ELSE shour = trimstring                               ; no :, only hour
  IF STRPOS(trimstring,':') GT 0 THEN BEGIN              ; look for more :'s
    trimstring=STRMID(trimstring,STRPOS(trimstring,':')+1, $
	STRLEN(trimstring)-(STRPOS(trimstring,':')+1))   ; trim off hour part
    IF STRPOS(trimstring,':') GT 0 THEN $                ; still more :'s ?
       smin=STRTRIM(STRMID(trimstring,0,STRPOS(trimstring,':'))) $; yes,get min
     ELSE  smin=trimstring                               ; no :, only min left
     IF STRPOS(trimstring,':') GT 0 THEN BEGIN           ; yet another : ?
       trimstring=STRMID(trimstring,STRPOS(trimstring,':')+1, $ 
         STRLEN(trimstring)-(STRPOS(trimstring,':')+1))  ; remove the :
        ssec=STRTRIM(trimstring)                         ; grab seconds
     ENDIF
  ENDIF                                      ; done parsing

  IF STRLEN(shour) GT 2 THEN $
	shour=STRMID(shour,STRLEN(shour)-2,2) ;only interested in last 2 digits
  IF STRLEN(smin) GT 2 THEN $
	smin=STRMID(smin,STRLEN(smin)-2,2)    ; and for min
  IF STRLEN(ssec) GT 2 THEN $
	ssec=STRMID(ssec,STRLEN(ssec)-2,2)    ; and for sec
  IF STRLEN(smsc) GT 2 THEN $
	smsc=STRMID(smsc,STRLEN(smsc)-4,4) ;and last 4 for msc(4 including '.')

  hour = FIX(shour)                      ; convert to numbers
  min = FIX(smin)
  sec = FIX(ssec)
  msc = DOUBLE(smsc)

  IF sec GT 60 THEN BEGIN                ; carry values
	sec = sec - 60
	min = min+1
  ENDIF
  IF min GT 60 THEN BEGIN 
	min = min - 60
	hour = hour +1
  ENDIF
  
  rolls = 0 
  WHILE hour GT 23  DO BEGIN
     hour = hour - 24
     rolls = rolls + 1
  ENDWHILE
     
  IF N_ELEMENTS(output) EQ 0 THEN BEGIN
     output = DOUBLE(hour)*3600+DOUBLE(min)*60+sec+msc
     carries = rolls
  ENDIF ELSE BEGIN 
     output = [output, DOUBLE(hour)*3600+DOUBLE(min)*60+sec+msc]
     carries = [carries, rolls]
  ENDELSE 

ENDFOR                                   ; end of parameter loop
RETURN,output                            ; success

badconv:
RETURN, -1.D                             ; no success

END

