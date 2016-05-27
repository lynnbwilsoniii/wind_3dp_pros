;+
;PROCEDURE:	load_wi_sosp_3dp
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
;  PREFIX:	Prefix for TPLOT variables created.  Default is 'sosp'
;SEE ALSO: 
;  "loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Peter Schroeder
;FILE:  load_wi_sosp_3dp.pro
;LAST MODIFICATION: 03/04/30
;-
pro load_wi_sosp_3dp $
   ,time_range=trange $
   ,resolution=res $
;   ,bartel=bartel $
   ,data=d $
   ,nvdata = nd $
   ,masterfile=masterfile $
   ,prefix = prefix

;if keyword_set(bartel) then masterfile = 'wi_3dp_sosp_B_files'
;if not keyword_set(masterfile) then masterfile = 'wi_3dp_sosp_files'
if not keyword_set(masterfile) then masterfile = 'wi_sosp_3dp_files'

cdfnames = ['FLUX',  'ENERGY' ]

d=0
loadallcdf,masterfile=masterfile,cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange,resolu=res
if not keyword_set(d) then return


if data_type(prefix) eq 7 then px=prefix else px = 'sosp'


evals = round(d(0).energy/1000.)
elab = strtrim(string(evals)+' keV',2)
;elabpos=[ 1e-4, 4.2e-05,  1.3e-05,  5.7e-06,  2.5e-06,  8.4e-07, 1.3e-07]

store_data,px,data={x:d.time,y:dimen_shift(d.flux,1),v:dimen_shift(d.energy,1)}$
  ,min=-1e30,dlim={ylog:1,labels:elab}



end
