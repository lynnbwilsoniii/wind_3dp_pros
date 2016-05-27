;+
;FUNCTION: ymd2unix.pro
;
;PURPOSE: Convert yyyy,mon,day,hh,mm,ss,msec time to Unix time
;
;ARGUMENTS:
;       YEAR -> integer year
;       MON  -> integer month
;       DAY  -> integer day
;       HH   -> integer hour
;       MM   -> integer minute
;       SS   -> integer second
;       MSEC -> integer millisecond (0-999)
;
;KEYWORDS:
;       (none)
;
;RETURNS: Unix time (Seconds since January 1, 1970)
;
;CALLING SEQUENCE: utime=ymd2unix(year,month,day,hout,minute,second,msecond)
;
;NOTES:
;       Vectorized, all arguments can be either single integer values
;       or arrays of integers.
;-
;CREATED BY:  Kris Kersten  04Jun2007
;
;MODIFICATION HISTORY:
;       04Jun2007 - KK - created, vectorized
;
;INCLUDED MODULES:
;       ymd2unix
;
;LIBRARIES USED:
;       epoch2unix.pro
;
;DEPENDENCIES:
;       (none)
;-

function ymd2unix,year,mon,day,hh,mm,ss,msec
  dsize=size(year,/n_elements)
  etime=0D
  utime=dblarr(dsize)
  for dcount=0L,dsize-1 do begin
    cdf_epoch,etime,year[dcount],mon[dcount],day[dcount],$
              hh[dcount],mm[dcount],ss[dcount],msec[dcount],/compute_epoch
    utime[dcount]=epoch2unix(etime)
  endfor
  if dsize eq 1 then return,utime[0] else return,utime
end