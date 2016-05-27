;+
;PROCEDURE:	load_wi_sopd
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
;  PREFIX:	Prefix for TPLOT variables created.  Default is 'ehpd'
;
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Peter Schroeder
;FILE:  load_wi_sopd.pro
;LAST MODIFICATION: 2000/9/13
;-
pro load_wi_sopd $
   ,time_range=trange $
   ,data=d $
   ,nvdata = nd $
   ,masterfile=masterfile $
   ,resolution=res $
   ,prefix = prefix


if not keyword_set(masterfile) then masterfile = 'wi_sopd_3dp_files'

cdfnames = ['FLUX',  'ENERGY' ,'PANGLE','MAGF','VSW']

d = 0
nd = 0
loadallcdf,masterfile=masterfile,cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange,resolution=res

if not keyword_set(d) then return

if data_type(prefix) eq 7 then px=prefix else px = 'sopd'

store_data,px,data={x:d.time,y:dimen_shift(d.flux,1), $
  v1:dimen_shift(d.energy,1),v2:dimen_shift(d.pangle,1)}$
  ,min=-1e30,dlim={ylog:1}

energies = dimen_shift(d.energy,1)
angles = dimen_shift(d.pangle,1)

ang_size = size(angles)
e_size = size(energies)

n_ang = ang_size(ang_size(0))
n_nrg = e_size(e_size(0))


for i = 0, n_nrg-1, 1 do begin
   reduce_pads,px,1,i,i,e_units=1
ENDFOR

reduce_pads,px,2,6,7,e_units=1
reduce_pads,px,2,0,1,e_units=1


return
end

