;+
;FUNCTION:   get_fpc(t)
;INPUT:
;    t: double,  seconds since 1970. If this time is a vector than the
;	routine will get all samples in between the two times in the 
;	vector
;KEYWORDS:
;	advance:	advance to the next data point
;	index:		select data by sample index instead of by time.
;	times:		if non-zero, return and array of data times 
;			corresponding to data samples.
;PURPOSE:   returns a structure containing all data pertinent to a single
;  correlator sample.  See the file 3dp_help.doc for a more complete 
;  description of the structure.
;
;CREATED BY:	Jonathan Loran
;LAST MODIFICATION:	@(#)get_fpc.pro	1.4 01/29/98
;
;NOTES: The procedure "load_3dp_data" must be 
;	called first.
;-
function get_fpc,t,advance=adv, times=tms, index=idx
@wind_com.pro

dat = {						$
	time: 0D,				$
	index: 0L,				$
	select_by:  0,				$ ;  Change later when implementing index
	spinperiod: 0D,				$
	spin:       0L,				$
	E_steps:    0L,				$
	Bq_th:      0L,				$
	Bq_ph:      0L,				$
	Energy:     0.,				$
	B_th:       0.,				$
	B_ph:       0.,				$
	code:       0L,				$
	valid:      0L,				$
	time_total: intarr(8),			$
	flags:      intarr(8),			$
	sample_time:fltarr(128),		$
	total:      fltarr(128,4),		$
	sin:        fltarr(128,4),		$
	cos:        fltarr(128,4),		$
	freq:       fltarr(128),		$
	sint:       fltarr(128),		$
	cost:       fltarr(128),		$
	wave_ampl:  fltarr(128),		$
	phi:        fltarr(128,4),		$
	theta:      fltarr(128,4)		$
}

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
   num = call_external(wind_lib,'fpc_to_idl')
   if num eq 0 then return,0
   options(0) = num
   times = dblarr(num)
   ok = call_external(wind_lib,'fpc_to_idl',options,times)
   print,ok+1,'  FPC time samples'
   if ok lt 0 then return,0d else return,times(0:ok)
endif

time = gettime(t)
if (n_elements(time) eq 1) then time=[time,time]
ok=call_external(wind_lib,'fpc_to_idl',options,time,dat)

return, dat
end
