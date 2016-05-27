;+
;PROCEDURE:	load_wi_pm_3dp
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
;  RESOLUTION:  number of seconds resolution to return.
;  PREFIX:	Prefix for TPLOT variables created.  Default is 'wi_pm_'
;  POLAR:       Computes polar coordinates if set.
;  VTHERMAL:	If set, calculates and stores thermal velocity.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_pm_3dp.pro
;LAST MODIFICATION: 99/05/27
;-
pro load_wi_pm_3dp $
   ,time_range=trange $
   ,data=d $
   ,nvdata = nd $
   ,masterfile=masterfile $
   ,prefix = prefix $
   ,vthermal = vth $
   ,resolution = res $
   ,polar=polar

if not keyword_set(masterfile) then masterfile = 'wi_pm_3dp_files'

cdfnames = ['P_DENS',  'P_VELS', 'P_TENS','P_TEMP',  $
          'A_DENS','A_VELS', 'A_TENS','A_TEMP','E_RANGE','VALID']
;novarnames = ['ion_flux_energy','e_flux_energy']

d = 0
loadallcdf,masterfile=masterfile,cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange,resolution=res
if not keyword_set(d) then return

if data_type(prefix) eq 7 then px=prefix else px = 'wi_pm_'

vxlab = ['Vx','Vy','Vz']

store_data,px+'Np',data={x:d.time,y:d.P_DENS},min=-1e30,  $
  dlim={ytitle:'N!dP!n',yrange:[0.,20.]}
store_data,px+'Vp',data={x:d.time,y:dimen_shift(d.P_VELS,1)},min=-1e30,$
  dlim={ytitle:'V!dP!n',yrange:[-700,100],labels:vxlab}
if keyword_set(polar) then begin
  xyz_to_polar,px+'Vp',/ph_0_360
  options,px+'Vp_mag','ytitle','|V!dP!n|',/def
  options,px+'Vp_th','ytitle','!9Q!X!DVp!N',/def
  ylim,px+'Vp_th',-20,20
  options,px+'Vp_phi','ytitle','!9F!X!DVp!N',/def
  ylim,px+'Vp_phi',160,200,0
endif
store_data,px+'Tp',data={x:d.time,y:d.P_TEMP},min=-1e30
store_data,px+'Pp',data={x:d.time,y:dimen_shift(d.P_TENS,1)}

store_data,px+'Na',data={x:d.time,y:d.A_DENS},min=-1e30
store_data,px+'Va',data={x:d.time,y:dimen_shift(d.A_VELS,1)}, $
   dlim={labels:vxlab},min=-1e30
if keyword_set(polar) then xyz_to_polar,px+'Va',/ph_0_360
store_data,px+'Ta',data={x:d.time,y:d.A_TEMP},min=-1e30
store_data,px+'Pa',data={x:d.time,y:dimen_shift(d.A_TENS,1)}

if not keyword_set(vth) then begin
  vthp = sqrt(d.P_TEMP/.00522)
  store_data,px+'VTHp',data={x:d.time,y:vthp}
endif

end
