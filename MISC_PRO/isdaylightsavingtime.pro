
function  isdaylightsavingtime,gmtime,timezone   ; this can give odd results during the 2 hour interval around the DST change.

dprint,dlevel=9,gmtime

  if n_elements(timezone) eq 0  then begin
     timezone = getenv('TIMEZONE')
     if not keyword_set(timezone) then begin  ;  This is a cluge... but the only way I know of to determine the timezone.
dprint,dlevel=9,"Determining timezone..."
        timezone = fix(round((time_double(strjoin(bin_date(systime(0)))) -systime(1)) / 3600))
        timezone -= isdaylightsavingtime(systime(1),timezone)
        setenv,'TIMEZONE='+strtrim(timezone,2)
dprint,dlevel=9,'timezone is:',timezone
     endif else timezone = fix(timezone)
  endif
  if timezone eq 0 then return,fix(gmtime * 0)
  if timezone lt -11 or timezone gt -5 then return,fix(gmtime *0)  ; Only the U.S. is handled

; The following dates are only valid for the U.S. (except arizona and hawaii)
;  time_changes = time_double([ ['2001-4-1/2' ,'2001-10-28/2'], $
;                 ['2002-4-7/2' ,'2002-10-27/2'], $
;                 ['2003-4-6/2' ,'2003-10-26/2'], $
;                 ['2004-4-4/2' ,'2004-10-31/2'], $
;                 ['2005-4-3/2' ,'2005-10-30/2'], $
;                 ['2006-4-2/2' ,'2006-10-29/2'], $
;                 ['2007-3-11/2','2007-11-04/2'], $
;                 ['2008-3-09/2','2008-11-02/2']])

  time_changes=[ $
  [ 986090400 , 1004234400],$
  [1018144800 , 1035684000],$
  [1049594400 , 1067133600],$
  [1081044000 , 1099188000],$
  [1112493600 , 1130637600],$
  [1143943200 , 1162087200],$
  [1173578400 , 1194141600],$
  [1205028000 , 1225591200]]


  ltime = timezone*3600d + gmtime
  dst = 0
  for i = 0,7 do dst = dst +(ltime gt time_changes[0,i])  and (ltime lt time_changes[1,i])

 return,dst

end

