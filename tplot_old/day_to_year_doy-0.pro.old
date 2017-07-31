
pro day_to_year_doy,day,y,d
;+
;NAME:
;   day_to_year_doy
;PURPOSE:
;   determines year and day of year given day since 0000 AD
;USAGE:
;   day_to_year_doy,daynum,year,doy
;INPUT:
;   daynum:   (long int)  day since 0 AD
;OUTPUT:
;   year:     year         (0 <= year <= 14699 AD)
;   doy:      day of year  (1 <= doy  <=  366) 
;NOTES:
;  This procedure is reasonably fast, it works on arrays and works from
;  0 AD to 14699 AD
;
;CREATED BY:	Davin Larson  Oct 1996
;FILE:  day_to_year_doy.pro
;VERSION:  1.2
;LAST MODIFICATION:  97/01/27
;-
day = floor(day)

;get year correctly to within one year  
y = (day*400)/(365l*400 +100 -4 + 1)
;get doy based on the year
d = day - (y*365 + y/4 - y/100 + y/400 - y/4000)

w = where(d ge 365,c)                    ;make corrections
if(c ne 0) then begin 
   y(w) = y(w) +1
   d(w) = day(w) - (y(w)*365 + y(w)/4 - y(w)/100 + y(w)/400 - y(w)/4000)
endif

w = where(d lt 0,c)                     ;more corrections
if(c ne 0) then begin 
   y(w) = y(w) -1 
   d(w) = day(w) - (y(w)*365 + y(w)/4 - y(w)/100 + y(w)/400 - y(w)/4000)
endif

y = y+1
d = d+1

return
end


