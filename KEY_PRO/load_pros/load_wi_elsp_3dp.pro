;+
;PROCEDURE:	load_wi_elsp_3dp
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
;  PREFIX:	Prefix for TPLOT variables created.  Default is 'elsp'
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_elsp_3dp.pro
;LAST MODIFICATION: 99/05/27
;-
pro load_wi_elsp_3dp $
   ,time_range=trange $
   ,data=d $
   ,nvdata = nd $
   ,resolution = res  $
   ,masterfile=masterfile $
   ,prefix = prefix

if not keyword_set(masterfile) then masterfile = 'wi_elsp_3dp_files'

cdfnames = ['FLUX',  'ENERGY' ]

loadallcdf,masterfile=masterfile,cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange,res=res

if data_type(prefix) eq 7 then px=prefix else px = 'elsp'


store_data,px,data={x:d.time,y:dimen_shift(d.flux,1),v:dimen_shift(d.energy,1)}$
  ,min=-1e30,dlim={ylog:1}

end
