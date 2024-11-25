function str2time,s,informat=format,tformat=tformat
;+
;
; Warning: This routine is deprecated.  Use the TFORMAT keyword to time_double/time_struct instead
;
;FUNCTION str2time(string, informat=string)
; INPUT: scalar string.
; Returns seconds since 1970 given virtually any input string.
; (Assumes the string is GMT)
; The user should specify the input order of Year, Month, Date, hour, min, second is with INFORMAT keyword
; INFORMAT should be a 6 character string:  "YMDhms"  specifies Year/Mon/Date-hour:minute:second
; examples:      time = str2time(systime(),informat='MDhmsY')
;                time = str2time('tue, 04 jul 2006 19:00:04 gmt',informat='DMYhms')
; Written by Davin Larson - 2007
; 
; This routine is deprecated.  Use the TFORMAT keyword to time_double/time_struct instead
; 
;-

if keyword_set(tformat) then begin
  ns = n_elements(s)
  str = replicate(time_struct(0d),ns)

  year = 0
  p = strpos(tformat,'yy')
  if p ge 0 then begin
     year = fix(strmid(s,p,2))
     year +=  1900*(year ge 70) +2000 *(year lt 70)
  endif
  p = strpos(tformat,'YYYY')
  if p ge 0 then  year = fix(strmid(s,p,4))
  str.year = year

  p = strpos(tformat,'MM')
  if p ge 0 then str.month = fix(strmid(s,p,2))

  p = strpos(tformat,'DD')
  if p ge 0 then str.date = fix(strmid(s,p,2))

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

 ; printdat,str
  return,time_double(str)
endif


if not keyword_set(format) then format='YMDhms'

months= ['JAN','FEB','MAR','APR', 'MAY', 'JUN', 'JUL', 'AUG','SEP','OCT','NOV','DEC']

;printdat,s
ss = strsplit(strupcase(s),' _-:/',/extract,count=nss)   ; Remove all "white space" and separate into segments.

for i=0,nss-1 do begin
   w = where(ss[i] eq months,nw)
   if nw gt 0 then ss[i] = strtrim(w[0]+1,2)  ; replace months with a number.
endfor

w = where(ss eq strlowcase(ss),nw)           ; Find segments that only contains numbers. Ignore everything else
ss = ss[w]
;printdat,ss

srt = sort(byte(format))
order = [2,1,0,3,4,5]
srto = srt[order]
ss = ss[srto[0:nw-1]]     ; put tokens in the correct order

str = strjoin(ss,' ')
;printdat,str

return,time_double(str)

end

