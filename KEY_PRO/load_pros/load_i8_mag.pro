;+
;PROCEDURE:	load_i8_mag
;PURPOSE:	
;   loads IMP-8 magnetometer key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  TIME_RANGE:  2 element vector specifying the time range
;  DATA:	returns data structure
;RESTRICTIONS:
;  This routine expects to find the master file: 'i8_k0_mag_files'
;  In the directory specified by the environment variable: 'CDF_DATA_DIR'
;  See "make_cdf_index" for more info.
;  
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_i8_mag.pro
;LAST MODIFICATION: 02/04/12
;-
pro load_i8_mag,time_range=trange,data=d,filenames=filenames

masterfile = 'i8_k0_mag_files'
cdfnames = ['B_GSE_c','B_GSE_p','RMS','SC_pos_se']

loadallcdf,time_range=trange,masterfile=masterfile,filenames=filenames $
   ,cdfnames=cdfnames,data=d

b = dimen_shift(d.b_gse_c,1)
rms = dimen_shift(d.rms,1)
xyz_to_polar,b,mag=mag,theta=th,phi=ph

nan = !values.f_nan
bad = where(mag gt 1000.,c)
if c gt 0 then begin
   b(bad,*)= nan
   mag(bad) = nan
   th(bad)=nan
   ph(bad)=nan
endif
bad = where(rms lt 0,c)
if c gt 0 then rms(bad)=nan

store_data,'i8_B',data={x:d.time,y:b}  , lim={labels:['Bx','By','Bz']}
store_data,'i8_B_rms',data={x:d.time,y:rms}
store_data,'i8_pos',data={x:d.time,y:dimen_shift(d.sc_pos_se,1)}

if keyword_set(polar) then xyz_to_polar,'i8_B'
if keyword_set(polar) then xyz_to_polar,'i8_pos'

end
