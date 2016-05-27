;+
;PROCEDURE:	load_wi_swe_el
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
;FILE:  %M%
;LAST MODIFICATION: %E%
;-
pro load_wi_swe_el,time_range=trange,data=d,polar=polar,resolution=res, $
  filenames=files,bartel=bartel  

if not keyword_set(masterfile) then masterfile = 'wi_swe_h0_files'
if keyword_set(bartel) then masterfile = 'wi_swe_h0_B_files'

;cdfnames = ['Np','THERMAL_SPD','V_GSE']   ;,'Alpha_Percent']

loadallcdf,time_range=trange,masterfile=masterfile,res=res,filenames=files, $  
     cdfnames=cdfnames,data=d

nan = !values.f_nan
;bad = where(d.np lt 0,c)
;if c gt 0 then for i=1,n_tags(d)-1 do d(bad).(i) = nan



store_data,'swe_el',data=d




end
