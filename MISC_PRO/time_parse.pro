;+
;FUNCTION: time_parse
;PURPOSE:
;  Parse a string or array of strings into double precision seconds since 1970
;    (a)using user provided format code
; or (b)using flexible formatting and no code 
;
;INPUTS:
;  s : the input string or array of strings
;
;KEYWORDS:
;  tformat=tformat:  Format string such as "YYYY-MM-DD/hh:mm:ss" (Default)
;               the following tokens are recognized:
;                    YYYY  - 4 digit year
;                    yy    - 2 digit year (00-69 assumed to be 2000-2069, 70-99 assumed to be 1970-1999)
;                    MM    - 2 digit month
;                    DD    - 2 digit date
;                    hh    - 2 digit hour
;                    mm    - 2 digit minute
;                    ss    - 2 digit seconds
;                    .fff   - fractional seconds (can be repeated, e.g. .f,.ff,.fff,.ffff, etc... are all acceptable codes)
;                    MTH   - 3 character month
;                    DOY   - 3 character Day of Year
;                    TDIFF - 5 character, +hhmm or -hhmm different from UTC (sign required)
;               tformat is case sensitive!
;
; tdiff=tdiff: Offset in hours.  Array or scalar acceptable.
;              If your input times are not UTC and offset 
;              is not specified in the time string itself,
;              use this keyword.
;
; MMDDYYYY=MMDDYYYY: handle dates in month/day/year format flexibly if tformat not specified
;
;
;Examples:
;
;NOTES:
;  #1 Some format combinations can conflict and may lead to unpredictable behavior. (e.g. "YYYY-MM-MTH") 
;  #2 Primarily intended as a helper routine for time_double and time_struct
;  #3 letter codes are case insensitive.
;  #4 Based heavily on str2time by Davin Larson.
; 
;$LastChangedBy: davin-mac $
;$LastChangedDate: 2014-04-29 23:06:36 -0400 (Tue, 29 Apr 2014) $
;$LastChangedRevision: 14975 $
;$URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/misc/time/time_parse.pro $
;-

function time_parse,s, tformat=tformat,tdiff=tdiff,MMDDYYYY=MMDDYYYY

  compile_opt idl2
  
  months= ['JAN','FEB','MAR','APR', 'MAY', 'JUN', 'JUL', 'AUG','SEP','OCT','NOV','DEC']
  
  ndim = size(s,/n_dimen)
  dim = size(s,/dim)
  if ndim gt 0 then begin
    str = replicate(time_struct(0d),dim)
  endif else begin
    str = time_struct(0d)
  endelse
  
  if undefined(tdiff) then begin
    tdiff = 0
  endif
  
  tdiff_sec = tdiff * 60. * 60.
  
  ;flexible formatting, allows arbitary punctuation, variable length fields, etc...
  ;primarily used for human entry and legacy support
  if undefined(tformat) then begin
    
    ;Davin's version.  Even though it loops and is a little opaque,
      ;this is faster than the vectorized versions using stregex
    bt = bindgen(256)
    bt[byte(':_-/,T')]= 32 ;create new ascii set where common separators are replaced with space
    
    year=0l & month=0l & date=0 & hour=0 & min=0 & fsec=0.d ;select output types for parse
    for i=0l,n_elements(s)-1l do begin
      st = string(bt[byte(s[i])])+' 0 0 0 0 0 0'    ; remove separators and pad fields
      if keyword_set(MMDDYYYY) then reads,st,month,date,year,hour,min,fsec  $
      else  reads,st,year,month,date,hour,min,fsec
  
      ;handle inputs of the form yyyymmdd hhmmss (only separator is space between date and time)
      if year gt 10000000l then begin
        hour = month
        date = year mod 100
        year = year/100
        month = year mod 100
        year = year/100
        min = hour mod 100
        hour = hour / 100
      endif
      
      ;handle two digit years
      if year lt 70  then year = year+2000
      if year lt 200 then year = year+1900

      ; month=0 or date=0 are invalid entries, replace with 1 
      month = month > 1
      date = date > 1
      
      str[i].year=year
      str[i].month=month
      str[i].date=date
      str[i].hour=hour
      str[i].min=min
      
      ;separate seconds and fractional seconds
      str[i].sec=fix(fsec)
      str[i].fsec=double(fsec) mod 1.0
      
    endfor
     
  endif else begin ;fixed formatting

    year = 0
    p = strpos(tformat,'yy')
    
    if p ge 0 then begin
      year = fix(strmid(s,p,2))
      year +=  1900*(year ge 70) +2000 *(year lt 70)
    endif
    
    p = strpos(tformat,'YYYY')
    if p ge 0 then begin
       year = fix(strmid(s,p,4))
    endif
    
    str.year = year
    
    p = strpos(tformat,'MM')
    if p ge 0 then begin
      str.month = fix(strmid(s,p,2))
    endif
    
    p = strpos(tformat,'MTH')
    
    for i = 0,11 do begin
      idx = where(months[i] eq strupcase(strmid(s,p,3)),c)
      if c gt 0 then begin
        str[idx].month = i+1
      endif
    endfor
    
    p = strpos(tformat,'DD')
    if p ge 0 then str.date = fix(strmid(s,p,2))
    
    p = strpos(tformat,'DOY')
    if p ge 0 then begin
      doy_to_month_date,str.year,fix(strmid(s,p,3)),month,date
      str.month = month
      str.date = date
    endif
    
    p = strpos(tformat,'hh')
    if p ge 0 then str.hour = fix(strmid(s,p,2))
    
    p = strpos(tformat,'mm')
    if p ge 0 then str.min = fix(strmid(s,p,2))
    
    p = strpos(tformat,'ss')
    if p ge 0 then str.sec = fix(strmid(s,p,2))
    
    token='.'
    repeat begin
      token = token +'f'
      p = strpos(tformat, token )
    endrep until strpos(tformat,token+'f') lt 0
    if p ge 0 then str.fsec = double(strmid(s,p,strlen(token)))
      
    p = strpos(tformat,'TDIFF')
    if p gt 0 then begin
      tdiff_hr = fix(strmid(s,p,3))
      tdiff_min = fix(strmid(s,p+3,2))
      tdiff_sec = tdiff_hr * 60. * 60. + tdiff_min * 60. 
    endif
    
  endelse
 
  if n_elements(tdiff_sec) gt 1 || tdiff_sec ne 0 then begin   
    return,time_struct(time_double(str) - tdiff_sec)
  endif else begin
    return,str
  endelse
    
end
