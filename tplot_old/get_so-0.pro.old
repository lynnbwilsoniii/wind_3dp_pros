;+
;FUNCTION:   get_so(t)
;INPUT:
;    t: double,  seconds since 1970. If this time is a vector then the
;	routine will get all samples in between the two times in the 
;	vector
;KEYWORDS:
;       chanmode:       if set, load only channels that are read out for
;                       the selected packet.
;	index:		select data by sample index instead of by time.
;	times:		if non-zero, return and array of data times 
;			corresponding to data samples.
;PURPOSE:   returns a 3d structure containing all data pertinent to a single
;  SST Open sample.  See "3D_STRUCTURE" for a more complete 
;  description of the structure.
;
;CREATED BY:	Peter Schroeder
;LAST MODIFIED:	@(#)get_so.pro	1.21 99/03/02
;
;NOTES: The procedure "load_3dp_data" must be 
;	called first.
;-

function get_so,t,add, times=tms, index=idx, chanmode=chanmode  ;, advance = adv
@wind_com.pro

dat = { so_struct2, $
   PROJECT_NAME:   'Wind 3D Plasma', $
   DATA_NAME:      'SST Open', $
   UNITS_NAME:     'Counts', $
   UNITS_PROCEDURE:'convert_so_units', $
   TIME      :     0.d, $
   END_TIME  :     0.d, $
   TRANGE    :     [0.d,0.d], $
   INTEG_T   :     0.d, $
   DELTA_T   :     0.d, $
   MASS      :     0.d, $
   GEOMFACTOR:     0.d, $
   INDEX     :     0l, $
   N_samples :     0l,  $
   VALID     :     0, $
   SPIN      :     0l, $
   NBINS     :     48, $
   NENERGY   :     9, $
   detector  :     intarr(48), $
   DATA      :     fltarr(9, 48), $
   energy    :     fltarr(9, 48), $
   denergy   :     fltarr(9, 48), $
   phi: fltarr(9, 48), $
   dphi: fltarr(9, 48), $
   theta: fltarr(9, 48), $
   dtheta: fltarr(9, 48), $
   bins      :     replicate(1b,9,48), $
   dt        :     fltarr(9,48), $
   gf        :     fltarr(9,48), $
   bkgrate   :     fltarr(9,48), $
   deadtime  :     fltarr(9,48), $
   dvolume   :     fltarr(9,48), $
   ddata     :     replicate(!values.f_nan,9,48), $
   magf      :     replicate(!values.f_nan,3), $
   vsw       :     replicate(!values.f_nan,3), $
   sc_pot    :     0., $
   domega: fltarr(48) $
}

size = n_tags(dat,/length)
if (n_elements(idx) eq 0) and (n_elements(t) eq 0) and (not keyword_set(adv)) $
	and (not keyword_set(tms)) then ctime,t
if keyword_set(adv) then a=adv else a=0
if n_elements(idx) eq 0 then i=-1 else i=idx
if n_elements(t)   eq 0 then t=0.d
if keyword_set(chanmode) or n_elements(t) eq 2 then c=1 else c=0

options = long([size,a,i,c])

if n_elements(wind_lib) eq 0 then begin
  print, 'You must first load the data'
  return,0
endif

; get times if requested
if keyword_set(tms) then begin
;   num = call_external(wind_lib,'sst_foil_to_idl')
   num = 100000
   options(0) = num
   times = dblarr(num)
   ok = call_external(wind_lib,'sst_open_to_idl',options,times)
   print,ok+1,'  SST Open time samples'
   if ok lt 0 then return,0d else return,times(0:ok)
endif

time = gettime(t)
if (n_elements(time) eq 1) then time=[time,time]
retdat = dat
q = 0
oldtime = dat.time
repeat begin
	ok = call_external(wind_lib,'sst_open_to_idl',options,time(0),dat)
	dat.end_time = dat.time + dat.integ_t
	if retdat.valid eq 0 then retdat = dat   $
	else if dat.time ge oldtime and dat.valid eq 1 then begin
		retdat.data = dat.data +  retdat.data
		retdat.dt   = dat.dt   +  retdat.dt
		retdat.delta_t = dat.delta_t + retdat.delta_t
		retdat.integ_t = dat.integ_t + retdat.integ_t
		retdat.end_time = dat.end_time
		retdat.n_samples = dat.n_samples
		oldtime = dat.time
		q = dat.end_time gt time(1)
	endif else if dat.valid eq 1 then q = 1
	options[2] = dat.index+1
	if (time(1) eq time(0)) then q=1
endrep until q

retdat.trange = [retdat.time,retdat.end_time]

;@get_so2_extra.pro

return,retdat
end

