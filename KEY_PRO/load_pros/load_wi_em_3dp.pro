;+
;PROCEDURE:	load_wi_em_3dp
;PURPOSE:	
;   loads WIND 3D Plasma Experiment key parameter data for "tplot".
;
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  NVDATA:	Raw non-varying data can be returned through this variable.
;  TIME_RANGE:  2 element vector specifying the time range.
;  MASTERFILE:  (string) full file name to the master file.
;  PREFIX:	Prefix for TPLOT variables created.  Default is 'wi_em_'
;  POLAR:	If nonzero, compute velocities in polar coordinates.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_em_3dp.pro
;LAST MODIFICATION: 99/05/27
;-
pro load_wi_em_3dp $
   ,time_range=trange $
   ,data=d $
   ,nvdata = nd $
   ,masterfile=masterfile $
   ,prefix = prefix $
   ,polar=polar

if not keyword_set(masterfile) then masterfile = 'wi_em_3dp_files'

cdfnames = ['E_DENS',  'E_VELS', 'E_TENS','E_TEMP', 'E_Q', $
          'GAP','VALID']

d = 0
loadallcdf,masterfile=masterfile,cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange
if not keyword_set(d) then return

if data_type(prefix) eq 7 then px=prefix else px = 'wi_em_'

vxlab = ['Vx','Vy','Vz']

store_data,px+'Ne',data={x:d.time,y:d.E_DENS},min=-1e30
store_data,px+'Ve',data={x:d.time,y:dimen_shift(d.E_VELS,1)},$
  dlim={labels:vxlab},min=-1e30
if keyword_set(polar) then xyz_to_polar,px+'Ve',/ph_0_360
store_data,px+'Te',data={x:d.time,y:d.E_TEMP},min=-1e30
store_data,px+'Pe',data={x:d.time,y:dimen_shift(d.E_TENS,1)}


end
