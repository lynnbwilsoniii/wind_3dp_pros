
pro doy_to_month_date, year,doy,month,date
;+
;PROCEDURE:
;  doy_to_month_date, year, doy, month, date
;NAME:
;  doy_to_month_date
;PURPOSE:
; Determines month and date given the year and day of year.
; fast, vector oriented routine that returns the month and date given year and 
; day of year (1<=doy<=366)
;
;CREATED BY:	Davin Larson  Oct 1996
;FILE:  doy_to_month_date.pro
;VERSION:  1.2
;LAST MODIFICATION:  97/01/27
;-
common doy_mon_date_com1,months,dates
if not keyword_set(months) then begin    ; only needs to be computed once!
   mdt = [[0, 31,  59,  90, 120, 151, 181, 212, 243, 273, 304, 334, 365], $
          [0, 31,  60,  91, 121, 152, 182, 213, 244, 274, 305, 335, 366]]
   doys = [[indgen(366)],[indgen(366)]]
   isleap = [[replicate(0,366)],[replicate(1,366)]]
   months = doys/29
   dates = doys - mdt(months,isleap)
   w = where(dates lt 0,c)
   if c ne 0 then begin
      months(w) = months(w) -1
      dates(w) = doys(w) - mdt(months(w),isleap(w))
   endif
   months = months+1
   dates  = dates +1
endif

isleap = ((year mod 4) eq 0) - ((year mod 100) eq 0) + ((year mod 400) eq 0) - ((year mod 4000) eq 0)
month=months(doy-1,isleap)
date =dates(doy-1,isleap)

end


