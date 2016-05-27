;+
;PROCEDURE:	load_wi_frm_3dp
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
;  PREFIX:	Prefix for TPLOT variables created.  Default is 'wi_frm'
;  RESOLUTION:	Resolution of data in seconds.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Peter Schroeder
;FILE:  load_wi_frm_3dp.pro
;LAST MODIFICATION: 97/02/26
;-
pro load_wi_frm_3dp $
   ,time_range=trange $
   ,data=d $
   ,nvdata = nd $
   ,masterfile=masterfile $
   ,prefix = prefix $
   ,resolution = res

if not keyword_set(masterfile) then masterfile = 'wi_frm_3dp_files'
px_default = 'wi_frm'

d = 0

loadallcdf,masterfile=masterfile,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange,resolution=res

if not keyword_set(d) then return

if data_type(prefix) eq 7 then px=prefix else px = px_default

store_data,px,data=d

end
