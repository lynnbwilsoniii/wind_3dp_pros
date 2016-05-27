;+
;PROCEDURE: _get_example_dat
;NAME:
;  _get_example_dat
;PURPOSE:
;  A procedure that generates sample data for "TPLOT".
;  See the crib sheet: "_tplot_example" for instructions on using this routine.
;
;CREATED BY:	Davin Larson  96-2-19
;FILE:  _get_example_dat.pro
;VERSION:  1.4
;LAST MODIFICATION:  96/10/14
;- 



pro _get_example_dat, n_samples=n_samples,seed=seed

if not keyword_set(n_samples) then n_samples = 300


n_energy = 15             ; number of energy steps
emin = 2.                 ; energy range
emax = 700.

delta_time = 3600. * 4.   ; four hours of data
start_time = str_to_time('95-11-22')   ; random start date

time = dindgen(n_samples)*delta_time/(n_samples-1) + start_time
energy = (emax/emin)^(findgen(n_energy)/(n_energy-1)) * emin
elabs = strtrim(string(energy,format='(f5.1," eV")'),2)

;Generate some random numbers:
b = 20
r1 = (smooth( randomn(seed,n_samples+2*b), b))(b:n_samples+b-1)
r2 = (smooth( randomn(seed,n_samples+2*b), b))(b:n_samples+b-1)

;Generate amplitude and slope
amplitude = 1e6 * exp(r1/2.)
slope     = -1.5 + .2 * r2


x = replicate(1.,n_samples)
e = replicate(1.,n_energy)
data = (amplitude # e) * ( (x # energy) ^ (slope # e))


;Store the data:
;Please note: in the following examples ONLY the elements x and y are required

store_data,'amp',dat={x:time, y:amplitude},dlim={ytitle:'Amplitude'}

store_data,'slp',dat={x:time, y:slope},dlim={ytitle:'Slope'}

store_data,'flx1',dat={x:time, y:data, v:energy}, $
  dlim={labels:elabs ,zlog:1, ylog:1, ytitle:'Flux', panel_size:2.0}

;The element spec is a flag indicating a spectrogram.
store_data,'flx2',dat={x:time, y:data, v:energy}, dlim={labels:elabs, $
  zlog:1, ylog:1, spec:1,  ytitle:'Energy', ztitle:'Flux (Counts)',  $
  panel_size:2.0}




;generate a sample spacecraft altitude:
time0 = time(n_samples/3)
alt = 250.* (1 -  ((time-time0)/delta_time)^2)

store_data,'alt',dat ={x:time, y:alt}, dlim ={ format:'(F8.2)'}



;Generate simulated housekeeping data:
hkp = bindgen(n_samples)

;Turn MSB on only when the slope is greater than -1.45
hkp = hkp and not 128b         ; turn off MSB
w = where(slope gt -1.45,c)
if c ne 0 then hkp(w) = hkp(w) or 128b
store_data,'hkp_dat',dat = {x:time,y:hkp}, dlim={tplot_routine:'bitplot'   $
   ,labels:['b0','b1','b2','b3','b4','b5','b6','H']}

end

