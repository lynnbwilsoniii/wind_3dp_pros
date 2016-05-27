;+
;PROCEDURE:	load_i8_pla
;PURPOSE:	
;   loads IMP-8 Plasma Experiment key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  TIME_RANGE:  2 element vector specifying the time range
;  DATA:	returns data structure
;RESTRICTIONS:
;  This routine expects to find the master file: 'i8_k0_pla_files'
;  In the directory specified by the environment variable: 'CDF_DATA_DIR'
;  See "make_cdf_index" for more info.
;  
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_i8_pla.pro
;LAST MODIFICATION: 02/04/12
;-
pro load_i8_pla,time_range=trange,data=d,filenames=filenames

masterfile = 'i8_k0_pla_files'
cdfnames = ['Np','THERMAL_SPEED','V_GSE','SC_pos_gse']

loadallcdf,time_range=trange,masterfile=masterfile,filenames=filenames $
   ,cdfnames=cdfnames,data=d

np = dimen_shift(d.np,1)
thsp = dimen_shift(d.thermal_speed,1)
vsw = dimen_shift(d.v_gse,1)
pos = dimen_shift(d.sc_pos_gse,1) / 6380.
time = d.time

nan = !values.f_nan
bad = where(np gt 1000.,c)
if c gt 0 then begin
   np(bad) = nan
   vsw(bad) = nan
   thsp(bad) = nan
endif


tp = .00522 * d.thermal_speed^2

store_data,'i8_pla_Np',data={x:d.time,y:d.NP}
store_data,'i8_pla_Vp',data={x:d.time,y:dimen_shift(d.V_GSE,1)}
store_data,'i8_pla_Tp',data={x:d.time,y:tp}
store_data,'i8_pla_VTHp',data={x:d.time,y:d.thermal_speed}
;store_data,'i8_pos',data={x:d.time,y:dimen_shift(d.sc_pos_gse,1)}


end
