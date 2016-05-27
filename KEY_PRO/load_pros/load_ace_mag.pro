;+
;PROCEDURE:     load_ace_mag
;PURPOSE:
;   loads ACE MAG Experiment key parameter data for "tplot".
;
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  TIME_RANGE:  2 element vector specifying the time range.
;  MASTERFILE:  (String) full filename of master file.
;  POLAR:	Computes B field and SC position in polar coordinates.
;SEE ALSO: 
;  "loadallhdf"
;
;CREATED BY:    Peter Schroeder
;LAST MODIFIED: @(#)load_ace_mag.pro	1.2 02/04/12
;-
pro load_ace_mag,data=data,time_range=time_range,masterfile=masterfile,$
	polar=polar,filenames=filenames

vdataname = 'MAG_data_16sec'
tplot_prefix = 'ace_mag_'

if not keyword_set(indexfile) then indexfile='ace_mag_files'
hdfnames=['ACEepoch','Bgse_x','Bgse_y','Bgse_z','dBrms','sigma_B',$
'fraction_good','N_vectors','Quality','pos_gse_x','pos_gse_y','pos_gse_z']

loadallhdf,time_range=time_range,vdataname=vdataname,data=data,$
	indexfile=indexfile,masterfile=masterfile,filenames=filenames $
	,hdfnames=hdfnames

timearray = data.ACEepoch + time_double('96-1-1')

baddataindx = where(data.Quality eq 2,baddatacnt)
if baddatacnt ne 0 then begin
	data.Bgse_x[baddataindx] = !values.f_nan
	data.Bgse_y[baddataindx] = !values.f_nan
	data.Bgse_z[baddataindx] = !values.f_nan
endif

store_data,tplot_prefix+'Bgse',data={x: timearray, $
	y: [[data.Bgse_x],[data.Bgse_y],[data.Bgse_z]]}
if keyword_set(polar) then xyz_to_polar,tplot_prefix+'Bgse',/ph_0_360
store_data,tplot_prefix+'dBrms',data={x: timearray, y: data.dBrms}
store_data,tplot_prefix+'sigma_B',data={x: timearray, y: data.sigma_B}
store_data,tplot_prefix+'fraction_good',data={x: timearray, y: data.fraction_good}
store_data,tplot_prefix+'N_vectors',data={x: timearray, y: data.N_vectors}
store_data,tplot_prefix+'Quality',data={x: timearray, y: data.Quality}
store_data,tplot_prefix+'pos_gse',data={x: timearray, $
	y: [[data.pos_gse_x],[data.pos_gse_y],[data.pos_gse_z]]/6370.}
if keyword_set(polar) then xyz_to_polar,tplot_prefix+'pos_gse',/ph_0_360

return
end
