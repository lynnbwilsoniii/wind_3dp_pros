;+
;FUNCTION: fix_sdt_time,ptr_array,month,day,year
;
;PURPOSE: To convert times of sdt data into standard Unix times
;
;ARGUMENTS:
;	PTR_ARRAY  <> pointer array returned from MREAD_SDT or
;                          array of doubles with zeroth column sdt times
;	MONTH      -> month data was taken
;	DAY        -> day data was taken
;	YEAR       -> year data was taken
;
;RETURNS: status
;           0 - Failure
;           1 - Success
;
;KEYWORDS: N/A
;
;CALLING SEQUENCE: status=fix_sdt_time(ptr_array,mon,day,yr)
;
;NOTES: Original month day and year that data was taken must be known to 
;	use this function.
;
;CREATED BY: Lisa Rassel June 2001
;
;MODIFICATION HISTORY: 
;      06/11/2001-L. Rassel	created
;-
;INCLUDED MODULES:
;   fix_sdt_time
;
;LIBRARIES USED:
;   None
;
;DEPENDANCIES
;   data_type
;   date_time_0
;
;-



;*** MAIN *** : * FIX_SDT_TIME *

function fix_sdt_time,ptr_array,month,day,year


; Check input

  dtype=data_type(ptr_array)
  if dtype ne 5 and dtype ne 10 then begin
    message,'PTR_ARRAY required sdt pointer data or array of doubles',/cont
    return,0
  endif

  if n_elements(month) eq 0 or n_elements(day) eq 0 $
     or n_elements(year) eq 0 then begin
    message,'MONTH, DAY and YEAR required',/cont
    return,0
  endif

  if month ne fix(month) or month lt 1 or month gt 12 then begin
    message,'MONTH requires integer [1,12]',/cont
    return,0
  endif

  if day ne fix(day) or day lt 1 or day gt 31 then begin
    message,'DAY requires integer [1,31]',/cont
    return,0
  endif

  if year ne fix(year) or year lt 1 then begin
    message,'YEAR requires integer [>0]',/cont
    return,0
  endif


; Find UNIX time of 12:00 AM

  time_zero=date_time_0(month,day,year)


; Correct times


; SDT pointer data type

  if dtype eq 10 then begin
    sz1=size(ptr_array,/dimensions)
    for i=0l,(sz1[0]-1) do begin
      (*ptr_array(i))(*,0)=(*ptr_array(i))(*,0)+time_zero
    endfor


; Array of doubles

  endif else begin
    ptr_array(*,0)=ptr_array(*,0)+time_zero
  endelse
  
return,1
end        ;*** MAIN *** : * FIX_SDT_TIME *

