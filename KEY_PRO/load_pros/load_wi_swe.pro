;+
;PROCEDURE:	load_wi_swe
;PURPOSE:
;   loads WIND Solar Wind Experiment key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  TIME_RANGE:  2 element vector specifying the time range.
;  MASTERFILE:  (string) full file name to the master file.
;  POLAR:	If set, calculate and store velocity in polar
;		coordinates.
;SEE ALSO:
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_swe.pro
;LAST MODIFICATION: 02/12/03
;-
pro load_wi_swe,time_range=trange,data=d,polar=polar,resolution=res, $
  filenames=files,bartel=bartel  ;,prefix=prefix

if not keyword_set(masterfile) then masterfile = 'wi_k0_swe_files'
if keyword_set(bartel) then masterfile = 'wi_swe_k0_B_files'

cdfnames = ['Np','THERMAL_SPD','V_GSE']   ;,'Alpha_Percent']

loadallcdf,time_range=trange,masterfile=masterfile,res=res,filenames=files, $
     cdfnames=cdfnames,data=d

nan = !values.f_nan
if not keyword_set(d) then begin
  message,/info,'Unable to load data.'
  return
endif
bad = where(d.np lt 0,c)
if c gt 0 then for i=1,n_tags(d)-1 do d(bad).(i) = nan



tp = .00522 * d.thermal_spd^2     ;  tp = 1/2 m vth^2

d.V_GSE(1) = d.V_GSE(1) + 29.86  ;remove Earth motion correction

store_data,'wi_swe_Np',data={x:d.time,y:d.NP}
store_data,'wi_swe_Vp',data={x:d.time,y:dimen_shift(d.V_GSE,1)}
store_data,'wi_swe_Tp',data={x:d.time,y:tp}
store_data,'wi_swe_VTHp',data={x:d.time,y:d.thermal_spd}
;store_data,'wi_swe_A/P',data={x:d.time,y:d.alpha_percent}
if keyword_set(polar) then xyz_to_polar,'wi_swe_Vp',/ph_0_360


end
