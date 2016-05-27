;+
;PROCEDURE:	load_wi_3dp
;PURPOSE:	
;   loads WIND 3D Plasma Experiment key parameter data for "tplot".
;
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  NVDATA:	Raw non-varying data can be returned through this variable.
;  POLAR:       Computes polar coordinates if set.
;  TIME_RANGE:  2 element vector specifying the time range.
;  VTHERMAL:	if nonzero, calculates ion thermal velocities.
;  RESOLUTION:	Returns data at a given time resolution.  In seconds.
;  MASTERFILE:	(String) full filename of master file.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_3dp.pro
;LAST MODIFICATION: 02/04/19
;-
pro load_wi_3dp $
   ,time_range=trange $
   ,filenames=filenames $
   ,pathname = pathname $
   ,verbose = verbose $
   ,vthermal=vth $
   ,data=d $
   ,nvdata = nd $
   ,resolution = res $
;   ,masterfile=masterfile $
   ,polar=polar


cdfnames = ['ion_density',  'ion_vel', 'ion_temp','ion_flux',  $
          'elect_density','elect_vel', 'elect_temp','elect_flux']
novarnames = ['ion_flux_energy','e_flux_energy']


if not keyword_set(masterfile) then masterfile = 'wi_k0_3dp_files'
loadallcdf,time_range=trange,masterfile=masterfile,filenames=filenames, $
   cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,resolution=res


px = 'wi_3dp_'

vxlab = ['Vx','Vy','Vz']
ilab = string(nd.ion_flux_energy,format='(f6.2," keV")')
elab = string(nd.e_flux_energy,format='(f6.2," keV")')

store_data,px+'Ne',data={x:d.time,y:d.elect_density},min=-1e30
store_data,px+'Ve',data={x:d.time,y:dimen_shift(d.elect_vel,1)}, $
   dlim={labels:vxlab},min=-1e30
store_data,px+'Te',data={x:d.time,y:d.elect_temp},min=-1e30
store_data,px+'Fe',data={x:d.time,y:dimen_shift(d.elect_flux,1),v:nd.e_flux_energy},$
  dlim={ylog:1,labels:elab,labflag:-1},min=-1e30

store_data,px+'Np',data={x:d.time,y:d.ion_density},min=-1e30
store_data,px+'Vp',data={x:d.time,y:dimen_shift(d.ion_vel,1)},$
  dlim={labels:vxlab},min=-1e30
store_data,px+'Tp',data={x:d.time,y:d.ion_temp},min=-1e30
store_data,px+'Fp',data={x:d.time,y:dimen_shift(d.ion_flux,1),v:nd.ion_flux_energy},$
  dlim={ylog:1,labels:ilab,labflag:-1},min=-1e30

if keyword_set(vth) then begin
  vthp = sqrt(d.ion_temp/.00522)
  store_data,px+'VTHp',data={x:d.time,y:vthp}
endif
if keyword_set(polar) then xyz_to_polar,'wi_3dp_Ve',/ph_0_360
if keyword_set(polar) then xyz_to_polar,'wi_3dp_Vp',/ph_0_360


end
