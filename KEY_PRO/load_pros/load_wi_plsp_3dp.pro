;+
;PROCEDURE:	load_wi_plsp_3dp
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
;  PREFIX:	Prefix for TPLOT variables created.  Default is 'plsp'
;  MOMENT:	Load PESA Low moment data.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION: @(#)load_wi_plsp_3dp.pro	1.7 02/11/01
;-
pro load_wi_plsp_3dp $
   ,time_range=trange $
   ,data=d $
   ,nvdata = nd $
   ,masterfile=masterfile $
   ,bartel=bartel $
   ,moment=moment $
   ,prefix = prefix $
   ,resolution = res

if not keyword_set(masterfile) then masterfile = 'wi_plsp_3dp_files'
if keyword_set(bartel) then masterfile = 'wi_3dp_plsp_b_files

cdfnames = ['FLUX',  'ENERGY' ]
momentnames = ['DENSITY','VEL_MAG','AVGTEMP','VELOCITY','VTHERMAL']
momentnames = ['P.'+momentnames,'A.'+momentnames]
if keyword_set(moment) then cdfnames = [cdfnames,'MOM.'+momentnames]

d = 0
nd = 0

loadallcdf,masterfile=masterfile,cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange,resolution=res

if data_type(d) ne 8 then return

if data_type(prefix) eq 7 then px=prefix else px = 'plsp'

mass = 1836*5.6856591e-6             ; mass eV/(km/sec)^2

if keyword_set(moment) then begin
;  str_element,/add,d,'mom.p.t',float(.5*mass*d.mom.p.vth^2)
;  str_element,/add,d,'mom.a.t',float(.5*mass*4*d.mom.a.vth^2)
  store_data,'PL',data=d
endif 
store_data,px,data={x:d.time,y:dimen_shift(d.flux,1),v:dimen_shift(d.energy,1)} $
    ,dlim={ylog:1,spec:1,zlog:1,ystyle:1,zstyle:1,yrange:[200.,10000.],zrange:[5e6,5e10]}

end
