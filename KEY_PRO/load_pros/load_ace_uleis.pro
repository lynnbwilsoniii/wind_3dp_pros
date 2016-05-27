;+
;PROCEDURE:     load_ace_uleis
;PURPOSE:
;   loads ACE ULEIS Experiment key parameter data for "tplot".
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
;LAST MODIFIED: @(#)load_ace_uleis.pro	1.1 00/01/20
;-
pro load_ace_uleis,data=data,time_range=time_range,masterfile=masterfile

vdataname = 'ULEIS_data_1hr'
tplot_prefix = 'ace_uleis_'

if not keyword_set(indexfile) then indexfile='ace_uleis_files'
hdfnames=['ACEepoch','H_S1','H_S2','H_S3','H_S4','H_S5','unc_H_S1','unc_H_S2',$
	'unc_H_S3','unc_H_S4','unc_H_S5','He3_S1','He3_S2','He3_L2','He3_L3',$
	'He3_L4','He3_L5','He3_L6','unc_He3_S1','unc_He3_S2','unc_He3_L2',$
	'unc_He3_L3','unc_He3_L4','unc_He3_L5','unc_He3_L6','He4_S1','He4_S2',$
	'He4_S3','He4_L1','He4_L2','He4_L3','He4_L4','He4_L5','He4_L6',$
	'He4_L7','He4_L8','He4_L9','He4_L10','He4_L11','He4_L12','unc_He4_S1',$
	'unc_He4_S2','unc_He4_S3','unc_He4_L1','unc_He4_L2','unc_He4_L3',$
	'unc_He4_L4','unc_He4_L5','unc_He4_L6','unc_He4_L7','unc_He4_L8',$
	'unc_He4_L9','unc_He4_L10','unc_He4_L11','unc_He4_L12','C_S1','C_L1',$
	'C_L2','C_L3','C_L4','C_L5','C_L6','C_L7','C_L8','unc_C_S1','unc_C_L1',$
	'unc_C_L2','unc_C_L3','unc_C_L4','unc_C_L5','unc_C_L6','unc_C_L7',$
	'unc_C_L8','O_S1','O_L1','O_L2','O_L3','O_L4','O_L5','O_L6','O_L7',$
	'unc_O_S1','unc_O_L1','unc_O_L2','unc_O_L3','unc_O_L4','unc_O_L5',$
	'unc_O_L6','unc_O_L7','Ne_S_L1','Ne_S_L2','Ne_S_L3','Ne_S_L4',$
	'Ne_S_L5','Ne_S_L6','Ne_S_L7','unc_Ne_S_L1','unc_Ne_S_L2',$
	'unc_Ne_S_L3','unc_Ne_S_L4','unc_Ne_S_L5','unc_Ne_S_L6','unc_Ne_S_L7',$
	'Fe_L1','Fe_L2','Fe_L3','Fe_L4','Fe_L5','Fe_L6','Fe_L7','Fe_L8',$
	'Fe_L9','unc_Fe_L1','unc_Fe_L2','unc_Fe_L3','unc_Fe_L4','unc_Fe_L5',$
	'unc_Fe_L6','unc_Fe_L7','unc_Fe_L8','unc_Fe_L9','up_time_fraction']

loadallhdf,time_range=time_range,vdataname=vdataname,data=data,$
	indexfile=indexfile,masterfile=masterfile,hdfnames=hdfnames

timearray = data.ACEepoch + time_double('96-1-1')
str_element,data,'time',timearray,/add

store_data,'ace_uleis',data=data

return
end
