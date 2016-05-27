;+
;PROCEDURE:	load_moon_pos
;PURPOSE:	
;   loads moon pos from WIND WAVES key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  NVDATA:	Raw non-varying data can be returned through this variable.
;  TIME_RANGE:  2 element vector specifying the time range.
;  MASTERFILE:  (string) full file name to the master file.
;  RESOLUTION:  number of seconds resolution to return.
;  MOON:	Load moon position data.
;  SOLAR:	Load solar data.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_moon_pos.pro
;-
pro load_moon_pos,time_range=trange,data=d,nvdata=nd $
   ,masterfile=masterfile,resolution=res,ne_filter=ne_filter $
   ,solar=solar

if not keyword_set(masterfile) then masterfile = 'wi_k0_wav_files'
cdfnames = ['Moon_pos','Sol_min','Sol_max']
tagnames = ['moon_pos','Sol_min','Sol_max']
;novarnames = ['E_freq_val']

d=0

loadallcdf,time_range=trange,masterfile=masterfile,resolution=res, $
   cdfnames=cdfnames,tagnames=tagnames,data=d, $
   novarnames=novarnames,novard=nd

if not keyword_set(d) then return


store_data,'moon_pos',data={x:d.time,y:dimen_shift(d.moon_pos,1)/6370.},min=-1e30
if keyword_set(solar) then begin $
  store_data,'wi_sol_arr',data = {x:d.time,y:[[d.sol_min],[d.sol_max]]}
endif


end
