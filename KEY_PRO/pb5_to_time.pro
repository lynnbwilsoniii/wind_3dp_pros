;+
;WARNING!!! This Function is OBSOLETE try not to use it...
;FUNCTION: pb5_to_time
;INPUT: pb5 array from cdf files (especially kpd files)
;OUTPUT:  double array,  seconds since 1970
;
;SEE ALSO: 	"print_cdf_info",
;		"loadcdf"
;
;CREATED BY: 	Davin Larson
;LAST MODIFICATION:	@(#)pb5_to_time.pro	1.5 95/10/18
;-

function  pb5_to_time,pb5
if dimen2(pb5) lt 2 then begin 
  print,'Invalid time input to pb5_to_time: ',gethelp('pb5')
  return,-1d
endif 
year = pb5(*,0)
yearm1 = year-1
nleap1970  = 477
nm1leap = yearm1/4 - yearm1/100 + yearm1/400 - yearm1/4000  - nleap1970
days = (year-1970)*365+nm1leap
days = days + pb5(*,1) - 1
time = double(days) * 24.d * 3600.d + pb5(*,2)/1000.d
return, time
end




;JUNK:

;function ndays_since_1970,year
;year = long(year) 
;century = (year lt 200) * 1900
;year = year+century
;nleap1970  = 477
;nleap = year/4 - year/100 + year/400 - year/4000  - nleap1970
;return,(year-1970)*365+nleap
;end




