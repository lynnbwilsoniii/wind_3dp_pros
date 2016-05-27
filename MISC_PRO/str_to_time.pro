;+
; FUNCTION:
; 	 STR_TO_TIME
;
; DESCRIPTION:
;
;	function to parse out a date/time string with format of
;	YY-MM-DD/HH:MM:SS.MSC.  Any trailing component of the date
;	or time may be left off	(e.g. '95-8/1 is legal).  The year
;	may be either 2 or 4 digits, where 1970 is assumed to be
;	the epoch.  The RETURN value is double float in seconds
;	since 1 Jan 1970, 00:00 UT.
;
; USAGE (SAMPLE CODE FRAGMENT):
; 
;    
;    ; seconds since 1970 
;
;	string_date_time = '1991-03-21/04:04:04'
;    
;    ; convert to string    
;    
;	seconds_date = str_to_time(string_date_time)
;    
;    ; print it out
;    
;	PRINT, seconds_date
;
; --- Sample output would be
;    
;	6.6952824e+08
;    
;
; NOTES:
;
;	If conversion fails, this function returns -1.
; 
;	If any of the fields is to large then a carry operation will
;	occur.  i.e. 34/13/89 would come out to year 90, month 2, day 3.
;	The same is true of the time portion.
;
;	If input seconds is an array, then an array of 
;	N_ELEMENTS(inputs vals) of date strings and remainders will be
;	returned.
;
;
; REVISION HISTORY:
;
;	@(#)str_to_time.pro	1.7 10/06/95
; 	Originally written by Jonathan M. Loran,  University of 
; 	California at Berkeley, Space Sciences Lab.   Sep. '91
;
;	Revised to handle arrays of input values, JML, Jan. '92
;-

FUNCTION str_to_time, stringin

   IF N_ELEMENTS (stringin) EQ 0 THEN  RETURN, -1D
   
   ; just use datesec and timesec to parse string

   outproto = 1.D

   FOR i=0, N_ELEMENTS (stringin) -1 DO BEGIN 
      IF i EQ 0 THEN      $
        out = outproto    $
      ELSE                $
        out = [out, outproto]
      
      locstring = stringin(i)      ; local copy of input string to edit
      datestring = locstring
   
      secsOut = 0.D
      secsTime = 0.D

      IF STRPOS (datestring, '/') GT 0 THEN                              $
        strput, datestring, '                    ', strpos (locstring, '/')

      secsDate = datesec(datestring) ; get seconds in date part
                                     ; if we have date part, remove it
      IF STRPOS (locstring, '/') GE 0 THEN                               $
        locstring = STRMID (locstring, STRPOS(locstring, '/')+1, 13)     $
      ELSE                                                               $
        locstring = ''
                                    ; get seconds of time part
      IF strlen (locstring) GT 0 THEN  secsTime = timesec(locstring, car=car) + car * 86400.D

      IF (secsDate EQ -1D) OR (secsTime EQ -1D) THEN secsOut = -1D
      IF secsDate GT 0.D THEN secsOut = secsOut + secsDate
      IF secsTime GT 0.D THEN secsOut = secsOut + secsTime

      out(i) = secsOut

   ENDFOR 

   RETURN, out

END
