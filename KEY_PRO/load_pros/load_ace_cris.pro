;+
;PROCEDURE:     load_ace_cris
;PURPOSE:
;   loads ACE CRIS Experiment key parameter data for "tplot".
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
;LAST MODIFIED: @(#)load_ace_cris.pro	1.1 00/01/20
;-
pro load_ace_cris,data=data,time_range=time_range,masterfile=masterfile

vdataname = 'CRIS_data_1hr'
tplot_prefix = 'ace_cris_'

if not keyword_set(indexfile) then indexfile='ace_cris_files'
hdfnames=['ACEepoch','flux_B','flux_C','flux_N','flux_O','flux_F','flux_Ne',$
	'flux_Na','flux_Mg','flux_Al','flux_Si','flux_P','flux_S','flux_Cl',$
	'flux_Ar','flux_K','flux_Ca','flux_Sc','flux_Ti','flux_V','flux_Cr',$
	'flux_Mn','flux_Fe','flux_Co','flux_Ni']

loadallhdf,time_range=time_range,vdataname=vdataname,data=data,$
	indexfile=indexfile,masterfile=masterfile,hdfnames=hdfnames

timearray = data.ACEepoch + time_double('96-1-1')
str_element,data,'time',timearray,/add

store_data,'ace_cris',data=data

return
end
