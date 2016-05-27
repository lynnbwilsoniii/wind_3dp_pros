;+
;PROCEDURE:     load_ace_sis
;PURPOSE:
;   loads ACE SIS Experiment key parameter data for "tplot".
;
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  TIME_RANGE:  2 element vector specifying the time range.
;  MASTERFILE:  (String) full filename of master file.
;SEE ALSO: 
;  "loadallhdf"
;
;CREATED BY:    Peter Schroeder
;LAST MODIFIED: @(#)load_ace_sis.pro	1.1 00/01/20
;-
pro load_ace_sis,data=data,time_range=time_range,masterfile=masterfile

vdataname = 'SIS_data_256s'
tplot_prefix = 'ace_sis_'

if not keyword_set(indexfile) then indexfile='ace_sis_files'
hdfnames=['ACEepoch','flux_He','flux_C','flux_N','flux_O','flux_Ne','flux_Mg',$
	'flux_Si','flux_S','flux_Fe','up_time_fraction','solar_activity_flag']

loadallhdf,time_range=time_range,vdataname=vdataname,data=data,$
	indexfile=indexfile,masterfile=masterfile,hdfnames=hdfnames

timearray = data.ACEepoch + time_double('96-1-1')
str_element,data,'time',timearray,/add

store_data,'ace_sis',data=data

return
end
