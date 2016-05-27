;+
;FUNCTION: epoch2unix.pro
;
;PURPOSE: Convert CDF Epoch time to Unix time
;
;ARGUMENTS:
;       EPOCHTIME -> Epoch time (Milli-seconds since January 1, year 0)
;
;KEYWORDS: None
;
;RETURNS: Unix time (Seconds since January 1, 1970)
;
;CALLING SEQUENCE: utime=epoch2unix(etime)
;
;NOTES: None
;
;CREATED BY:  John Dombeck  1/11/01
;
;MODIFICATION HISTORY:
;       01/11/01-J. Dombeck     created
;-
;INCLUDED MODULES:
;   epoch2unix
;
;LIBRARIES USED:
;   None
;
;DEPENDANCIES
;   time_double
;
;-



;*** MAIN *** : * EPOCH2UNIX *

function epoch2unix, epochtime

  cdf_epoch,edate,2000,1,1,0,0,0,/compute_epoch
  tdate=time_double('2000-01-01/00:00:00')
  dif=edate-tdate*1000.

return,(epochtime-dif)/1000.
end       ;*** MAIN *** : * EPOCH2UNIX *

