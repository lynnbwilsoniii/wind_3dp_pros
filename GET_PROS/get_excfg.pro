;+
;FUNCTION:   get_excfg(t)
;INPUT:
;    t: double,  seconds since 1970.
;KEYWORDS:
;	advance:	advance to the next data point
;	index:		select data by sample index instead of by time.
;	times:		if non-zero, return an array of data times 
;			corresponding to data samples.
;PURPOSE:   returns an Eesa Extended Instrument Configuration data record.
;
;CREATED BY:	Peter Schroeder
;LAST MODIFIED: @(#)get_excfg.pro	1.1 99/04/19
;
;NOTES: The procedure "load_3dp_data" must be 
;	called first.
;-

function get_excfg,t,times=tms, index=idx, advance = adv
@wind_com.pro

dat = { excfg_struct, $
   PROJECT_NAME:   'Wind 3D Plasma', $
   DATA_NAME:      'Eesa Extended Instrument Configuration', $
   TIME      :     0.d, $
   INDEX     :	   0l, $
   VALID     :	   0, $
   DATA	     :     bytarr(264) }

size = n_tags(dat,/length)
if (n_elements(idx) eq 0) and (n_elements(t) eq 0) and (not keyword_set(adv)) $
	and (not keyword_set(tms)) then ctime,t
if keyword_set(adv) then a=adv else a=0
if n_elements(idx) eq 0 then i=-1 else i=idx
if n_elements(t)   eq 0 then t=0.d

options = long([size,a,i])

if n_elements(wind_lib) eq 0 then begin
  print, 'You must first load the data'
  return,0
endif

; get times if requested
if keyword_set(tms) then begin
;   num = call_external(wind_lib,'excfg_to_idl')
   num = 10000
   options(0) = num
   times = dblarr(num)
   ok = call_external(wind_lib,'excfg_to_idl',options,times)
   print,ok+1,'  EXCFG time samples'
   if ok lt 0 then return,0d else return,times(0:ok)
endif

time = gettime(t)
ok = call_external(wind_lib,'excfg_to_idl',options,time,dat)

return,dat
end

