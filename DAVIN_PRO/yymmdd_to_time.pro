;+
;FUNCTION:  yymmdd_to_time
;PURPOSE:
;    Returns time (seconds since 1970) given date in format:  YYMMDD  HHMM
;USAGE:
;  t = yymmdd_to_time(yymmdd [,hhmm])
;  (yymmdd can be either a long or a string)
;Examples:
;  t = yymmdd_to_time(990421,1422)
;  print,t,' ',time_string(t)
;Created by: Davin Larson, April 1999
;-
function yymmdd_to_time,yymmdd_,hhmm_

yymmdd = long(yymmdd_)
n=n_elements(yymmdd)

yy = floor(yymmdd/10000)
mmdd = yymmdd - yy *10000
mm = floor(mmdd/100)
dd = mmdd - mm*100

yy =  yy + 1900*(yy lt 200) + 100*(yy lt 50)   ; Do the most logical year

t=replicate(time_struct(0.d),n)

t.year = yy
t.month = mm
t.date = dd

if n_elements(hhmm_) eq n then begin
 hhmm = long(hhmm_)
 hh = hhmm/100
 mm = hhmm - hh*100
 t.hour = hh
 t.min = mm
endif

return,time_double(t)
end
