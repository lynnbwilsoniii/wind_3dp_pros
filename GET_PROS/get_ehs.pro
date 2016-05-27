pro convert_ehs_units, data, units, scale=scale
if n_params() eq 0 then return

if strupcase(units) eq strupcase(data.units_name) then return

energy = data.energy           ; in eV                (ne,nbins)
n_e = data.nenergy             ; number of energies   
nbins=data.nbins               ; number of bins       
dt = data.dt                   ; 
gf = data.gf * data.geomfactor
deadtime = data.deadtime


mass = data.mass               ; scaler

rate = data.data/dt

dtc = (1.-rate*deadtime)
w = where( dtc lt .2,c)
if c ne 0 then dtc(w) = !values.f_nan



scale = 0
case strupcase(units) of 
'COUNTS' :  scale = 1.
'RATE'   :  scale = 1 / dt
'CRATE'  :  scale = 1 /dtc / dt
'EFLUX'  :  scale = 1 /dtc / (dt * gf)
'E2FLUX' :  scale = 1 /dtc / (dt * gf) * energy
'E3FLUX' :  scale = 1 /dtc / (dt * gf) * energy^2
'FLUX'   :  scale = 1 /dtc / (dt * gf * energy)
'DF'     :  scale = 1 /dtc / (dt * gf * energy^2 * (2./mass/mass*1e5) )
else: begin
        message,'Undefined units: '+units
	return
      end
endcase


case strupcase(data.units_name) of 
'COUNTS' :  scale = scale * 1.
;'RATE'   :  scale = scale * dt
;'CRATE'  :  scale = scale * dtc * dt
;'EFLUX'  :  scale = scale * dtc * (dt * gf)
;'FLUX'   :  scale = scale * dtc * (dt * gf * energy)
;'DF'     :  scale = scale * dtc * (dt * gf * energy^2 * 2./mass/mass*1e5)
else: begin
        print,'Unknown starting units: ',data.units_name
	return
      end
endcase

data.units_name = units

if find_str_element(data,'ddata') ge 0 then data.ddata = data.ddata*scale
data.data = data.data * scale 
return
end





;+
;FUNCTION:   get_ehs(t)
;INPUT:
;    t: double,  seconds since 1970. If this time is a vector then the
;	routine will get all samples in between the two times in the 
;	vector
;KEYWORDS:
;	advance:	advance to the next data point
;	index:		select data by sample index instead of by time.
;	times:		if non-zero, return an array of data times 
;			corresponding to data samples.
;PURPOSE:   returns a 3d structure containing all data pertinent to a single
;  eesa high slice 3d sample.  See "3D_STRUCTURE" for a more complete 
;  description of the structure.
;
;CREATED BY:	Peter Schroeder
;LAST MODIFIED: @(#)get_ehs.pro	1.8 99/03/02
;
;NOTES: The procedure "load_3dp_data" must be 
;	called first.
;-

function get_ehs,t,add, times=tms, index=idx  ;, advance = adv
@wind_com.pro

dat = { ehs_struct, $
   PROJECT_NAME:   'Wind 3D Plasma', $
   DATA_NAME:      'Eesa High Slice', $
   UNITS_NAME:     'Counts', $
   UNITS_PROCEDURE:'convert_ehs_units', $
   TIME      :     0.d, $
   END_TIME  :     0.d, $
   TRANGE    :     [0.d,0.d], $
   INTEG_T   :     0.d, $
   DELTA_T   :     0.d, $
   MASS      :     0.d, $
   GEOMFACTOR:     0.d, $
   INDEX     :     0l, $
   N_samples :     0l,  $
   SHIFT     :     0b, $
   VALID     :     0, $
   SPIN      :     0l, $
   NBINS     :     24, $
   NENERGY   :     30, $
   DACCODES  :     intarr(8,15),  $
   VOLTS     :     fltarr(8,15),  $
   DATA      :     fltarr(30, 24), $
   energy    :     fltarr(30, 24), $
   denergy   :     fltarr(30, 24), $
   phi: fltarr(30, 24), $
   dphi: fltarr(30, 24), $
   theta: fltarr(30, 24), $
   dtheta: fltarr(30, 24), $
   bins      :     replicate(1b,30,24), $
   dt        :     fltarr(30,24), $
   gf        :     fltarr(30,24), $
   bkgrate   :     fltarr(30,24), $
   deadtime  :     fltarr(30,24), $
   dvolume   :     fltarr(30,24), $
   ddata     :     replicate(!values.f_nan,30,24), $
   magf       :     replicate(!values.f_nan,3), $
   vsw	     :     replicate(!values.f_nan,3), $
   domega: fltarr(24), $
   sc_pot: 0., $
   e_shift: 0. $

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
;   num = call_external(wind_lib,'ehs_to_idl')
   num = 10000
   options(0) = num
   times = dblarr(num)
   ok = call_external(wind_lib,'ehs_to_idl',options,times)
   print,ok+1,'  Eesa high slice time samples'
   if ok lt 0 then return,0d else return,times(0:ok)
endif

time = gettime(t)
if (n_elements(time) eq 1) then time=[time,time]
retdat = dat
q = 0
oldtime=dat.time
repeat begin
	ok = call_external(wind_lib,'ehs_to_idl',options,time,dat)
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
retdat.geomfactor = retdat.geomfactor * 0.8

;@get_el2_extra.pro

return,retdat
end

