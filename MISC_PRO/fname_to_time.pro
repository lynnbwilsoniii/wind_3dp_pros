;+
;PROCEDURE:	fname_to_time, fname, time
;PURPOSE:
;	To translate the name of a standard WIND data file into the starting
;	time of the data.
;INPUT:
;	fname: filename (string) to be translated
;	time: variable in which to return time (double)
;
;CREATED BY:	Peter Schroeder
;LAST MODIFICATION:	%W% %E%
;-
pro fname_to_time,fname,time

strippedname = strippath(fname)
date_pos = strlen(strippedname(0).file_name)-16
date = long(strmid(strippedname.file_name,date_pos,8))
year = date/10000
date = date - year*10000
month = date/100
date = date mod 100
time = time_double({year: year, date: date, month: month, hour: 0,$
	min: 0, sec: 0, fsec: 0})
return
end