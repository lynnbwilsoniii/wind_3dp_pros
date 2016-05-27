;+
;PROCEDURE:     load_ace_sepica
;PURPOSE:
;   loads ACE SEPICA Experiment key parameter data for "tplot".
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
;LAST MODIFIED: @(#)load_ace_sepica.pro	1.1 00/01/20
;-
pro load_ace_sepica,data=data,time_range=time_range,masterfile=masterfile

vdataname = 'SEPICA_data_120s'
tplot_prefix = 'ace_sepica_'

if not keyword_set(indexfile) then indexfile='ace_sepica_files'
hdfnames=['ACEepoch','H1','H2','H3','H4','H5','He1','He2','He3','He4','He5',$
	'He6','unc_H1','unc_H2','unc_H3','unc_H4','unc_H5','unc_He1','unc_He2',$
	'unc_He3','unc_He4','unc_He5','unc_He6','up_time_fraction']

loadallhdf,time_range=time_range,vdataname=vdataname,data=data,$
	indexfile=indexfile,masterfile=masterfile,hdfnames=hdfnames

timearray = data.ACEepoch + time_double('96-1-1')
str_element,data,'time',timearray,/add

store_data,'ace_sepica',data=data

return
end
