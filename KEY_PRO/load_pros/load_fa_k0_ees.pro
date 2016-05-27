;+
;PROCEDURE:	load_fa_k0_ees
;PURPOSE:	
;   loads FAST Electron key parameter data for "tplot".
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
;FILE:  %M%
;LAST MODIFICATION: %E%
;-
pro load_fa_k0_ees $
   ,time_range=trange $
   ,filenames=filenames $
   ,masterfile=masterfile $
   ,verbose = verbose $
   ,vthermal=vth $
   ,data=d $
   ,nvdata = nd $
   ,resolution = res $
   ,polar=polar


;cdfnames = ['ion_density',  'ion_vel', 'ion_temp','ion_flux',  $
;          'elect_density','elect_vel', 'elect_temp','elect_flux']
;novarnames = ['ion_flux_energy','e_flux_energy']


if not keyword_set(masterfile) then masterfile = 'fa_k0_ees_files'
loadallcdf,time_range=trange,masterfile=masterfile,filenames=filenames, $
   cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,resolution=res


px = 'fa_ees_'

lim = {spec:1,yrange:[40,40000.],ystyle:1,ylog:1,zrange:[1e4,1e9],zlog:1 }
store_data,px+'pa_0',data={x:d.time,y:transpose(d.EL_0),v:transpose(d.EL_EN) },dlim=lim
store_data,px+'pa_90',data={x:d.time,y:transpose(d.EL_90),v:transpose(d.EL_EN) },dlim=lim
store_data,px+'pa_180',data={x:d.time,y:transpose(d.EL_180),v:transpose(d.EL_EN) },dlim=lim

lim = {spec:1,yrange:[0,180],ystyle:1,ylog:0 ,zrange:[1e4,1e9],zlog:1}
store_data,px+'en_low',data={x:d.time,y:transpose(d.EL_low),v:transpose(d.EL_LOW_PA) },dlim=lim
store_data,px+'en_high',data={x:d.time,y:transpose(d.EL_high),v:transpose(d.EL_HIGH_PA) },dlim=lim

store_data,px+'jee',data={x:d.time,y:d.jee,v:d.JEE },dlim={yrange:[-2,20],ystyle:1}
store_data,px+'je',data={x:d.time,y:d.jee,v:d.JE },dlim={yrange:[-2,20],ystyle:1}


end
