;+
;FUNCTION:   get_tspc(t)
;INPUT:
;    t: double,  seconds since 1970. If this time is a vector than the
;	routine will get all samples in between the two times in the 
;	vector
;KEYWORDS:
;	advance:
;	index:		select data by sample index instead of by time.
;	times:		if non-zero, return and array of data times 
;			corresponding to data samples.
;PURPOSE:   returns a  structure containing all data pertinent to a single
;  f+t & o+t spectra.  See the file 3dp_help.doc for a more complete 
;  description of the structure.
;
;CREATED BY:	Robert D. Campbell
;LAST MODIFICATION:	%W% %E%
;
;NOTES: The procedure "load_3dp_data" must be 
;	called first.
;-

function get_tspc,t,advance=adv, times=tms, index=idx

@wind_com.pro
dat = { tspc_struct, $
   PROJECT_NAME:   'Wind 3D Plasma', $
   DATA_NAME:      'F+T & O+T spectra', $
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
   NBINS     :     4, $
   NENERGY   :     24, $
   detector  :     intarr(4), $
   DATA      :     fltarr(24, 4), $
   energy    :     fltarr(24, 4), $
   denergy   :     fltarr(24, 4), $
   phi: fltarr(24, 4), $
   dphi: fltarr(24, 4), $
   theta: fltarr(24, 4), $
   dtheta: fltarr(24, 4), $
   bins      :     replicate(1b,24,4), $
   dt        :     fltarr(24,4), $
   gf        :     fltarr(24,4), $
   bkgrate   :     fltarr(24,4), $
   deadtime  :     fltarr(24,4), $
   dvolume   :     fltarr(24,4), $
   ddata     :     replicate(!values.f_nan,24,4), $
   magf      :     replicate(!values.f_nan,3), $
   vsw       :     replicate(!values.f_nan,3), $
   sc_pot    :     0., $
   domega: fltarr(4), $
   feff      :     fltarr(24,4) $
}

size = n_tags(dat,/length)
if (n_elements(idx) eq 0) and (n_elements(t) eq 0) and (not keyword_set(adv)) $
	and (not keyword_set(tms)) then ctime,t
if keyword_set(adv) then a=adv else a=0
if n_elements(idx) eq 0 then i=-1 else i=idx
if n_elements(t)   eq 0 then t=0.d
if keyword_set(chanmode) then c=1 else c=0

options = long([size,a,i,c])

if n_elements(wind_lib) eq 0 then begin
  print, 'You must first load the data'
  return,0
endif

; get times if requested
if keyword_set(tms) then begin
   num = call_external(wind_lib,'tspc_to_idl')
   options(0) = num
   times = dblarr(num)
   ok = call_external(wind_lib,'tspc_to_idl',options,times)
   print,ok+1,'  F+T & O+T spectra time samples'
   if ok lt 0 then return,0d else return,times(0:ok)
endif

time = gettime(t)
if (n_elements(time) eq 1) then time=[time,time]
retdat = dat
q = 0
oldtime = dat.time
repeat begin
	ok = call_external(wind_lib,'tspc_to_idl',options,time,dat)
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
retdat.mass = 5.6856591e-6             ; mass eV/(km/sec)^2
retdat.geomfactor = .3                 ; ? estimate        
return,retdat
end
