
;+
;PROCEDURE:	load_wi_sp_mfi
;PURPOSE:	
;   loads WIND MAGNETOMETER 3 second data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  TIME_RANGE:  2 element vector specifying the time range
;  POLAR:       Also computes the B field in polar coordinates.
;  DATA:        Data returned in this named variable.
;  NODATA:	Returns 0 if data exists for time range, otherwise returns 1.
;  GSM:		If set, GSM data is retrieved.
;  PREFIX:	(string) prefix for tplot variables.  Default is 'wi_'
;  NAME:	(string) name for tplot variables. Default is 'wi_B3'
;  RESOLUTION:	Resolution to return in seconds.
;  MASTERFILE:	(string) full filename of master file.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_sp_mfi.pro
;VERSION: 1.17
;LAST MODIFICATION: 01/07/16
;-


pro load_wi_sp_mfi,time_range=trange,polar=polar,data=d,  $
  nodata=nodat, $
  GSM = gsm, $
  prefix = prefix, $
  resolution = res,  $
  name = bname, $
  masterfile=masterfile
     
if not keyword_set(masterfile) then masterfile = 'wi_sp_mfi_files'
cdfnames = ['B3GSE','B3RMSGSE']
if keyword_set(gsm) then cdfnames =['B3GSM','B3RMSGSM']


d=0
nodat = 0

loadallcdf,time_range=trange,masterfile=masterfile, $
    cdfnames=cdfnames,data=d,res =res

if keyword_set(d) eq 0 then begin
   message,'No 3 second MFI data during this time. Aborting.',/info
   nodat=1
   return
endif


if data_type(prefix) eq 7 then px=prefix else px = 'wi_'
if data_type(bname) eq 7 then px = bname else px = px+'B3'
if keyword_set(gsm) then px =px+'_GSM'

labs=['B!dx!n','B!dy!n','B!dz!n']


ndat = n_elements(d.time)

t = replicate(1.,20) # d.time
dt = (findgen(20)*3.-28.5) # replicate(1.,ndat)
t = t+dt
time  = reform(t,ndat*20)
b3gse = transpose(reform(d.b3gse,3,ndat*20))
b3rmsgse = transpose(reform(d.b3rmsgse,3,ndat*20))

bmag=sqrt(total(b3gse*b3gse,2))
w =where(bmag gt 1000.,c)
if c ne 0 then b3gse[w,*] = !values.f_nan
if c ne 0 then b3rmsgse[w,*] = !values.f_nan

b3rmsgse = sqrt( total(b3rmsgse^2,2) )

store_data,px,data={x:time,y:b3gse},min= -1e30, dlim={labels:labs}
store_data,px+'_rms',data={x:time,y:b3rmsgse},min= -1e30 

if keyword_set(polar) then begin
   xyz_to_polar,px,/ph_0_360

   options,px+'_mag','ytitle','|B|',/def
   options,px+'_th','ytitle','!4h!X!DB!U',/def
   ylim,px+'_th',-90,90,0,/def
   options,px+'_phi','ytitle','!4u!X!DB!U',/def
   options,px+'_phi','psym',3,/def
   ylim,px+'_phi',0,360.,0,/def

endif


end

