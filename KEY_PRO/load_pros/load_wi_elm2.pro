;+
;PROCEDURE:	load_wi_elm2
;PURPOSE:	
;   loads WIND 3D Plasma Experiment key parameter data for "tplot".
;
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  NVDATA:	Raw non-varying data can be returned through this variable.
;  TIME_RANGE:  2 element vector specifying the time range.
;  MASTERFILE:  (string) full file name to the master file.
;  RESOLUTION:  number of seconds resolution to return.
;  PREFIX:	Prefix for TPLOT variables created.  Default is 'el_mom'
;
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Peter Schroeder
;LAST MODIFIED: @(#)load_wi_elm2.pro	1.3 99/05/27
;-
pro load_wi_elm2 $
   ,time_range=trange $
   ,resolution=res $
   ,data=d $
   ,nvdata = nd $
   ,masterfile=masterfile $
   ,prefix = prefix

if not keyword_set(masterfile) then masterfile = 'wi_elm2_3dp_files'


d = 0
loadallcdf,masterfile=masterfile,cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange,resolution=res
if not keyword_set(d) then return

if data_type(prefix) eq 7 then px=prefix else px = 'el_mom'


store_data,px,data=d


end
