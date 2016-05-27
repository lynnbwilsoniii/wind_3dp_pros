;+
;FUNCTION: unix2epoch.pro
;
;PURPOSE: Convert Unix time to CDF Epoch time
;
;ARGUMENTS:
;       UNIXTIME -> Unix time (Seconds since January 1, 1970)
;
;KEYWORDS: None
;
;RETURNS: Epoch time (Milli-seconds since January 1, year 0)
;
;CALLING SEQUENCE: etime=unix2epoch(utime)
;
;NOTES: None
;
;CREATED BY:  John Dombeck  1/11/01
;
;MODIFICATION HISTORY:
;       01/11/01-J. Dombeck     created
;-
;INCLUDED MODULES:
;   unix2epoch
;
;LIBRARIES USED:
;   None
;
;DEPENDANCIES
;   time_double
;
;-



;*** MAIN *** : * UNIX2EPOCH *

function unix2epoch, unixtime

  cdf_epoch,edate,2000,1,1,0,0,0,/compute_epoch
  tdate=time_double('2000-01-01/00:00:00')
  dif=edate-tdate*1000.

return,unixtime*1000.+dif
end         ;*** MAIN *** : * UNIX2EPOCH *

