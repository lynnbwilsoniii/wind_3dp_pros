;+
;PROCEDURE:	load_ge_mgf
;PURPOSE:	
;   loads GEOTAIL MAGNETOMETER Experiment key parameter data for "tplot".
;
;INPUTS:
;  none, but will call "timespan" if time range is not already set.
;KEYWORDS:
;  POLAR:       Also computes the B field in polar coordinates.
;  TIME_RANGE:  2 element vector specifying the time range
;  DATA:        Data returned in this named variable
;RESTRICTIONS:
;  This routine expects to find the master file: 'ge_k0_mgf_files'
;  in the directory specified by the environment variable: 'CDF_DATA_DIR'
;  See "make_cdf_index" for more info.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_ge_mgf.pro
;LAST MODIFICATION: 99/05/27
;-
pro load_ge_mgf,time_range=trange,data=d,polar=polar

masterfile = 'ge_k0_mgf_files'
cdfnames = ['IB_vector','POS','Gap_Flag']


loadallcdf,time_range=trange,masterfile=masterfile,cdfnames=cdfnames,data=d

bad = where(d.gap_flag,c)
if c ne 0 then begin
;   d(bad).pos = !values.f_nan
   d(bad).ib_vector=!values.f_nan
endif

b = dimen_shift(d.ib_vector/10.,1)

px = 'ge_B'

store_data,px,data={x:d.time,y:b} 
store_data,px,lim={labels:['Bx','By','Bz']}

store_data,'ge_pos',data={x:d.time,y:dimen_shift(d.pos/6370.,1)} 

if keyword_set(polar) then xyz_to_polar,px

end
