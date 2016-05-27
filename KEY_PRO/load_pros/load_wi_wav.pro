;+
;PROCEDURE:	load_wi_wav
;PURPOSE:	
;   loads WIND WAVES Experiment key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  NVDATA:	Raw non-varying data can be returned through this variable.
;  TIME_RANGE:  2 element vector specifying the time range.
;  MASTERFILE:  (string) full file name to the master file.
;  RESOLUTION:  number of seconds resolution to return.
;  NE_FILTER:	Name of electron density variable to be used as filter.
;  MOON:	Load moon position data.
;  SOLAR:	Load solar data.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_wav.pro
;LAST MODIFICATION: 99/05/27
;-
pro load_wi_wav,time_range=trange,data=d,nvdata=nd $
   ,masterfile=masterfile,resolution=res,ne_filter=ne_filter $
   ,moon=moon,solar=solar

if not keyword_set(masterfile) then masterfile = 'wi_k0_wav_files'
cdfnames = ['Ne','Ne_Quality',  'E_Average','Moon_pos','Sol_min','Sol_max']
tagnames = ['Nel','Ne_Quality', 'E_A',      'moon_pos','Sol_min','Sol_max']
novarnames = ['E_freq_val']

d=0

loadallcdf,time_range=trange,masterfile=masterfile,resolution=res, $
   cdfnames=cdfnames,tagnames=tagnames,data=d, $
   novarnames=novarnames,novard=nd

if not keyword_set(d) then return

n = d.nel
w = where((d.ne_quality lt 100) or (n lt 0.) or (n gt 300.),nw)
if nw ne 0 then n(w)=!values.f_nan

px = 'wi_wav_'

if keyword_set(ne_filter) then begin
   n_e = data_cut(ne_filter,d.time)
   bad = where((d.nel lt n_e/2.) or (d.nel gt n_e*2.))
   d[bad].nel = !values.f_nan
endif


store_data,px+'Ne',data={x:d.time,y:d.nel}
store_data,px+'Pow',data={x:d.time,y:dimen_shift(d.e_a,1),v:nd.E_freq_val}$
  ,min=-0.1 $
  ,dlim={ytitle:'Freq (Hz)',spec:1,ylog:1,ystyle:1,panel_size:2.  $
  ,yrange:[4e3,1.2e7],zrange:[0.,80.],ztitle:'WAVES Power'}
if keyword_set(moon) then $
  store_data,'moon_pos',data={x:d.time,y:dimen_shift(d.moon_pos,1)/6370.},min=-1e30
if keyword_set(solar) then begin $
  store_data,'wi_sol_arr',data = {x:d.time,y:[[d.sol_min],[d.sol_max]]}
endif


end
