;+
;NAME:
;  time_epoch
;PURPOSE:
;  Returns the EPOCH time required by CDF files.
;USAGE:
;  epoch = time_epoch(t)
; NOT TESTED!!!
;
;CREATED BY:	Davin Larson  Oct 1996
;FILE:  time_epoch.pro
;VERSION:  1.1
;LAST MODIFICATION:  96/10/16
;-
function time_epoch,time
   return, 1000.d * (time_double(time) + 719528.d * 24.d* 3600.d)
end


