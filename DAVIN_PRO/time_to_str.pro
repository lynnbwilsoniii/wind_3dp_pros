;+
;NAME:
;   time_to_str
;PURPOSE:
;   Obsolete. Use "time_string" instead.
;-
function time_to_str, time,msec=msec,dateonly=dat,fmt=fmt
;help,calls=calls
;message,/info,calls(1)
return,time_string(time,date_only =dat,msec=msec,format=fmt)
end

