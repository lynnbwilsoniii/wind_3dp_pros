;+
;PROCEDURE:     load_ace_epam
;PURPOSE:
;   loads ACE EPAM Experiment key parameter data for "tplot".
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
;LAST MODIFIED: @(#)load_ace_epam.pro	1.1 00/01/20
;-
pro load_ace_epam,data=data,time_range=time_range,masterfile=masterfile

vdataname = 'EPAM_data_1hr'
tplot_prefix = 'ace_epam_'

if not keyword_set(indexfile) then indexfile='ace_epam_files'
hdfnames=['ACEepoch','P1','P2','P3','P4','P5','P6','P7','P8','unc_P1','unc_P2',$
	'unc_P3','unc_P4','unc_P5','unc_P6','unc_P7','unc_P8','DE1','DE2',$
	'DE3','DE4','unc_DE1','unc_DE2','unc_DE3','unc_DE4','W3','W4','W5',$
	'W6','W7','W8','unc_W3','unc_W4','unc_W5','unc_W6','unc_W7','unc_W8',$
	'E1p','E2p','E3p','E4p','FP5p','FP6p','FP7p','unc_E1p','unc_E2p',$
	'unc_E3p','unc_E4p','unc_FP5p','unc_FP6p','unc_FP7p','Z2','Z2A','Z3',$
	'Z4','unc_Z2','unc_Z2A','unc_Z3','unc_Z4','P1p','P2p','P3p','P4p',$
	'P5p','P6p','P7p','P8p','unc_P1p','unc_P2p','unc_P3p','unc_P4p',$
	'unc_P5p','unc_P6p','unc_P7p','unc_P8p','E1','E2','E3','E4','FP5',$
	'FP6','FP7','unc_E1','unc_E2','unc_E3','unc_E4','unc_FP5','unc_FP6',$
	'unc_FP7']

loadallhdf,time_range=time_range,vdataname=vdataname,data=data,$
	indexfile=indexfile,masterfile=masterfile,hdfnames=hdfnames

timearray = data.ACEepoch + time_double('96-1-1')
str_element,data,'time',timearray,/add

store_data,'ace_epam',data=data

return
end
