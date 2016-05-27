;+
;PROCEDURE:	load_wi_elpd_3dp
;PURPOSE:	
;   loads WIND 3D Plasma Experiment key parameter data for "tplot".
;
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  TIME_RANGE:  2 element vector specifying the time range
;RESTRICTIONS:
;  This routine expects to find the master file: 'wi_elsp_3dp_files'
;  In the directory specified by the environment variable: 'CDF_INDEX_DIR'
;  See "make_cdf_index" for more info.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_elpd2.pro
;LAST MODIFICATION: 99/05/27
;-
pro load_wi_elpd2 $
   ,time_range=trange $
   ,data=d $
   ,nvdata = nd $
   ,masterfile=masterfile $
   ,resolution=res $
   ,prefix = prefix $
   ,no_reduce=no_reduce $
   ,fits = fits $
   ,plot_it=plot_it $
   ,polar=polar



if not keyword_set(masterfile) then masterfile = 'wi_elpd_3dp_files'

cdfnames = ['FLUX',  'ENERGY' ,'PANGLE','MAGF','VSW']
if keyword_set(fits) then cdfnames=[cdfnames,'DENS_CORE','TEMP_CORE', $
  'TDIF_CORE','VEL_CORE','DENS_HALO','VTH_HALO','K_HALO','VEL_HALO','E_SHIFT', $
  'SC_POT']

d = 0
nd = 0
loadallcdf,masterfile=masterfile,cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange,resolution=res

if not keyword_set(d) then return

if data_type(prefix) eq 7 then px=prefix else px = 'elpd'

store_data,px,data={x:d.time,y:dimen_shift(d.flux,1), $
  v1:dimen_shift(d.energy,1),v2:dimen_shift(d.pangle,1)}$
  ,min=-1e30,dlim={ylog:1}

energies = dimen_shift(d.energy,1)
angles = dimen_shift(d.pangle,1)

ang_size = size(angles)
e_size = size(energies)

n_ang = ang_size(ang_size(0))
n_nrg = e_size(e_size(0))

pdname ='elpd'

if not keyword_set(no_reduce) then begin
for i = 0, n_nrg-1 do  reduce_pads,pdname,1,i,i

reduce_pads,pdname,2,7,7
reduce_pads,pdname,2,6,6
reduce_pads,pdname,2,5,5
reduce_pads,pdname,2,4,4
reduce_pads,pdname,2,3,3
reduce_pads,pdname,2,2,2
reduce_pads,pdname,2,1,1
reduce_pads,pdname,2,0,0
ylim,tnames(pdname+'-2-*'),10,1e8,1,/def
endif

if keyword_set(fits) then begin
store_data,px+'_TEMP_CORE',data={x:d.time,y:d.temp_core}
store_data,px+'_DENS_CORE',data={x:d.time,y:d.dens_core}
endif

return
end

