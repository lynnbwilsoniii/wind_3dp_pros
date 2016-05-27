;+
;FUNCTION: date_time_0.pro
;
;PURPOSE: Find Unix time of 12:00 AM for a given date
;
;ARGUMENTS:
;         MTH   -> Month (1-12)
;         DAY   -> Day (1-31)
;         YR    -> Year, full 4-digit year
;
;KEYWORDS: None
;
;RETURNS: Unix time, in seconds
;         0 on error
;
;CALLING SEQUENCE: value=date_time_0(4,24,1997)
;
;NOTES: None
;
;CREATED BY:  John Dombeck  1/11/01
;
;MODIFICATION HISTORY:
;       01/11/01-J. Dombeck     created
;       07/24/01-J. Dombeck     Added input checking
;-
;INCLUDED MODULES:
;   time_date_0
;
;LIBRARIES USED:
;   None
;
;DEPENDANCIES
;   time_double
;
;-



;*** MAIN *** : * DATE_TIME_0 *

function date_time_0,mth,day,yr


; Check input

  if n_elements(mth) eq 0 or n_elements(day) eq 0 or n_elements(yr) eq 0 then $
     begin
    message,"Month, Day, and Year required",/cont
    return,0
  endif

  if mth ne floor(mth) or day ne floor(day) or yr ne floor(yr) then begin
    message,"Month, Day, and Year require integers",/cont
    return,0
  endif

  if mth lt 1 or mth gt 12 then begin
    message,"Month must be 1-12",/cont
    return,0
  endif

  if day lt 1 or day gt 31 then begin
    message,"Day must be 1-31",/cont
    return,0
  endif

  if yr lt 1 then begin
    message,"Month must be >0",/cont
    return,0
  endif


; Compute time for 12:00 AM of date

  datestr=string(format='(I4.4,"-",I2.2,"-",I2.2,"/00:00:00")',yr,mth,day)

return,time_double(datestr)
end         ;*** MAIN *** : * DATE_TIME_0 *

