;+
; FUNCTION: TIME_INTERVALS
; Purpose:
;  TIME_INTERVALS will generate regular time intervals given a time range
;     This routine was specifically designed to aid in producing file names based on time ranges
;  KEYWORDS:
;    TRANGE:  Time range - scaler or two element array. double, string or structure  (see time_double(), time_string, time_struct)
;    
;     Generated times will be LESS than or equal to TRANGE[0]  and less than TRANGE[1]   (may be scaler)
;  
;    RESOLUTION:    resolution in seconds
;    MINUTE_RES:    Forces RESOLUTION to 60
;    HOURLY_RES:    Forces RESOLUTION to 3600
;    DAILY_RES:     Forces RESOLUTION to 3600*24L
;    MONTHLY_RES:   resolution in months.
;    YEARLY_RES:    resolution in years
;    
;    PHASE_SHIFT:   scaler between 0. and 1. - shifts the starting phase.
;    
;    TIMES:  named variable that will return the double precision array of values (same as output if tformat is not specified))
;    
;     array of times used to generate the output strings. (output if any of above resolutions and TRANGE is set)
;       TIMES is an output if TRANGE is set and any of the resolutions are set.
;       Otherwise is can be used as an input.
;       
;    TFORMAT:  (string) format the output and return as a string  (See TIME_STRING(t,TFORMAT=tformat))
;    
;  Examples:
;  
;  times = time_intervals(trange=['2014-12-28','2015-1-3'],/daily_res)
;  
;  filenames = time_intervals(tformat='data/YYYY/MM/example_yyMMDD_v??.dat',trange=['2015','2016'] ,daily_res=7,phase_shift=4/7.,times=t)  
;
;  Generate weekly filenames that start on Mondays:
;  tr =['2014-12-1','2015-1-31']
;  filenames = time_intervals(trange=tr,daily=7,phase_shift=4/7.,times=t,tformat='file_yyMMDD')+time_intervals(tformat='_yyMMDD_v??.dat',times=t+3600d*24*7)
;
;$LastChangedBy: adrozdov $
;$LastChangedDate: 2018-01-10 17:03:26 -0800 (Wed, 10 Jan 2018) $
;$LastChangedRevision: 24506 $
;$URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/misc/time_intervals.pro $
;-

function time_intervals,trange=trange,tformat=tformat, $
    MINUTE_RES=MINUTE_RES,DAILY_RES=DAILY_RES,HOURLY_RES=HOURLY_RES,MONTHLY_RES=MONTHLY_RES,YEARLY_RES=YEARLY_RES, $
    resolution=resolution,phase_shift=phase_shift, times=times


times = 0
if keyword_set(trange) then begin
  tr = time_double(trange)
  if n_elements(tr) eq 1 then tr= [tr[0],tr[0]]

  if keyword_set(MINUTE_RES) then resolution = round(60.d * MINUTE_RES)
  if keyword_set(HOURLY_RES) then resolution = round(3600.d * HOURLY_RES)
  if keyword_set(DAILY_RES) then resolution = round(24*3600.d * DAILY_RES)
  if n_elements(phase_shift) eq 0 then phase_shift=0d

  if keyword_set(MONTHLY_RES)  then begin
    trs = time_struct(tr+ [0.,-1.])
    months = trs.month + 12 * (trs.year - 1970)  + [0,1]
    str = double(months-1)/ MONTHLY_RES - double(phase_shift)
    dtr = ( ceil(str[1]) - floor(str[0]  ) ) > 1
    times = replicate(time_struct(0d),dtr)
    times.month = 1+ round(MONTHLY_RES * (floor( str[0]) + lindgen(dtr) + double(phase_shift) ) )
    times = time_double(times)
  endif else   if keyword_set(YEARLY_RES)  then begin
    trs = time_struct(tr+ [0.,-1.])
    years =  (trs.year)  + [0,1]
    str = double(years)/ YEARLY_RES - double(phase_shift)
    dtr = ( ceil(str[1]) - floor(str[0]  ) ) > 1
    times = replicate(time_struct(0d),dtr)
    times.year =  round(YEARLY_RES * (floor( str[0]) + lindgen(dtr) + double(phase_shift) ) )
    times = time_double(times)
  endif else begin
    if ~keyword_set(resolution)  then resolution = 24L*3600    ;Default to 1 day resolution
    str = tr/resolution - double(phase_shift)
    dtr = ( ceil(str[1]) - floor(str[0]) )  > 1           ; must have at least one value
    times = long( resolution * (floor(str[0]) + lindgen(dtr) + double(phase_shift) ))   ; to nearest second
  endelse

endif

if keyword_set(tformat)  then begin
  if n_elements(times) ne 0  then return,  time_string(times,tformat=tformat,escape_seq='\') $
  else return,''  
endif

return,times

end

